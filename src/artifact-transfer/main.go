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
	"sort"
	"strings"
	"time"

	"github.com/klauspost/pgzip"
)

const (
	manifestSchema                    = "artifact-transfer/vagrant-box/v1"
	manifestFilename                  = "manifest.json"
	rawTarFilename                    = "vagrant.raw.tar"
	canonicalBoxPath                  = "vagrant/vagrant.box"
	checksumFilename                  = "checksum.sha256"
	virtualBoxVagrantContractFilename = "virtualbox-vagrant.json"
	virtualBoxVagrantContractSchema   = "artifact-transfer/virtualbox-vagrant/v1"
	packerPluginSource                = "github.com/hashicorp/vagrant"
	packerPluginVersion               = "1.1.6"
	pgzipModule                       = "github.com/klauspost/pgzip"
	pgzipVersion                      = "v0.0.0-20151221113845-47f36e165cec"
	deflateModule                     = "github.com/klauspost/compress"
	deflateVersion                    = "v1.13.6"
	compressionPolicy                 = "runtime.GOMAXPROCS(-1)"
	reconstructionName                = "packer-vagrant-tar-writer/v1"
	gzipHeaderHex                     = "1f8b080000096e8800ff"
	archiveSafety                     = "validated"
	hyperVBoxXMLPath                  = "Virtual Machines/box.xml"
	packerBlockSize                   = 500000
	packerFileWriteSize               = 32 * 1024
	tarBlockSize                      = 512
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
	VirtualBox *virtualBoxVagrantContract `json:"virtualbox,omitempty"`
}

type virtualBoxNativeManifest struct {
	Schema        string `json:"schema"`
	CanonicalDisk struct {
		Format        string `json:"format"`
		FormatVariant string `json:"format_variant"`
	} `json:"canonical_disk"`
	Canonical struct {
		Files []identity `json:"files"`
	} `json:"canonical"`
}

type virtualBoxVagrantContract struct {
	Schema            string     `json:"schema"`
	GuestArchitecture string     `json:"guest_architecture"`
	Provider          string     `json:"provider"`
	DiskFormat        string     `json:"disk_format"`
	Box               identity   `json:"box"`
	Entries           []identity `json:"entries"`
}

type operationMetrics struct {
	OperationWallSeconds   float64 `json:"operation_wall_seconds"`
	UserCPUSeconds         float64 `json:"user_cpu_seconds"`
	SystemCPUSeconds       float64 `json:"system_cpu_seconds"`
	StagingOutputBytes     int64   `json:"staging_output_bytes"`
	DiskFreeBytesBefore    uint64  `json:"disk_free_bytes_before"`
	MinimumDiskFreeBytes   uint64  `json:"minimum_disk_free_bytes"`
	PeakTemporaryDiskBytes uint64  `json:"peak_temporary_disk_bytes"`
}

type operationResult struct {
	Schema             string                     `json:"schema"`
	Operation          string                     `json:"operation"`
	Canonical          identity                   `json:"canonical"`
	Transfer           identity                   `json:"transfer"`
	Archive            archiveState               `json:"archive"`
	VirtualBox         *virtualBoxVagrantContract `json:"virtualbox,omitempty"`
	HandoffWallSeconds *float64                   `json:"handoff_wall_seconds,omitempty"`
	operationMetrics
}

type canonicalizationResult struct {
	Schema              string       `json:"schema"`
	Operation           string       `json:"operation"`
	Source              identity     `json:"source"`
	Canonical           identity     `json:"canonical"`
	ArchiveBefore       archiveState `json:"archive_before"`
	ArchiveAfter        archiveState `json:"archive_after"`
	RemovedPath         string       `json:"removed_path"`
	VMConfigurationPath string       `json:"vm_configuration_path"`
	UnchangedEntries    int          `json:"unchanged_entries"`
	operationMetrics
}

