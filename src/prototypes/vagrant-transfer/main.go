package main

import (
	"archive/tar"
	"bytes"
	"compress/flate"
	"compress/gzip"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"os"
	"path"
	"path/filepath"
	"runtime"
	"runtime/debug"
	"strings"

	"github.com/klauspost/pgzip"
)

const blockSize = 500000

type digest struct {
	Bytes  int64  `json:"bytes"`
	SHA256 string `json:"sha256"`
}

type archiveState struct {
	Entries       int `json:"entries"`
	RegularFiles  int `json:"regular_files"`
	VMCXFiles     int `json:"vmcx_files"`
	HyperVBoxXMLs int `json:"hyperv_box_xml_files"`
}

type manifest struct {
	Schema      string       `json:"schema"`
	Source      digest       `json:"source"`
	RawTar      digest       `json:"raw_tar"`
	Archive     archiveState `json:"archive"`
	Compression struct {
		Algorithm           string `json:"algorithm"`
		PackerPluginVersion string `json:"packer_vagrant_plugin_version"`
		PgzipModule         string `json:"pgzip_module"`
		PgzipVersion        string `json:"pgzip_version"`
		DeflateModule       string `json:"deflate_module"`
		DeflateVersion      string `json:"deflate_version"`
		BlockSize           int    `json:"block_size"`
		Level               int    `json:"level"`
		Parallelism         string `json:"parallelism"`
		GzipHeader          string `json:"gzip_header_hex"`
	} `json:"compression"`
}

type reconstructionState struct {
	HostOS              string `json:"host_os"`
	HostArchitecture    string `json:"host_architecture"`
	Parallelism         int    `json:"parallelism"`
	RawTar              digest `json:"raw_tar"`
	ReconstructedSource digest `json:"reconstructed_source"`
	ExpectedSource      digest `json:"expected_source"`
	Exact               bool   `json:"exact"`
}

type canonicalizationState struct {
	Schema    string       `json:"schema"`
	Source    digest       `json:"source"`
	Canonical digest       `json:"canonical"`
	Input     archiveState `json:"input_archive"`
	Output    archiveState `json:"output_archive"`
	Removed   []string     `json:"removed_entries"`
}

type virtualBoxCanonicalFile struct {
	Path         string `json:"path"`
	LogicalBytes int64  `json:"logical_bytes"`
	SHA256       string `json:"sha256"`
}

type virtualBoxProducerManifest struct {
	Canonical struct {
		Files []virtualBoxCanonicalFile `json:"files"`
	} `json:"canonical"`
	CanonicalDisk struct {
		FormatVariant string `json:"format_variant"`
	} `json:"canonical_disk"`
}

type virtualBoxSparseBoxState struct {
	Schema       string            `json:"schema"`
	Box          digest            `json:"box"`
	Architecture string            `json:"architecture"`
	Provider     string            `json:"provider"`
	Entries      map[string]digest `json:"entries"`
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 {
		return usage()
	}

	switch args[0] {
	case "canonicalize-hyperv":
		if len(args) != 4 {
			return usage()
		}
		return canonicalizeHyperV(args[1], args[2], args[3])
	case "roundtrip":
		if len(args) != 4 {
			return usage()
		}
		return roundtrip(args[1], args[2], args[3])
	case "decode":
		if len(args) != 5 {
			return usage()
		}
		return decode(args[1], args[2], args[3], args[4])
	case "verify-virtualbox-sparse-box":
		if len(args) != 5 {
			return usage()
		}
		return verifyVirtualBoxSparseBox(args[1], args[2], args[3], args[4])
	case "reconstruct":
		if len(args) != 4 {
			return usage()
		}
		return reconstruct(args[1], args[2], args[3])
	case "reconstruct-packer-writes":
		if len(args) != 4 {
			return usage()
		}
		return reconstructPackerWrites(args[1], args[2], args[3])
	default:
		return usage()
	}
}

