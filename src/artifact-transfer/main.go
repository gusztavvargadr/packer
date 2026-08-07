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
	"time"

	"github.com/klauspost/pgzip"
)

const (
	manifestSchema      = "artifact-transfer/vagrant-box/v1"
	manifestFilename    = "manifest.json"
	rawTarFilename      = "vagrant.raw.tar"
	canonicalBoxPath    = "vagrant/vagrant.box"
	checksumFilename    = "checksum.sha256"
	packerPluginSource  = "github.com/hashicorp/vagrant"
	packerPluginVersion = "1.1.6"
	pgzipModule         = "github.com/klauspost/pgzip"
	pgzipVersion        = "v0.0.0-20151221113845-47f36e165cec"
	deflateModule       = "github.com/klauspost/compress"
	deflateVersion      = "v1.13.6"
	compressionPolicy   = "runtime.GOMAXPROCS(-1)"
	reconstructionName  = "packer-vagrant-tar-writer/v1"
	gzipHeaderHex       = "1f8b080000096e8800ff"
	archiveSafety       = "validated"
	packerBlockSize     = 500000
	packerFileWriteSize = 32 * 1024
	tarBlockSize        = 512
)

type identity struct {
	Path   string `json:"path"`
	Bytes  int64  `json:"bytes"`
	SHA256 string `json:"sha256"`
}

type archiveState struct {
	Format       string `json:"format"`
	Safety       string `json:"safety"`
	Entries      int    `json:"entries"`
	RegularFiles int    `json:"regular_files"`
}

type moduleContract struct {
	Module  string `json:"module"`
	Version string `json:"version"`
}

type manifest struct {
	Schema              string       `json:"schema"`
	HandoffStartedAtUTC time.Time    `json:"handoff_started_at_utc"`
	Canonical           identity     `json:"canonical"`
	Transfer            identity     `json:"transfer"`
	Archive             archiveState `json:"archive"`
	Producer            struct {
		PackerVagrantPlugin moduleContract `json:"packer_vagrant_plugin"`
	} `json:"producer"`
	Compression struct {
		Algorithm   string         `json:"algorithm"`
		PGzip       moduleContract `json:"pgzip"`
		Deflate     moduleContract `json:"deflate"`
		BlockBytes  int            `json:"block_bytes"`
		Level       int            `json:"level"`
		Parallelism string         `json:"parallelism"`
		HeaderHex   string         `json:"gzip_header_hex"`
	} `json:"compression"`
	Reconstruction struct {
		Schedule       string `json:"schedule"`
		HeaderBytes    int    `json:"header_bytes"`
		FileWriteBytes int    `json:"file_write_bytes"`
		Padding        string `json:"padding"`
		TrailerWrites  int    `json:"trailer_writes"`
	} `json:"reconstruction"`
}

type operationResult struct {
	Schema                 string       `json:"schema"`
	Operation              string       `json:"operation"`
	Canonical              identity     `json:"canonical"`
	Transfer               identity     `json:"transfer"`
	Archive                archiveState `json:"archive"`
	OperationWallSeconds   float64      `json:"operation_wall_seconds"`
	UserCPUSeconds         float64      `json:"user_cpu_seconds"`
	SystemCPUSeconds       float64      `json:"system_cpu_seconds"`
	HandoffWallSeconds     *float64     `json:"handoff_wall_seconds,omitempty"`
	StagingOutputBytes     int64        `json:"staging_output_bytes"`
	DiskFreeBytesBefore    uint64       `json:"disk_free_bytes_before"`
	MinimumDiskFreeBytes   uint64       `json:"minimum_disk_free_bytes"`
	PeakTemporaryDiskBytes uint64       `json:"peak_temporary_disk_bytes"`
}

type cpuTime struct {
	UserSeconds   float64
	SystemSeconds float64
}

type diskMeasurement struct {
	MinimumBytes uint64
	Err          error
}

type diskSampler struct {
	initialBytes uint64
	stop         chan struct{}
	done         chan diskMeasurement
}