type rawTarRecordIdentity struct {
	Path   string
	Bytes  int64
	SHA256 string
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
	if len(arguments) == 2 && arguments[0] == "canonicalize-hyperv-vagrant" {
		result, err := canonicalizeHyperVVagrant(arguments[1])
		if err != nil {
			return err
		}
		return printJSON(result)
	}
	if len(arguments) == 5 && arguments[0] == "verify-virtualbox-vagrant" {
		result, err := verifyVirtualBoxVagrantPackage(arguments[1], arguments[2], arguments[3], arguments[4])
		if err != nil {
			return err
		}
		return printJSON(result)
	}
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
	return errors.New("usage: artifact-transfer canonicalize-hyperv-vagrant <artifact-directory> | verify-virtualbox-vagrant <artifact-directory> <native-manifest> <guest-architecture> <contract-output> | prepare-vagrant <artifact-directory> <transfer-directory> | reconstruct-vagrant <transfer-directory> <artifact-directory> | verify-vagrant <transfer-directory> <artifact-directory>")
}

func verifyVirtualBoxVagrantPackage(artifactDirectory, nativeManifestPath, guestArchitecture, contractPath string) (virtualBoxVagrantContract, error) {
	var result virtualBoxVagrantContract
	contents, err := os.ReadFile(nativeManifestPath)
	if err != nil {
		return result, fmt.Errorf("read VirtualBox native manifest: %w", err)
	}
	var native virtualBoxNativeManifest
	if err := json.Unmarshal(contents, &native); err != nil {
		return result, fmt.Errorf("malformed VirtualBox native manifest: %w", err)
	}
	if native.Schema != "artifact-transfer/virtualbox-native/v1" {
		return result, fmt.Errorf("unsupported VirtualBox native manifest schema %q", native.Schema)
	}
	if native.CanonicalDisk.Format != "VMDK" || native.CanonicalDisk.FormatVariant != "dynamic default" {
		return result, fmt.Errorf("expected canonical monolithic-sparse VMDK, found %s %s", native.CanonicalDisk.Format, native.CanonicalDisk.FormatVariant)
	}
	expected, err := virtualBoxPackageEntries(native.Canonical.Files)
	if err != nil {
		return result, err
	}
	result = virtualBoxVagrantContract{
		Schema:            virtualBoxVagrantContractSchema,
		GuestArchitecture: guestArchitecture,
		Provider:          "virtualbox",
		DiskFormat:        "monolithic-sparse",
		Entries:           expected,
	}
	boxPath := filepath.Join(artifactDirectory, filepath.FromSlash(canonicalBoxPath))
	result.Box, err = fileIdentity(boxPath, canonicalBoxPath)
	if err != nil {
		return result, fmt.Errorf("read VirtualBox Vagrant box: %w", err)
	}
	result.Entries, err = verifyVirtualBoxVagrantBox(boxPath, result)
	if err != nil {
		return result, err
	}
	if err := validateVirtualBoxVagrantContract(result); err != nil {
		return result, err
	}
	if err := verifyPackerChecksum(filepath.Join(artifactDirectory, checksumFilename), result.Box); err != nil {
		return result, err
	}
	if err := requireAbsent(contractPath, "VirtualBox Vagrant contract"); err != nil {
		return result, err
	}
	if err := writeJSON(contractPath, result); err != nil {
		return result, err
	}
	return result, nil
}

func virtualBoxPackageEntries(files []identity) ([]identity, error) {
	if len(files) != 3 {
		return nil, fmt.Errorf("VirtualBox native manifest must contain exactly one OVF, NVRAM, and VMDK; found %d files", len(files))
	}
	entries := make([]identity, 0, 5)
	exts := make(map[string]bool)
	paths := make(map[string]bool)
	for _, file := range files {
		if err := validateIdentity(file, file.Path); err != nil {
			return nil, fmt.Errorf("invalid canonical VirtualBox file identity: %w", err)
		}
		extension := strings.ToLower(filepath.Ext(file.Path))
		if extension != ".ovf" && extension != ".nvram" && extension != ".vmdk" {
			return nil, fmt.Errorf("unexpected canonical VirtualBox file %q", file.Path)
		}
		if exts[extension] {
			return nil, fmt.Errorf("VirtualBox native manifest contains more than one %s file", extension)
		}
		exts[extension] = true
		name := filepath.Base(file.Path)
		if extension == ".ovf" {
			name = "box.ovf"
		}
		key := strings.ToLower(name)
		if paths[key] {
			return nil, fmt.Errorf("ambiguous canonical VirtualBox package path %q", name)
		}
		paths[key] = true
		file.Path = name
		entries = append(entries, file)
	}
	if !exts[".ovf"] || !exts[".nvram"] || !exts[".vmdk"] {
		return nil, errors.New("VirtualBox native manifest must contain exactly one OVF, NVRAM, and VMDK")
	}
	return entries, nil
}