func usage() error {
	return errors.New("usage: go run . canonicalize-hyperv <source.box> <canonical.box> <result.json> | roundtrip <source.box> <scratch-directory> <packer-plugin-version> | decode <source.box> <raw.tar> <manifest.json> <packer-plugin-version> | verify-virtualbox-sparse-box <source.box> <producer-manifest.json> <architecture> <result.json> | reconstruct <raw.tar> <manifest.json> <reconstructed.box> | reconstruct-packer-writes <raw.tar> <manifest.json> <reconstructed.box>")
}

func verifyVirtualBoxSparseBox(boxPath, producerManifestPath, architecture, resultPath string) error {
	contents, err := os.ReadFile(producerManifestPath)
	if err != nil {
		return err
	}
	var producer virtualBoxProducerManifest
	if err := json.Unmarshal(contents, &producer); err != nil {
		return err
	}
	if strings.Contains(producer.CanonicalDisk.FormatVariant, "streamOptimized") {
		return fmt.Errorf("canonical VMDK is compressed: %s", producer.CanonicalDisk.FormatVariant)
	}

	expected := make(map[string]digest)
	var expectedOVF digest
	var expectedVMDK bool
	var expectedNVRAM bool
	for _, file := range producer.Canonical.Files {
		state := digest{Bytes: file.LogicalBytes, SHA256: file.SHA256}
		name := filepath.Base(file.Path)
		switch strings.ToLower(filepath.Ext(name)) {
		case ".ovf":
			if expectedOVF.SHA256 != "" {
				return errors.New("producer manifest contains more than one OVF")
			}
			expectedOVF = state
		case ".vmdk":
			if expectedVMDK {
				return errors.New("producer manifest contains more than one VMDK")
			}
			expectedVMDK = true
			expected[name] = state
		case ".nvram":
			if expectedNVRAM {
				return errors.New("producer manifest contains more than one NVRAM")
			}
			expectedNVRAM = true
			expected[name] = state
		default:
			return fmt.Errorf("unexpected canonical file %q", file.Path)
		}
	}
	if expectedOVF.SHA256 == "" || !expectedVMDK || !expectedNVRAM || len(expected) != 2 {
		return errors.New("producer manifest must contain exactly one OVF, VMDK, and NVRAM")
	}
	expected["box.ovf"] = expectedOVF

	box, err := os.Open(boxPath)
	if err != nil {
		return err
	}
	defer box.Close()
	gzipReader, err := gzip.NewReader(box)
	if err != nil {
		return err
	}
	defer gzipReader.Close()

	entries := make(map[string]digest)
	var ovfContents []byte
	var metadataContents []byte
	reader := tar.NewReader(gzipReader)
	for {
		header, nextErr := reader.Next()
		if errors.Is(nextErr, io.EOF) {
			break
		}
		if nextErr != nil {
			return nextErr
		}
		name, pathErr := safeArchivePath(header.Name)
		if pathErr != nil {
			return pathErr
		}
		if header.Typeflag != tar.TypeReg && header.Typeflag != tar.TypeRegA {
			return fmt.Errorf("unsafe archive entry %q has unsupported type %d", header.Name, header.Typeflag)
		}
		if _, exists := entries[name]; exists {
			return fmt.Errorf("duplicate box entry %q", name)
		}

		hash := sha256.New()
		var capture bytes.Buffer
		output := io.Writer(hash)
		if name == "box.ovf" || name == "metadata.json" {
			output = io.MultiWriter(hash, &capture)
		}
		written, copyErr := io.Copy(output, reader)
		if copyErr != nil {
			return copyErr
		}
		entries[name] = digest{Bytes: written, SHA256: hex.EncodeToString(hash.Sum(nil))}
		if name == "box.ovf" {
			ovfContents = capture.Bytes()
		}
		if name == "metadata.json" {
			metadataContents = capture.Bytes()
		}
	}

	expectedNames := map[string]bool{"Vagrantfile": true, "box.ovf": true, "metadata.json": true}
	for name, state := range expected {
		expectedNames[name] = true
		if entries[name] != state {
			return fmt.Errorf("box entry %q differs from canonical artifact", name)
		}
	}
	if len(entries) != len(expectedNames) {
		return fmt.Errorf("box contains %d entries, expected %d", len(entries), len(expectedNames))
	}
	for name := range entries {
		if !expectedNames[name] {
			return fmt.Errorf("unexpected box entry %q", name)
		}
	}
	if !bytes.Contains(ovfContents, []byte("#sparse")) || bytes.Contains(ovfContents, []byte("#streamOptimized")) {
		return errors.New("box.ovf does not exclusively declare a sparse VMDK")
	}

	var metadata map[string]string
	if err := json.Unmarshal(metadataContents, &metadata); err != nil {
		return err
	}
	if metadata["provider"] != "virtualbox" || metadata["architecture"] != architecture || len(metadata) != 2 {
		return fmt.Errorf("unexpected metadata.json: %v", metadata)
	}
	boxState, err := fileDigest(boxPath)
	if err != nil {
		return err
	}
	result := virtualBoxSparseBoxState{
		Schema:       "vagrant-transfer/virtualbox-sparse-box/v1",
		Box:          boxState,
		Architecture: architecture,
		Provider:     "virtualbox",
		Entries:      entries,
	}
	if err := writeJSON(resultPath, result); err != nil {
		return err
	}
	return printJSON(result)
}