type operationMeasurement struct {
	startedAt  time.Time
	startedCPU cpuTime
	disk       *diskSampler
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(arguments []string) error {
	if len(arguments) != 3 {
		return usage()
	}
	var (
		result operationResult
		err    error
	)
	switch arguments[0] {
	case "prepare-vagrant":
		result, err = prepareVagrantTransfer(arguments[1], arguments[2])
	case "reconstruct-vagrant":
		result, err = reconstructVagrantTransfer(arguments[1], arguments[2])
	case "verify-vagrant":
		result, err = verifyVagrantTransfer(arguments[1], arguments[2])
	default:
		return usage()
	}
	if err != nil {
		return err
	}
	return printJSON(result)
}

func usage() error {
	return errors.New("usage: artifact-transfer prepare-vagrant <artifact-directory> <transfer-directory> | reconstruct-vagrant <transfer-directory> <artifact-directory> | verify-vagrant <transfer-directory> <artifact-directory>")
}

func prepareVagrantTransfer(artifactDirectory, transferDirectory string) (operationResult, error) {
	var result operationResult
	if err := requireAbsent(transferDirectory, "transfer directory"); err != nil {
		return result, err
	}
	parent := filepath.Dir(transferDirectory)
	if err := os.MkdirAll(parent, 0o755); err != nil {
		return result, err
	}
	measurement, err := beginOperation(parent)
	if err != nil {
		return result, err
	}
	defer measurement.cancel()
	canonicalPath := filepath.Join(artifactDirectory, filepath.FromSlash(canonicalBoxPath))
	canonical, err := fileIdentity(canonicalPath, canonicalBoxPath)
	if err != nil {
		return result, fmt.Errorf("read canonical Vagrant box: %w", err)
	}
	if err := verifyPackerChecksum(filepath.Join(artifactDirectory, checksumFilename), canonical); err != nil {
		return result, err
	}
	if err := validateGzipHeader(canonicalPath); err != nil {
		return result, err
	}

	staging, err := os.MkdirTemp(parent, ".artifact-transfer-*")
	if err != nil {
		return result, err
	}
	defer os.RemoveAll(staging)
	rawPath := filepath.Join(staging, rawTarFilename)
	transfer, archive, err := decodeAndValidate(canonicalPath, rawPath)
	if err != nil {
		return result, err
	}
	transfer.Path = rawTarFilename

	contract, err := newManifest(measurement.startedAt.UTC(), canonical, transfer, archive)
	if err != nil {
		return result, err
	}
	if err := writeJSON(filepath.Join(staging, manifestFilename), contract); err != nil {
		return result, err
	}
	if err := os.Rename(staging, transferDirectory); err != nil {
		return result, fmt.Errorf("promote transfer payload: %w", err)
	}

	return measurement.finish("prepare-vagrant", contract, transfer.Bytes)
}

func reconstructVagrantTransfer(transferDirectory, artifactDirectory string) (operationResult, error) {
	var result operationResult
	if err := requireAbsent(artifactDirectory, "artifact directory"); err != nil {
		return result, err
	}

	parent := filepath.Dir(artifactDirectory)
	if err := os.MkdirAll(parent, 0o755); err != nil {
		return result, err
	}
	measurement, err := beginOperation(parent)
	if err != nil {
		return result, err
	}
	defer measurement.cancel()
	contract, rawPath, err := validateTransferPayload(transferDirectory)
	if err != nil {
		return result, err
	}
	staging, err := os.MkdirTemp(parent, ".artifact-reconstruction-*")
	if err != nil {
		return result, err
	}
	defer os.RemoveAll(staging)
	boxPath := filepath.Join(staging, filepath.FromSlash(canonicalBoxPath))
	if err := os.MkdirAll(filepath.Dir(boxPath), 0o755); err != nil {
		return result, err
	}
	if err := reconstructBox(rawPath, boxPath); err != nil {
		return result, err
	}
	actual, err := fileIdentity(boxPath, canonicalBoxPath)
	if err != nil {
		return result, err
	}
	if actual != contract.Canonical {
		return result, fmt.Errorf("reconstructed Vagrant box identity differs: expected %d bytes and %s, got %d bytes and %s", contract.Canonical.Bytes, contract.Canonical.SHA256, actual.Bytes, actual.SHA256)
	}
	if err := writeChecksum(filepath.Join(staging, checksumFilename), actual); err != nil {
		return result, err
	}
	if err := os.Rename(staging, artifactDirectory); err != nil {
		return result, fmt.Errorf("promote reconstructed artifact: %w", err)
	}

	result, err = measurement.finish("reconstruct-vagrant", contract, actual.Bytes)
	if err != nil {
		return result, err
	}
	handoff := time.Since(contract.HandoffStartedAtUTC).Seconds()
	result.HandoffWallSeconds = &handoff
	return result, nil
}

func verifyVagrantTransfer(transferDirectory, artifactDirectory string) (operationResult, error) {
	var result operationResult
	measurement, err := beginOperation(filepath.Dir(artifactDirectory))
	if err != nil {
		return result, err
	}
	defer measurement.cancel()
	contract, _, err := validateTransferPayload(transferDirectory)
	if err != nil {
		return result, err
	}
	if err := validateArtifactDirectory(artifactDirectory); err != nil {
		return result, err
	}
	actual, err := fileIdentity(filepath.Join(artifactDirectory, filepath.FromSlash(canonicalBoxPath)), canonicalBoxPath)
	if err != nil {
		return result, err
	}
	if actual != contract.Canonical {
		return result, errors.New("verified Vagrant box differs from the canonical identity")
	}
	if err := verifyPackerChecksum(filepath.Join(artifactDirectory, checksumFilename), actual); err != nil {
		return result, err
	}
	result, err = measurement.finish("verify-vagrant", contract, 0)
	if err != nil {
		return result, err
	}
	handoff := time.Since(contract.HandoffStartedAtUTC).Seconds()
	result.HandoffWallSeconds = &handoff
	return result, nil
}

func newManifest(preparedAt time.Time, canonical, transfer identity, archive archiveState) (manifest, error) {
	var result manifest
	pgzipPath, pgzipResolvedVersion := buildModule(pgzipModule)
	deflatePath, deflateResolvedVersion := buildModule(deflateModule)
	if pgzipPath != pgzipModule || pgzipResolvedVersion != pgzipVersion {
		return result, fmt.Errorf("artifact-transfer contains unsupported pgzip contract %s %s", pgzipPath, pgzipResolvedVersion)
	}
	if deflatePath != deflateModule || deflateResolvedVersion != deflateVersion {
		return result, fmt.Errorf("artifact-transfer contains unsupported DEFLATE contract %s %s", deflatePath, deflateResolvedVersion)
	}
	result.Schema = manifestSchema
	result.HandoffStartedAtUTC = preparedAt
	result.Canonical = canonical
	result.Transfer = transfer
	result.Archive = archive
	result.Producer.PackerVagrantPlugin = moduleContract{Module: packerPluginSource, Version: packerPluginVersion}
	result.Compression.Algorithm = "gzip"
	result.Compression.PGzip = moduleContract{Module: pgzipModule, Version: pgzipVersion}
	result.Compression.Deflate = moduleContract{Module: deflateModule, Version: deflateVersion}
	result.Compression.BlockBytes = packerBlockSize
	result.Compression.Level = flate.DefaultCompression
	result.Compression.Parallelism = compressionPolicy
	result.Compression.HeaderHex = gzipHeaderHex
	result.Reconstruction.Schedule = reconstructionName
	result.Reconstruction.HeaderBytes = tarBlockSize
	result.Reconstruction.FileWriteBytes = packerFileWriteSize
	result.Reconstruction.Padding = "explicit"
	result.Reconstruction.TrailerWrites = 2
	return result, nil
}

func validateTransferPayload(directory string) (manifest, string, error) {
	var result manifest
	entries, err := os.ReadDir(directory)
	if err != nil {
		return result, "", fmt.Errorf("read transfer payload: %w", err)
	}
	if len(entries) != 2 {
		return result, "", fmt.Errorf("transfer payload must contain exactly %s and %s; found %d entries", manifestFilename, rawTarFilename, len(entries))
	}
	expected := map[string]bool{manifestFilename: true, rawTarFilename: true}
	for _, entry := range entries {
		if !expected[entry.Name()] || entry.Type()&os.ModeSymlink != 0 || !entry.Type().IsRegular() {
			return result, "", fmt.Errorf("unexpected transfer payload entry %q", entry.Name())
		}
	}
	result, err = readManifest(filepath.Join(directory, manifestFilename))
	if err != nil {
		return result, "", err
	}
	rawPath := filepath.Join(directory, rawTarFilename)
	actual, err := fileIdentity(rawPath, rawTarFilename)
	if err != nil {
		return result, "", err
	}
	if actual != result.Transfer {
		return result, "", fmt.Errorf("raw-tar identity differs: expected %d bytes and %s, got %d bytes and %s", result.Transfer.Bytes, result.Transfer.SHA256, actual.Bytes, actual.SHA256)
	}
	archive, err := validateRawTar(rawPath)
	if err != nil {
		return result, "", err
	}
	if archive != result.Archive {
		return result, "", errors.New("raw-tar archive state differs from the manifest")
	}
	return result, rawPath, nil
}

func readManifest(filename string) (manifest, error) {
	var result manifest
	file, err := os.Open(filename)
	if err != nil {
		return result, fmt.Errorf("read transfer manifest: %w", err)
	}
	defer file.Close()
	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&result); err != nil {
		return result, fmt.Errorf("malformed transfer manifest: %w", err)
	}
	var extra any
	if err := decoder.Decode(&extra); !errors.Is(err, io.EOF) {
		return result, errors.New("malformed transfer manifest: trailing JSON value")
	}
	if err := validateManifest(result); err != nil {
		return result, err
	}
	return result, nil
}