func verifyVirtualBoxVagrantBox(boxPath string, contract virtualBoxVagrantContract) ([]identity, error) {
	if contract.Schema != virtualBoxVagrantContractSchema || contract.Provider != "virtualbox" || contract.DiskFormat != "monolithic-sparse" {
		return nil, errors.New("unsupported VirtualBox Vagrant package contract")
	}
	if contract.GuestArchitecture != "amd64" && contract.GuestArchitecture != "arm64" {
		return nil, fmt.Errorf("unsupported VirtualBox Vagrant guest architecture %q", contract.GuestArchitecture)
	}
	box, err := os.Open(boxPath)
	if err != nil {
		return nil, err
	}
	defer box.Close()
	reader, err := gzip.NewReader(box)
	if err != nil {
		return nil, fmt.Errorf("open VirtualBox Vagrant box: %w", err)
	}
	defer reader.Close()

	expected := make(map[string]identity, len(contract.Entries))
	for _, entry := range contract.Entries {
		if err := validateIdentity(entry, entry.Path); err != nil {
			return nil, fmt.Errorf("invalid expected VirtualBox Vagrant entry identity: %w", err)
		}
		expected[strings.ToLower(entry.Path)] = entry
	}
	actual := make(map[string]identity, len(contract.Entries))
	var ovfContents, metadataContents bytes.Buffer
	tarReader := tar.NewReader(reader)
	for {
		header, nextErr := tarReader.Next()
		if errors.Is(nextErr, io.EOF) {
			break
		}
		if nextErr != nil {
			return nil, fmt.Errorf("read VirtualBox Vagrant box: %w", nextErr)
		}
		name, pathErr := safeArchivePath(header.Name)
		if pathErr != nil {
			return nil, pathErr
		}
		if header.Typeflag != tar.TypeReg && header.Typeflag != tar.TypeRegA {
			return nil, fmt.Errorf("unsafe archive entry %q has unsupported type %d", header.Name, header.Typeflag)
		}
		key := strings.ToLower(name)
		if _, exists := actual[key]; exists {
			return nil, fmt.Errorf("duplicate or ambiguous VirtualBox Vagrant box entry %q", header.Name)
		}
		hash := sha256.New()
		output := io.Writer(hash)
		if key == "box.ovf" {
			output = io.MultiWriter(hash, &ovfContents)
		}
		if key == "metadata.json" {
			output = io.MultiWriter(hash, &metadataContents)
		}
		written, copyErr := io.Copy(output, tarReader)
		if copyErr != nil {
			return nil, copyErr
		}
		actual[key] = identity{Path: name, Bytes: written, SHA256: hex.EncodeToString(hash.Sum(nil))}
	}
	if len(actual) != 5 {
		return nil, fmt.Errorf("VirtualBox Vagrant box contains %d entries, expected 5", len(actual))
	}
	for key, wanted := range expected {
		got, exists := actual[key]
		if !exists || got != wanted {
			return nil, fmt.Errorf("VirtualBox Vagrant box entry %q differs from the canonical contract", wanted.Path)
		}
	}
	if !bytes.Contains(ovfContents.Bytes(), []byte("#sparse")) || bytes.Contains(ovfContents.Bytes(), []byte("#streamOptimized")) {
		return nil, errors.New("box.ovf does not exclusively declare a sparse VMDK")
	}
	var metadata map[string]string
	if err := json.Unmarshal(metadataContents.Bytes(), &metadata); err != nil {
		return nil, fmt.Errorf("malformed VirtualBox metadata.json: %w", err)
	}
	if len(metadata) != 2 || metadata["provider"] != contract.Provider || metadata["architecture"] != contract.GuestArchitecture {
		return nil, fmt.Errorf("VirtualBox metadata.json differs from the provider and guest architecture contract: %v", metadata)
	}
	entries := make([]identity, 0, len(actual))
	for _, entry := range actual {
		entries = append(entries, entry)
	}
	sort.Slice(entries, func(left, right int) bool { return entries[left].Path < entries[right].Path })
	return entries, nil
}