func canonicalizeHyperV(sourcePath, outputPath, resultPath string) error {
	source, err := fileDigest(sourcePath)
	if err != nil {
		return err
	}

	in, err := os.Open(sourcePath)
	if err != nil {
		return err
	}
	defer in.Close()
	gzipReader, err := gzip.NewReader(in)
	if err != nil {
		return err
	}
	defer gzipReader.Close()

	raw, err := os.CreateTemp(filepath.Dir(outputPath), ".canonical-hyperv-*.tar")
	if err != nil {
		return err
	}
	rawPath := raw.Name()
	defer os.Remove(rawPath)

	reader := tar.NewReader(gzipReader)
	writer := tar.NewWriter(raw)
	var input archiveState
	var output archiveState
	removed := []string{}
	for {
		header, nextErr := reader.Next()
		if errors.Is(nextErr, io.EOF) {
			break
		}
		if nextErr != nil {
			writer.Close()
			raw.Close()
			return nextErr
		}
		name, pathErr := safeArchivePath(header.Name)
		if pathErr != nil {
			writer.Close()
			raw.Close()
			return pathErr
		}
		if header.Typeflag != tar.TypeReg && header.Typeflag != tar.TypeRegA {
			writer.Close()
			raw.Close()
			return fmt.Errorf("unsafe archive entry %q has unsupported type %d", header.Name, header.Typeflag)
		}
		countArchiveEntry(&input, name)
		if strings.EqualFold(name, "Virtual Machines/box.xml") {
			removed = append(removed, name)
			continue
		}
		if err := writer.WriteHeader(header); err != nil {
			writer.Close()
			raw.Close()
			return err
		}
		if _, err := io.Copy(writer, reader); err != nil {
			writer.Close()
			raw.Close()
			return err
		}
		countArchiveEntry(&output, name)
	}
	if err := writer.Close(); err != nil {
		raw.Close()
		return err
	}
	if err := raw.Close(); err != nil {
		return err
	}
	if input.HyperVBoxXMLs != 1 || len(removed) != 1 {
		return fmt.Errorf("expected exactly one Virtual Machines/box.xml, found %d", input.HyperVBoxXMLs)
	}
	if output.HyperVBoxXMLs != 0 {
		return errors.New("canonical archive still contains Virtual Machines/box.xml")
	}
	if output.VMCXFiles == 0 {
		return errors.New("canonical archive contains no .vmcx file")
	}

	if err := compressRawTar(rawPath, outputPath); err != nil {
		return err
	}
	canonical, err := fileDigest(outputPath)
	if err != nil {
		return err
	}
	result := canonicalizationState{
		Schema:    "vagrant-transfer/hyperv-canonical-box/v1",
		Source:    source,
		Canonical: canonical,
		Input:     input,
		Output:    output,
		Removed:   removed,
	}
	if err := writeJSON(resultPath, result); err != nil {
		return err
	}
	return printJSON(result)
}