func validateManifest(value manifest) error {
	if value.Schema != manifestSchema {
		return fmt.Errorf("unsupported transfer manifest schema %q", value.Schema)
	}
	if value.HandoffStartedAtUTC.IsZero() || value.HandoffStartedAtUTC.Location() != time.UTC {
		return errors.New("transfer manifest handoff_started_at_utc must be a UTC timestamp")
	}
	if err := validateIdentity(value.Canonical, canonicalBoxPath); err != nil {
		return fmt.Errorf("invalid canonical identity: %w", err)
	}
	if err := validateIdentity(value.Transfer, rawTarFilename); err != nil {
		return fmt.Errorf("invalid transfer identity: %w", err)
	}
	if value.Archive.Format != "tar" || value.Archive.Safety != archiveSafety || value.Archive.Entries < 1 || value.Archive.RegularFiles != value.Archive.Entries {
		return errors.New("unsupported or invalid archive contract")
	}
	if value.Producer.PackerVagrantPlugin != (moduleContract{Module: packerPluginSource, Version: packerPluginVersion}) {
		return errors.New("unsupported Packer Vagrant producer contract")
	}
	if value.Compression.Algorithm != "gzip" || value.Compression.PGzip != (moduleContract{Module: pgzipModule, Version: pgzipVersion}) || value.Compression.Deflate != (moduleContract{Module: deflateModule, Version: deflateVersion}) || value.Compression.BlockBytes != packerBlockSize || value.Compression.Level != flate.DefaultCompression || value.Compression.Parallelism != compressionPolicy || value.Compression.HeaderHex != gzipHeaderHex {
		return errors.New("unsupported compression contract")
	}
	if value.Reconstruction.Schedule != reconstructionName || value.Reconstruction.HeaderBytes != tarBlockSize || value.Reconstruction.FileWriteBytes != packerFileWriteSize || value.Reconstruction.Padding != "explicit" || value.Reconstruction.TrailerWrites != 2 {
		return errors.New("unsupported reconstruction contract")
	}
	module, version := buildModule(pgzipModule)
	if module != value.Compression.PGzip.Module || version != value.Compression.PGzip.Version {
		return fmt.Errorf("pgzip dependency mismatch: manifest requires %s %s, executable contains %s %s", value.Compression.PGzip.Module, value.Compression.PGzip.Version, module, version)
	}
	module, version = buildModule(deflateModule)
	if module != value.Compression.Deflate.Module || version != value.Compression.Deflate.Version {
		return fmt.Errorf("DEFLATE dependency mismatch: manifest requires %s %s, executable contains %s %s", value.Compression.Deflate.Module, value.Compression.Deflate.Version, module, version)
	}
	return nil
}