func validateVirtualBoxVagrantContract(contract virtualBoxVagrantContract) error {
	if contract.Schema != virtualBoxVagrantContractSchema || contract.Provider != "virtualbox" || contract.DiskFormat != "monolithic-sparse" {
		return errors.New("unsupported VirtualBox Vagrant package contract")
	}
	if contract.GuestArchitecture != "amd64" && contract.GuestArchitecture != "arm64" {
		return fmt.Errorf("unsupported VirtualBox Vagrant guest architecture %q", contract.GuestArchitecture)
	}
	if err := validateIdentity(contract.Box, canonicalBoxPath); err != nil {
		return fmt.Errorf("invalid VirtualBox Vagrant box identity: %w", err)
	}
	if len(contract.Entries) != 5 {
		return errors.New("VirtualBox Vagrant package contract must contain exactly five entries")
	}
	required := map[string]bool{"Vagrantfile": true, "box.ovf": true, "metadata.json": true}
	exts := map[string]bool{".nvram": false, ".vmdk": false}
	seen := make(map[string]bool)
	for _, entry := range contract.Entries {
		if err := validateIdentity(entry, entry.Path); err != nil {
			return fmt.Errorf("invalid VirtualBox Vagrant entry identity: %w", err)
		}
		if entry.Path != filepath.Base(entry.Path) {
			return fmt.Errorf("VirtualBox Vagrant entry must be at the archive root: %q", entry.Path)
		}
		key := strings.ToLower(entry.Path)
		if seen[key] {
			return fmt.Errorf("ambiguous VirtualBox Vagrant package entry %q", entry.Path)
		}
		seen[key] = true
		if required[entry.Path] {
			continue
		}
		extension := strings.ToLower(filepath.Ext(entry.Path))
		if _, exists := exts[extension]; !exists || exts[extension] {
			return fmt.Errorf("unexpected VirtualBox Vagrant package entry %q", entry.Path)
		}
		exts[extension] = true
	}
	for name := range required {
		if !seen[strings.ToLower(name)] {
			return fmt.Errorf("VirtualBox Vagrant package contract is missing %q", name)
		}
	}
	if !exts[".nvram"] || !exts[".vmdk"] {
		return errors.New("VirtualBox Vagrant package contract is missing its NVRAM or VMDK")
	}
	return nil
}

func canonicalizeHyperVVagrant(artifactDirectory string) (canonicalizationResult, error) {
	var result canonicalizationResult
	measurement, err := beginOperation(artifactDirectory)
	if err != nil {
		return result, err
	}
	defer measurement.cancel()

	boxPath := filepath.Join(artifactDirectory, filepath.FromSlash(canonicalBoxPath))
	checksumPath := filepath.Join(artifactDirectory, checksumFilename)
	sourceIdentity, err := fileIdentity(boxPath, canonicalBoxPath)
	if err != nil {
		return result, fmt.Errorf("read packaged Hyper-V Vagrant box: %w", err)
	}
	if err := verifyPackerChecksum(checksumPath, sourceIdentity); err != nil {
		return result, err
	}
	if err := validateGzipHeader(boxPath); err != nil {
		return result, err
	}

	staging, err := os.MkdirTemp(artifactDirectory, ".hyperv-canonicalization-*")
	if err != nil {
		return result, err
	}
	defer os.RemoveAll(staging)
	sourceRawPath := filepath.Join(staging, "source.raw.tar")
	_, archiveBefore, err := decodeAndValidate(boxPath, sourceRawPath)
	if err != nil {
		return result, err
	}
	canonicalRawPath := filepath.Join(staging, "canonical.raw.tar")
	proof, err := canonicalizeHyperVRawTar(sourceRawPath, canonicalRawPath)
	if err != nil {
		return result, err
	}
	archiveAfter, err := validateRawTar(canonicalRawPath)
	if err != nil {
		return result, fmt.Errorf("validate canonical Hyper-V archive: %w", err)
	}

	canonicalBoxPathname := filepath.Join(staging, "vagrant.box")
	if err := reconstructBox(canonicalRawPath, canonicalBoxPathname); err != nil {
		return result, fmt.Errorf("rebuild canonical Hyper-V Vagrant box: %w", err)
	}
	if err := validateGzipHeader(canonicalBoxPathname); err != nil {
		return result, err
	}
	canonicalIdentity, err := fileIdentity(canonicalBoxPathname, canonicalBoxPath)
	if err != nil {
		return result, err
	}
	canonicalChecksumPath := filepath.Join(staging, checksumFilename)
	if err := writeChecksum(canonicalChecksumPath, canonicalIdentity); err != nil {
		return result, err
	}
	if err := verifyPackerChecksum(canonicalChecksumPath, canonicalIdentity); err != nil {
		return result, fmt.Errorf("verify staged canonical Hyper-V checksum: %w", err)
	}

	metrics, err := measurement.finishMetrics(canonicalIdentity.Bytes)
	if err != nil {
		return result, err
	}
	result = canonicalizationResult{
		Schema:              "artifact-transfer/hyperv-canonicalization/v1",
		Operation:           "canonicalize-hyperv-vagrant",
		Source:              sourceIdentity,
		Canonical:           canonicalIdentity,
		ArchiveBefore:       archiveBefore,
		ArchiveAfter:        archiveAfter,
		RemovedPath:         hyperVBoxXMLPath,
		VMConfigurationPath: proof.vmConfigurationPath,
		UnchangedEntries:    len(proof.unchangedEntries),
		operationMetrics:    metrics,
	}
	if err := replaceCanonicalVagrantArtifact(boxPath, checksumPath, canonicalBoxPathname, canonicalChecksumPath, staging); err != nil {
		return canonicalizationResult{}, err
	}
	return result, nil
}