func compressRawTar(rawPath, outputPath string) error {
	in, err := os.Open(rawPath)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	writer, err := pgzip.NewWriterLevel(out, flate.DefaultCompression)
	if err != nil {
		out.Close()
		return err
	}
	if err := writer.SetConcurrency(blockSize, runtime.GOMAXPROCS(-1)); err != nil {
		out.Close()
		return err
	}
	_, copyErr := copyPackerTarWrites(writer, in)
	writerErr := writer.Close()
	closeErr := out.Close()
	if copyErr != nil {
		return copyErr
	}
	if writerErr != nil {
		return writerErr
	}
	return closeErr
}

func roundtrip(source, scratch, pluginVersion string) error {
	if err := os.MkdirAll(scratch, 0o755); err != nil {
		return err
	}
	raw := filepath.Join(scratch, "vagrant.raw.tar")
	manifestPath := filepath.Join(scratch, "vagrant-transfer.json")
	reconstructed := filepath.Join(scratch, "vagrant.reconstructed.box")
	if err := decode(source, raw, manifestPath, pluginVersion); err != nil {
		return err
	}
	return reconstructPackerWrites(raw, manifestPath, reconstructed)
}

func decode(sourcePath, rawPath, manifestPath, pluginVersion string) error {
	header, err := gzipHeader(sourcePath)
	if err != nil {
		return err
	}
	source, err := fileDigest(sourcePath)
	if err != nil {
		return err
	}

	in, err := os.Open(sourcePath)
	if err != nil {
		return err
	}
	defer in.Close()
	gzipReader, err := gzip.NewReader(in)
	if err != nil {
		return err
	}
	defer gzipReader.Close()
	out, err := os.Create(rawPath)
	if err != nil {
		return err
	}
	hash := sha256.New()
	bytesWritten, copyErr := io.Copy(io.MultiWriter(out, hash), gzipReader)
	closeErr := out.Close()
	if copyErr != nil {
		return copyErr
	}
	if closeErr != nil {
		return closeErr
	}
	raw := digest{Bytes: bytesWritten, SHA256: hex.EncodeToString(hash.Sum(nil))}
	archive, err := inspectTar(rawPath)
	if err != nil {
		return err
	}

	result := manifest{Schema: "vagrant-transfer/raw-tar/v1", Source: source, RawTar: raw, Archive: archive}
	result.Compression.Algorithm = "gzip"
	result.Compression.PackerPluginVersion = pluginVersion
	result.Compression.PgzipModule, result.Compression.PgzipVersion = buildModule("github.com/klauspost/pgzip")
	result.Compression.DeflateModule, result.Compression.DeflateVersion = buildModule("github.com/klauspost/compress")
	result.Compression.BlockSize = blockSize
	result.Compression.Level = flate.DefaultCompression
	result.Compression.Parallelism = "runtime.GOMAXPROCS(-1)"
	result.Compression.GzipHeader = hex.EncodeToString(header[:])

	if err := writeJSON(manifestPath, result); err != nil {
		return err
	}
	return printJSON(result)
}

func reconstruct(rawPath, manifestPath, outputPath string) error {
	return reconstructWith(rawPath, manifestPath, outputPath, io.Copy)
}

func reconstructPackerWrites(rawPath, manifestPath, outputPath string) error {
	return reconstructWith(rawPath, manifestPath, outputPath, copyPackerTarWrites)
}