func validateIdentity(value identity, expectedPath string) error {
	if value.Path != expectedPath {
		return fmt.Errorf("expected path %q, got %q", expectedPath, value.Path)
	}
	if value.Bytes <= 0 {
		return errors.New("byte length must be positive")
	}
	if len(value.SHA256) != sha256.Size*2 || strings.ToLower(value.SHA256) != value.SHA256 {
		return errors.New("SHA-256 must be 64 lowercase hexadecimal characters")
	}
	if _, err := hex.DecodeString(value.SHA256); err != nil {
		return errors.New("SHA-256 must be 64 lowercase hexadecimal characters")
	}
	return nil
}

func decodeAndValidate(sourcePath, rawPath string) (identity, archiveState, error) {
	var transfer identity
	var archive archiveState
	source, err := os.Open(sourcePath)
	if err != nil {
		return transfer, archive, err
	}
	defer source.Close()
	reader, err := gzip.NewReader(source)
	if err != nil {
		return transfer, archive, fmt.Errorf("open canonical box gzip stream: %w", err)
	}
	raw, err := os.OpenFile(rawPath, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		reader.Close()
		return transfer, archive, err
	}
	hash := sha256.New()
	written, copyErr := io.Copy(io.MultiWriter(raw, hash), reader)
	readerErr := reader.Close()
	rawErr := raw.Close()
	if copyErr != nil {
		return transfer, archive, fmt.Errorf("decode canonical box: %w", copyErr)
	}
	if readerErr != nil {
		return transfer, archive, fmt.Errorf("validate canonical box gzip stream: %w", readerErr)
	}
	if rawErr != nil {
		return transfer, archive, rawErr
	}
	transfer = identity{Bytes: written, SHA256: hex.EncodeToString(hash.Sum(nil))}
	archive, err = validateRawTar(rawPath)
	if err != nil {
		return transfer, archive, err
	}
	return transfer, archive, nil
}