type hyperVCanonicalizationProof struct {
	vmConfigurationPath string
	unchangedEntries    []rawTarRecordIdentity
}

func canonicalizeHyperVRawTar(sourcePath, outputPath string) (hyperVCanonicalizationProof, error) {
	var proof hyperVCanonicalizationProof
	source, err := os.Open(sourcePath)
	if err != nil {
		return proof, err
	}
	defer source.Close()
	output, err := os.OpenFile(outputPath, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		return proof, err
	}
	records, err := copyRawTarRecords(output, source, hyperVBoxXMLPath)
	closeErr := output.Close()
	if err != nil {
		return proof, err
	}
	if closeErr != nil {
		return proof, closeErr
	}

	removed := 0
	var expected []rawTarRecordIdentity
	for _, record := range records {
		if record.Path == hyperVBoxXMLPath {
			removed++
			continue
		}
		expected = append(expected, record)
		if path.Dir(record.Path) == "Virtual Machines" && path.Ext(record.Path) == ".vmcx" {
			if proof.vmConfigurationPath != "" {
				return proof, fmt.Errorf("ambiguous Hyper-V VM configurations %q and %q", proof.vmConfigurationPath, record.Path)
			}
			proof.vmConfigurationPath = record.Path
		}
	}
	if removed != 1 {
		return proof, fmt.Errorf("Hyper-V archive must contain exactly %q; found %d", hyperVBoxXMLPath, removed)
	}
	if proof.vmConfigurationPath == "" {
		return proof, errors.New("Hyper-V archive must contain exactly one .vmcx in Virtual Machines")
	}

	canonical, err := os.Open(outputPath)
	if err != nil {
		return proof, err
	}
	actual, scanErr := copyRawTarRecords(io.Discard, canonical, "")
	closeErr = canonical.Close()
	if scanErr != nil {
		return proof, scanErr
	}
	if closeErr != nil {
		return proof, closeErr
	}
	if len(actual) != len(expected) {
		return proof, errors.New("canonical Hyper-V archive changed the number of preserved entries")
	}
	for index := range expected {
		if actual[index] != expected[index] {
			return proof, fmt.Errorf("canonical Hyper-V archive changed preserved entry %q", expected[index].Path)
		}
	}
	proof.unchangedEntries = actual
	return proof, nil
}