func reconstructWith(rawPath, manifestPath, outputPath string, copyInput func(io.Writer, io.Reader) (int64, error)) error {
	var expected manifest
	contents, err := os.ReadFile(manifestPath)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(contents, &expected); err != nil {
		return err
	}
	if expected.Schema != "vagrant-transfer/raw-tar/v1" {
		return fmt.Errorf("unsupported manifest schema %q", expected.Schema)
	}
	module, version := buildModule("github.com/klauspost/pgzip")
	if module != expected.Compression.PgzipModule || version != expected.Compression.PgzipVersion {
		return fmt.Errorf("pgzip mismatch: manifest requires %s %s, executable contains %s %s", expected.Compression.PgzipModule, expected.Compression.PgzipVersion, module, version)
	}
	deflateModule, deflateVersion := buildModule("github.com/klauspost/compress")
	if deflateModule != expected.Compression.DeflateModule || deflateVersion != expected.Compression.DeflateVersion {
		return fmt.Errorf("deflate mismatch: manifest requires %s %s, executable contains %s %s", expected.Compression.DeflateModule, expected.Compression.DeflateVersion, deflateModule, deflateVersion)
	}
	if expected.Compression.Algorithm != "gzip" || expected.Compression.BlockSize != blockSize || expected.Compression.Level != flate.DefaultCompression || expected.Compression.Parallelism != "runtime.GOMAXPROCS(-1)" || expected.Compression.GzipHeader != "1f8b080000096e8800ff" {
		return errors.New("manifest compression settings do not match this prototype")
	}

	in, err := os.Open(rawPath)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	writer, err := pgzip.NewWriterLevel(out, flate.DefaultCompression)
	if err != nil {
		out.Close()
		return err
	}
	parallelism := runtime.GOMAXPROCS(-1)
	if err := writer.SetConcurrency(blockSize, parallelism); err != nil {
		out.Close()
		return err
	}
	rawHash := sha256.New()
	rawBytes, copyErr := copyInput(writer, io.TeeReader(in, rawHash))
	writerErr := writer.Close()
	closeErr := out.Close()
	if copyErr != nil {
		return copyErr
	}
	if writerErr != nil {
		return writerErr
	}
	if closeErr != nil {
		return closeErr
	}

	raw := digest{Bytes: rawBytes, SHA256: hex.EncodeToString(rawHash.Sum(nil))}
	reconstructed, err := fileDigest(outputPath)
	if err != nil {
		return err
	}
	state := reconstructionState{
		HostOS:              runtime.GOOS,
		HostArchitecture:    runtime.GOARCH,
		Parallelism:         parallelism,
		RawTar:              raw,
		ReconstructedSource: reconstructed,
		ExpectedSource:      expected.Source,
		Exact:               raw == expected.RawTar && reconstructed == expected.Source,
	}
	if err := printJSON(state); err != nil {
		return err
	}
	if !state.Exact {
		return errors.New("reconstructed box differs from the source")
	}
	return nil
}

func copyPackerTarWrites(dst io.Writer, src io.Reader) (int64, error) {
	var total int64
	header := make([]byte, 512)
	for {
		if _, err := io.ReadFull(src, header); err != nil {
			return total, err
		}
		if err := writeAll(dst, header); err != nil {
			return total, err
		}
		total += int64(len(header))
		if isZeroBlock(header) {
			if _, err := io.ReadFull(src, header); err != nil {
				return total, err
			}
			if !isZeroBlock(header) {
				return total, errors.New("tar trailer contains only one zero block")
			}
			if err := writeAll(dst, header); err != nil {
				return total, err
			}
			total += int64(len(header))
			var extra [1]byte
			if n, err := src.Read(extra[:]); n != 0 || !errors.Is(err, io.EOF) {
				return total, errors.New("raw tar contains bytes after the two-block trailer")
			}
			return total, nil
		}

		size, err := tarEntrySize(header)
		if err != nil {
			return total, err
		}
		remaining := size
		buffer := make([]byte, 32*1024)
		for remaining > 0 {
			chunk := int64(len(buffer))
			if remaining < chunk {
				chunk = remaining
			}
			if _, err := io.ReadFull(src, buffer[:chunk]); err != nil {
				return total, err
			}
			if err := writeAll(dst, buffer[:chunk]); err != nil {
				return total, err
			}
			total += chunk
			remaining -= chunk
		}

		padding := (512 - size%512) % 512
		if padding > 0 {
			if _, err := io.ReadFull(src, buffer[:padding]); err != nil {
				return total, err
			}
			if err := writeAll(dst, buffer[:padding]); err != nil {
				return total, err
			}
			total += padding
		}
	}
}