func validateRawTar(filename string) (archiveState, error) {
	var state archiveState
	state.Format = "tar"
	state.Safety = archiveSafety
	file, err := os.Open(filename)
	if err != nil {
		return state, err
	}
	if _, err := copyPackerTarWrites(io.Discard, file); err != nil {
		file.Close()
		return state, fmt.Errorf("invalid raw-tar write schedule: %w", err)
	}
	if err := file.Close(); err != nil {
		return state, err
	}

	file, err = os.Open(filename)
	if err != nil {
		return state, err
	}
	defer file.Close()
	reader := tar.NewReader(file)
	paths := make(map[string]string)
	for {
		header, nextErr := reader.Next()
		if errors.Is(nextErr, io.EOF) {
			break
		}
		if nextErr != nil {
			return state, fmt.Errorf("invalid tar archive: %w", nextErr)
		}
		name, pathErr := safeArchivePath(header.Name)
		if pathErr != nil {
			return state, pathErr
		}
		if header.Typeflag != tar.TypeReg && header.Typeflag != tar.TypeRegA {
			return state, fmt.Errorf("unsafe archive entry %q has unsupported type %d", header.Name, header.Typeflag)
		}
		key := strings.ToLower(name)
		if previous, exists := paths[key]; exists {
			return state, fmt.Errorf("ambiguous archive entries %q and %q resolve to the same path", previous, header.Name)
		}
		paths[key] = header.Name
		state.Entries++
		state.RegularFiles++
	}
	if state.Entries == 0 {
		return state, errors.New("Vagrant box tar archive is empty")
	}
	return state, nil
}