func copyRawTarRecords(destination io.Writer, source io.Reader, skippedPath string) ([]rawTarRecordIdentity, error) {
	var records []rawTarRecordIdentity
	header := make([]byte, tarBlockSize)
	buffer := make([]byte, packerFileWriteSize)
	for {
		if _, err := io.ReadFull(source, header); err != nil {
			return records, err
		}
		if isZeroBlock(header) {
			if err := writeAll(destination, header); err != nil {
				return records, err
			}
			if _, err := io.ReadFull(source, header); err != nil {
				return records, err
			}
			if !isZeroBlock(header) {
				return records, errors.New("tar trailer contains only one zero block")
			}
			if err := writeAll(destination, header); err != nil {
				return records, err
			}
			var extra [1]byte
			if read, readErr := source.Read(extra[:]); read != 0 || !errors.Is(readErr, io.EOF) {
				return records, errors.New("raw tar contains bytes after its two-block trailer")
			}
			return records, nil
		}

		name, err := rawTarHeaderPath(header)
		if err != nil {
			return records, err
		}
		if header[156] != tar.TypeReg && header[156] != tar.TypeRegA {
			return records, fmt.Errorf("unsafe raw archive entry %q has unsupported type %d", name, header[156])
		}
		size, err := tarEntrySize(header)
		if err != nil {
			return records, err
		}
		writeRecord := name != skippedPath
		hash := sha256.New()
		if _, err := hash.Write(header); err != nil {
			return records, err
		}
		if writeRecord {
			if err := writeAll(destination, header); err != nil {
				return records, err
			}
		}
		recordBytes := int64(len(header))
		remaining := size
		for remaining > 0 {
			chunk := int64(len(buffer))
			if remaining < chunk {
				chunk = remaining
			}
			contents := buffer[:int(chunk)]
			if _, err := io.ReadFull(source, contents); err != nil {
				return records, err
			}
			if _, err := hash.Write(contents); err != nil {
				return records, err
			}
			if writeRecord {
				if err := writeAll(destination, contents); err != nil {
					return records, err
				}
			}
			recordBytes += chunk
			remaining -= chunk
		}
		padding := (tarBlockSize - size%tarBlockSize) % tarBlockSize
		if padding > 0 {
			contents := buffer[:int(padding)]
			if _, err := io.ReadFull(source, contents); err != nil {
				return records, err
			}
			if !isZeroBlock(contents) {
				return records, errors.New("tar entry padding contains non-zero bytes")
			}
			if _, err := hash.Write(contents); err != nil {
				return records, err
			}
			if writeRecord {
				if err := writeAll(destination, contents); err != nil {
					return records, err
				}
			}
			recordBytes += padding
		}
		records = append(records, rawTarRecordIdentity{Path: name, Bytes: recordBytes, SHA256: hex.EncodeToString(hash.Sum(nil))})
	}
}