func tarEntrySize(header []byte) (int64, error) {
	field := header[124:136]
	if field[0]&0x80 != 0 {
		if field[0]&0x40 != 0 {
			return 0, errors.New("prototype does not support negative base-256 tar sizes")
		}
		var size uint64
		for index, octet := range field {
			if index == 0 {
				octet &= 0x7f
			}
			if size > (math.MaxInt64-uint64(octet))/256 {
				return 0, errors.New("base-256 tar size overflows int64")
			}
			size = size*256 + uint64(octet)
		}
		return int64(size), nil
	}
	value := strings.Trim(string(field), " \x00")
	if value == "" {
		return 0, nil
	}
	var size int64
	for _, digit := range value {
		if digit < '0' || digit > '7' {
			return 0, fmt.Errorf("invalid tar size %q", value)
		}
		size = size*8 + int64(digit-'0')
	}
	return size, nil
}

func isZeroBlock(block []byte) bool {
	for _, value := range block {
		if value != 0 {
			return false
		}
	}
	return true
}

func writeAll(dst io.Writer, contents []byte) error {
	for len(contents) > 0 {
		written, err := dst.Write(contents)
		if err != nil {
			return err
		}
		if written == 0 {
			return io.ErrShortWrite
		}
		contents = contents[written:]
	}
	return nil
}

func gzipHeader(filename string) ([10]byte, error) {
	var header [10]byte
	file, err := os.Open(filename)
	if err != nil {
		return header, err
	}
	defer file.Close()
	if _, err := io.ReadFull(file, header[:]); err != nil {
		return header, err
	}
	if header[0] != 0x1f || header[1] != 0x8b || header[2] != 8 {
		return header, errors.New("source is not a gzip-compressed box")
	}
	if header[3] != 0 {
		return header, fmt.Errorf("prototype only supports a gzip header without optional fields; flags are %#x", header[3])
	}
	return header, nil
}

func inspectTar(filename string) (archiveState, error) {
	var state archiveState
	file, err := os.Open(filename)
	if err != nil {
		return state, err
	}
	defer file.Close()
	reader := tar.NewReader(file)
	for {
		header, err := reader.Next()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return state, err
		}
		name, err := safeArchivePath(header.Name)
		if err != nil {
			return state, err
		}
		if header.Typeflag != tar.TypeReg && header.Typeflag != tar.TypeRegA {
			return state, fmt.Errorf("unsafe archive entry %q has unsupported type %d", header.Name, header.Typeflag)
		}
		countArchiveEntry(&state, name)
	}
	return state, nil
}

func countArchiveEntry(state *archiveState, name string) {
	state.Entries++
	state.RegularFiles++
	if strings.EqualFold(path.Ext(name), ".vmcx") {
		state.VMCXFiles++
	}
	if strings.EqualFold(name, "Virtual Machines/box.xml") {
		state.HyperVBoxXMLs++
	}
}

func safeArchivePath(name string) (string, error) {
	normalized := strings.ReplaceAll(name, `\`, "/")
	cleaned := path.Clean(normalized)
	if normalized == "" || cleaned == "." || path.IsAbs(cleaned) || cleaned == ".." || strings.HasPrefix(cleaned, "../") || (len(cleaned) >= 2 && cleaned[1] == ':') {
		return "", fmt.Errorf("unsafe archive path %q", name)
	}
	return cleaned, nil
}

func fileDigest(filename string) (digest, error) {
	var result digest
	file, err := os.Open(filename)
	if err != nil {
		return result, err
	}
	defer file.Close()
	hash := sha256.New()
	bytesRead, err := io.Copy(hash, file)
	if err != nil {
		return result, err
	}
	return digest{Bytes: bytesRead, SHA256: hex.EncodeToString(hash.Sum(nil))}, nil
}

func buildModule(module string) (string, string) {
	info, ok := debug.ReadBuildInfo()
	if !ok {
		return module, "unknown"
	}
	for _, dependency := range info.Deps {
		if dependency.Path == module {
			return dependency.Path, dependency.Version
		}
	}
	return module, "unknown"
}

func writeJSON(filename string, value any) error {
	contents, err := json.MarshalIndent(value, "", "  ")
	if err != nil {
		return err
	}
	contents = append(contents, '\n')
	return os.WriteFile(filename, contents, 0o644)
}

func printJSON(value any) error {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	return encoder.Encode(value)
}