func safeArchivePath(name string) (string, error) {
	normalized := strings.ReplaceAll(name, `\`, "/")
	cleaned := path.Clean(normalized)
	if normalized == "" || cleaned == "." || path.IsAbs(cleaned) || cleaned == ".." || strings.HasPrefix(cleaned, "../") || (len(cleaned) >= 2 && cleaned[1] == ':') {
		return "", fmt.Errorf("unsafe archive path %q", name)
	}
	return cleaned, nil
}

func reconstructBox(rawPath, outputPath string) error {
	raw, err := os.Open(rawPath)
	if err != nil {
		return err
	}
	defer raw.Close()
	output, err := os.OpenFile(outputPath, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		return err
	}
	writer, err := pgzip.NewWriterLevel(output, flate.DefaultCompression)
	if err != nil {
		output.Close()
		return err
	}
	if err := writer.SetConcurrency(packerBlockSize, runtime.GOMAXPROCS(-1)); err != nil {
		writer.Close()
		output.Close()
		return err
	}
	_, copyErr := copyPackerTarWrites(writer, raw)
	writerErr := writer.Close()
	outputErr := output.Close()
	if copyErr != nil {
		return copyErr
	}
	if writerErr != nil {
		return writerErr
	}
	return outputErr
}

func copyPackerTarWrites(destination io.Writer, source io.Reader) (int64, error) {
	var total int64
	header := make([]byte, tarBlockSize)
	buffer := make([]byte, packerFileWriteSize)
	for {
		if _, err := io.ReadFull(source, header); err != nil {
			return total, err
		}
		if err := writeAll(destination, header); err != nil {
			return total, err
		}
		total += int64(len(header))
		if isZeroBlock(header) {
			if _, err := io.ReadFull(source, header); err != nil {
				return total, err
			}
			if !isZeroBlock(header) {
				return total, errors.New("tar trailer contains only one zero block")
			}
			if err := writeAll(destination, header); err != nil {
				return total, err
			}
			total += int64(len(header))
			var extra [1]byte
			if read, readErr := source.Read(extra[:]); read != 0 || !errors.Is(readErr, io.EOF) {
				return total, errors.New("raw tar contains bytes after its two-block trailer")
			}
			return total, nil
		}

		size, err := tarEntrySize(header)
		if err != nil {
			return total, err
		}
		remaining := size
		for remaining > 0 {
			chunk := int64(len(buffer))
			if remaining < chunk {
				chunk = remaining
			}
			if _, err := io.ReadFull(source, buffer[:chunk]); err != nil {
				return total, err
			}
			if err := writeAll(destination, buffer[:chunk]); err != nil {
				return total, err
			}
			total += chunk
			remaining -= chunk
		}
		padding := (tarBlockSize - size%tarBlockSize) % tarBlockSize
		if padding > 0 {
			if _, err := io.ReadFull(source, buffer[:padding]); err != nil {
				return total, err
			}
			if !isZeroBlock(buffer[:padding]) {
				return total, errors.New("tar entry padding contains non-zero bytes")
			}
			if err := writeAll(destination, buffer[:padding]); err != nil {
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
			return 0, errors.New("negative base-256 tar size is unsupported")
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
		if size > (math.MaxInt64-int64(digit-'0'))/8 {
			return 0, errors.New("octal tar size overflows int64")
		}
		size = size*8 + int64(digit-'0')
	}
	return size, nil
}

func validateGzipHeader(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	header := make([]byte, 10)
	if _, err := io.ReadFull(file, header); err != nil {
		return fmt.Errorf("read canonical box gzip header: %w", err)
	}
	if hex.EncodeToString(header) != gzipHeaderHex {
		return fmt.Errorf("unsupported canonical box gzip header %s", hex.EncodeToString(header))
	}
	return nil
}

func validateArtifactDirectory(directory string) error {
	entries, err := os.ReadDir(directory)
	if err != nil {
		return err
	}
	if len(entries) != 2 {
		return fmt.Errorf("reconstructed artifact must contain exactly %s and vagrant; found %d entries", checksumFilename, len(entries))
	}
	for _, entry := range entries {
		switch entry.Name() {
		case checksumFilename:
			if entry.Type()&os.ModeSymlink != 0 || !entry.Type().IsRegular() {
				return errors.New("reconstructed checksum is not a regular file")
			}
		case "vagrant":
			if !entry.IsDir() || entry.Type()&os.ModeSymlink != 0 {
				return errors.New("reconstructed vagrant path is not a directory")
			}
		default:
			return fmt.Errorf("unexpected reconstructed artifact entry %q", entry.Name())
		}
	}
	vagrantEntries, err := os.ReadDir(filepath.Join(directory, "vagrant"))
	if err != nil {
		return err
	}
	if len(vagrantEntries) != 1 || vagrantEntries[0].Name() != "vagrant.box" || vagrantEntries[0].Type()&os.ModeSymlink != 0 || !vagrantEntries[0].Type().IsRegular() {
		return errors.New("reconstructed vagrant directory must contain exactly one regular vagrant.box")
	}
	return nil
}

func verifyPackerChecksum(filename string, canonical identity) error {
	contents, err := os.ReadFile(filename)
	if err != nil {
		return fmt.Errorf("read Packer checksum: %w", err)
	}
	lines := strings.Split(strings.TrimSpace(string(contents)), "\n")
	if len(lines) != 1 {
		return errors.New("Packer checksum must contain exactly one entry")
	}
	fields := strings.Fields(lines[0])
	if len(fields) != 2 || fields[1] != "vagrant.box" {
		return errors.New("Packer checksum must identify exactly vagrant.box")
	}
	if strings.ToLower(fields[0]) != canonical.SHA256 {
		return fmt.Errorf("Packer checksum differs from canonical Vagrant box: expected %s, got %s", canonical.SHA256, fields[0])
	}
	return nil
}

func writeChecksum(filename string, canonical identity) error {
	return os.WriteFile(filename, []byte(canonical.SHA256+"\tvagrant.box\n"), 0o644)
}

func fileIdentity(filename, manifestPath string) (identity, error) {
	info, err := os.Lstat(filename)
	if err != nil {
		return identity{}, err
	}
	if !info.Mode().IsRegular() {
		return identity{}, fmt.Errorf("%s is not a regular file", filename)
	}
	file, err := os.Open(filename)
	if err != nil {
		return identity{}, err
	}
	defer file.Close()
	hash := sha256.New()
	read, err := io.Copy(hash, file)
	if err != nil {
		return identity{}, err
	}
	return identity{Path: manifestPath, Bytes: read, SHA256: hex.EncodeToString(hash.Sum(nil))}, nil
}

func requireAbsent(filename, description string) error {
	_, err := os.Lstat(filename)
	if err == nil {
		return fmt.Errorf("%s already exists: %s", description, filename)
	}
	if !os.IsNotExist(err) {
		return err
	}
	return nil
}

func isZeroBlock(block []byte) bool {
	return bytes.Equal(block, make([]byte, len(block)))
}

func writeAll(destination io.Writer, contents []byte) error {
	for len(contents) > 0 {
		written, err := destination.Write(contents)
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

func beginOperation(probePath string) (*operationMeasurement, error) {
	startedCPU, err := processCPU()
	if err != nil {
		return nil, fmt.Errorf("measure process CPU: %w", err)
	}
	disk, err := startDiskSampler(probePath)
	if err != nil {
		return nil, fmt.Errorf("measure temporary disk: %w", err)
	}
	return &operationMeasurement{startedAt: time.Now(), startedCPU: startedCPU, disk: disk}, nil
}

func (measurement *operationMeasurement) finish(operation string, contract manifest, stagingBytes int64) (operationResult, error) {
	finishedCPU, err := processCPU()
	if err != nil {
		return operationResult{}, fmt.Errorf("measure process CPU: %w", err)
	}
	disk, err := measurement.disk.finish()
	measurement.disk = nil
	if err != nil {
		return operationResult{}, fmt.Errorf("measure temporary disk: %w", err)
	}
	return operationResult{
		Schema:                 "artifact-transfer/operation/v1",
		Operation:              operation,
		Canonical:              contract.Canonical,
		Transfer:               contract.Transfer,
		Archive:                contract.Archive,
		OperationWallSeconds:   time.Since(measurement.startedAt).Seconds(),
		UserCPUSeconds:         finishedCPU.UserSeconds - measurement.startedCPU.UserSeconds,
		SystemCPUSeconds:       finishedCPU.SystemSeconds - measurement.startedCPU.SystemSeconds,
		StagingOutputBytes:     stagingBytes,
		DiskFreeBytesBefore:    disk.initialBytes,
		MinimumDiskFreeBytes:   disk.minimumBytes,
		PeakTemporaryDiskBytes: disk.peakBytes(),
	}, nil
}

func (measurement *operationMeasurement) cancel() {
	if measurement.disk != nil {
		_, _ = measurement.disk.finish()
		measurement.disk = nil
	}
}

func startDiskSampler(path string) (*diskSampler, error) {
	initial, err := freeDiskBytes(path)
	if err != nil {
		return nil, err
	}
	sampler := &diskSampler{initialBytes: initial, stop: make(chan struct{}), done: make(chan diskMeasurement, 1)}
	go func() {
		minimum := initial
		var sampleErr error
		ticker := time.NewTicker(250 * time.Millisecond)
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				available, err := freeDiskBytes(path)
				if err != nil && sampleErr == nil {
					sampleErr = err
				}
				if err == nil && available < minimum {
					minimum = available
				}
			case <-sampler.stop:
				available, err := freeDiskBytes(path)
				if err != nil && sampleErr == nil {
					sampleErr = err
				}
				if err == nil && available < minimum {
					minimum = available
				}
				sampler.done <- diskMeasurement{MinimumBytes: minimum, Err: sampleErr}
				return
			}
		}
	}()
	return sampler, nil
}

type completedDiskMeasurement struct {
	initialBytes uint64
	minimumBytes uint64
}

func (sampler *diskSampler) finish() (completedDiskMeasurement, error) {
	close(sampler.stop)
	result := <-sampler.done
	return completedDiskMeasurement{initialBytes: sampler.initialBytes, minimumBytes: result.MinimumBytes}, result.Err
}

func (measurement completedDiskMeasurement) peakBytes() uint64 {
	if measurement.minimumBytes >= measurement.initialBytes {
		return 0
	}
	return measurement.initialBytes - measurement.minimumBytes
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