func rawTarHeaderPath(header []byte) (string, error) {
	name := strings.TrimRight(string(header[0:100]), "\x00")
	prefix := strings.TrimRight(string(header[345:500]), "\x00")
	if prefix != "" {
		name = prefix + "/" + name
	}
	if strings.ContainsRune(name, '\x00') {
		return "", errors.New("tar header path contains embedded NUL")
	}
	normalized := strings.ReplaceAll(name, `\`, "/")
	cleaned, err := safeArchivePath(name)
	if err != nil {
		return "", err
	}
	if cleaned != normalized {
		return "", fmt.Errorf("ambiguous archive path %q is not canonical after separator normalization", name)
	}
	return cleaned, nil
}

func replaceCanonicalVagrantArtifact(boxPath, checksumPath, newBoxPath, newChecksumPath, staging string) error {
	backupBoxPath := filepath.Join(staging, "packaged-vagrant.box")
	backupChecksumPath := filepath.Join(staging, "packaged-checksum.sha256")
	if err := os.Rename(boxPath, backupBoxPath); err != nil {
		return fmt.Errorf("stage packaged Hyper-V Vagrant box: %w", err)
	}
	if err := os.Rename(checksumPath, backupChecksumPath); err != nil {
		return errors.Join(
			fmt.Errorf("stage packaged Hyper-V checksum: %w", err),
			func() error {
				if rollbackErr := os.Rename(backupBoxPath, boxPath); rollbackErr != nil {
					return fmt.Errorf("restore packaged Hyper-V Vagrant box: %w", rollbackErr)
				}
				return nil
			}(),
		)
	}
	rollbackOriginals := func(removeCanonical bool) error {
		var rollbackErrors []error
		if removeCanonical {
			if err := os.Remove(boxPath); err != nil && !os.IsNotExist(err) {
				rollbackErrors = append(rollbackErrors, fmt.Errorf("remove incomplete canonical Hyper-V Vagrant box: %w", err))
			}
		}
		if err := os.Rename(backupBoxPath, boxPath); err != nil {
			rollbackErrors = append(rollbackErrors, fmt.Errorf("restore packaged Hyper-V Vagrant box: %w", err))
		}
		if err := os.Rename(backupChecksumPath, checksumPath); err != nil {
			rollbackErrors = append(rollbackErrors, fmt.Errorf("restore packaged Hyper-V checksum: %w", err))
		}
		return errors.Join(rollbackErrors...)
	}
	if err := os.Rename(newBoxPath, boxPath); err != nil {
		return errors.Join(fmt.Errorf("promote canonical Hyper-V Vagrant box: %w", err), rollbackOriginals(false))
	}
	if err := os.Rename(newChecksumPath, checksumPath); err != nil {
		return errors.Join(fmt.Errorf("promote canonical Hyper-V checksum: %w", err), rollbackOriginals(true))
	}
	return nil
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
	virtualBox, err := readOptionalVirtualBoxVagrantContract(artifactDirectory)
	if err != nil {
		return result, err
	}
	if virtualBox != nil {
		if canonical != virtualBox.Box {
			return result, errors.New("VirtualBox Vagrant package contract identifies different canonical box bytes")
		}
		if _, err := verifyVirtualBoxVagrantBox(canonicalPath, *virtualBox); err != nil {
			return result, err
		}
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
	contract.VirtualBox = virtualBox
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
	if contract.VirtualBox != nil {
		if _, err := verifyVirtualBoxVagrantBox(filepath.Join(artifactDirectory, filepath.FromSlash(canonicalBoxPath)), *contract.VirtualBox); err != nil {
			return result, err
		}
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
	if value.VirtualBox != nil {
		if err := validateVirtualBoxVagrantContract(*value.VirtualBox); err != nil {
			return err
		}
		if value.VirtualBox.Box != value.Canonical {
			return errors.New("VirtualBox Vagrant package contract differs from the canonical transfer identity")
		}
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

func readOptionalVirtualBoxVagrantContract(artifactDirectory string) (*virtualBoxVagrantContract, error) {
	filename := filepath.Join(artifactDirectory, virtualBoxVagrantContractFilename)
	info, err := os.Lstat(filename)
	if os.IsNotExist(err) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if !info.Mode().IsRegular() {
		return nil, errors.New("VirtualBox Vagrant package contract is not a regular file")
	}
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()
	var contract virtualBoxVagrantContract
	if err := decoder.Decode(&contract); err != nil {
		return nil, fmt.Errorf("malformed VirtualBox Vagrant package contract: %w", err)
	}
	var extra any
	if err := decoder.Decode(&extra); !errors.Is(err, io.EOF) {
		return nil, errors.New("malformed VirtualBox Vagrant package contract: trailing JSON value")
	}
	if err := validateVirtualBoxVagrantContract(contract); err != nil {
		return nil, err
	}
	return &contract, nil
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
	metrics, err := measurement.finishMetrics(stagingBytes)
	if err != nil {
		return operationResult{}, err
	}
	return operationResult{
		Schema:           "artifact-transfer/operation/v1",
		Operation:        operation,
		Canonical:        contract.Canonical,
		Transfer:         contract.Transfer,
		Archive:          contract.Archive,
		VirtualBox:       contract.VirtualBox,
		operationMetrics: metrics,
	}, nil
}

func (measurement *operationMeasurement) finishMetrics(stagingBytes int64) (operationMetrics, error) {
	finishedCPU, err := processCPU()
	if err != nil {
		return operationMetrics{}, fmt.Errorf("measure process CPU: %w", err)
	}
	disk, err := measurement.disk.finish()
	measurement.disk = nil
	if err != nil {
		return operationMetrics{}, fmt.Errorf("measure temporary disk: %w", err)
	}
	return operationMetrics{
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
