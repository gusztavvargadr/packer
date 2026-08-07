package main

import (
	"archive/tar"
	"bytes"
	"compress/flate"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/klauspost/pgzip"
)

func TestCanonicalizeHyperVVagrantRejectsUnsafeOrAmbiguousArchives(t *testing.T) {
	validVMCX := testEntry{name: "Virtual Machines/machine.vmcx", contents: "configuration"}
	boxXML := testEntry{name: hyperVBoxXMLPath, contents: "obsolete"}
	tests := []struct {
		name    string
		entries []testEntry
	}{
		{name: "missing box xml", entries: []testEntry{validVMCX}},
		{name: "missing vmcx", entries: []testEntry{boxXML}},
		{name: "vmcx outside virtual machines", entries: []testEntry{boxXML, {name: "machine.vmcx", contents: "configuration"}}},
		{name: "ambiguous vmcx", entries: []testEntry{boxXML, validVMCX, {name: "Virtual Machines/other.vmcx", contents: "other configuration"}}},
		{name: "ambiguous box xml", entries: []testEntry{boxXML, {name: "./Virtual Machines/box.xml", contents: "duplicate"}, validVMCX}},
		{name: "unsafe path", entries: []testEntry{boxXML, validVMCX, {name: "../escape", contents: "escape"}}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			source := newArtifactFixture(t, test.entries)
			originalBox := append([]byte(nil), source.box...)
			originalChecksum := append([]byte(nil), readFile(t, filepath.Join(source.directory, checksumFilename))...)

			if _, err := canonicalizeHyperVVagrant(source.directory); err == nil {
				t.Fatal("canonicalization unexpectedly accepted an unsafe or ambiguous archive")
			}
			if !bytes.Equal(readFile(t, filepath.Join(source.directory, canonicalBoxPath)), originalBox) {
				t.Fatal("failed canonicalization changed the original Vagrant box")
			}
			if !bytes.Equal(readFile(t, filepath.Join(source.directory, checksumFilename)), originalChecksum) {
				t.Fatal("failed canonicalization changed the original checksum")
			}
		})
	}
}

func TestCanonicalizeHyperVVagrantAcceptsSafeWindowsArchivePaths(t *testing.T) {
	source := newArtifactFixture(t, []testEntry{
		{name: hyperVBoxXMLPath, contents: "obsolete"},
		{name: `Virtual Machines\machine.vmcx`, contents: "configuration"},
		{name: `Virtual Hard Disks\disk.vhdx`, contents: "disk"},
	})

	result, err := canonicalizeHyperVVagrant(source.directory)
	if err != nil {
		t.Fatal(err)
	}
	if result.VMConfigurationPath != "Virtual Machines/machine.vmcx" {
		t.Fatalf("unexpected normalized VM configuration path: %q", result.VMConfigurationPath)
	}
}

func TestVagrantTransferReconstructsAndVerifiesCanonicalBoxByteExactly(t *testing.T) {
	source := newArtifactFixture(t, []testEntry{
		{name: "Vagrantfile", contents: "Vagrant.configure(\"2\")"},
		{name: "box.img", contents: string(bytes.Repeat([]byte("stable disk block\n"), 4096))},
		{name: "metadata.json", contents: `{"architecture":"amd64","provider":"libvirt"}`},
	})
	transfer := filepath.Join(t.TempDir(), "transfer")
	output := filepath.Join(t.TempDir(), "artifact")

	if _, err := prepareVagrantTransfer(source.directory, transfer); err != nil {
		t.Fatal(err)
	}
	if _, err := reconstructVagrantTransfer(transfer, output); err != nil {
		t.Fatal(err)
	}
	if _, err := verifyVagrantTransfer(transfer, output); err != nil {
		t.Fatal(err)
	}

	reconstructed, err := os.ReadFile(filepath.Join(output, canonicalBoxPath))
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(source.box, reconstructed) {
		t.Fatal("reconstructed vagrant.box differs from the canonical box")
	}
	checksum, err := os.ReadFile(filepath.Join(output, checksumFilename))
	if err != nil {
		t.Fatal(err)
	}
	expectedChecksum := source.sha256 + "\tvagrant.box\n"
	if string(checksum) != expectedChecksum {
		t.Fatalf("unexpected reconstructed checksum: %q", checksum)
	}
}

func TestPrepareVagrantTransferRejectsUnsafeOrAmbiguousArchives(t *testing.T) {
	tests := []struct {
		name    string
		entries []testEntry
	}{
		{name: "parent traversal", entries: []testEntry{{name: "../escape", contents: "escape"}}},
		{name: "absolute path", entries: []testEntry{{name: "/escape", contents: "escape"}}},
		{name: "windows absolute path", entries: []testEntry{{name: `C:\\escape`, contents: "escape"}}},
		{name: "symbolic link", entries: []testEntry{{name: "disk", link: "../escape", typeflag: tar.TypeSymlink}}},
		{name: "duplicate path", entries: []testEntry{{name: "disk", contents: "first"}, {name: "./disk", contents: "second"}}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			source := newArtifactFixture(t, test.entries)
			transfer := filepath.Join(t.TempDir(), "transfer")

			if _, err := prepareVagrantTransfer(source.directory, transfer); err == nil {
				t.Fatal("prepare unexpectedly accepted an unsafe or ambiguous archive")
			}
			if _, err := os.Stat(transfer); !os.IsNotExist(err) {
				t.Fatalf("failed preparation left a transfer payload: %v", err)
			}
		})
	}
}

func TestPrepareVagrantTransferRequiresThePackerChecksum(t *testing.T) {
	source := newArtifactFixture(t, []testEntry{{name: "metadata.json", contents: "{}"}})
	if err := os.WriteFile(filepath.Join(source.directory, checksumFilename), []byte("0000000000000000000000000000000000000000000000000000000000000000\tvagrant.box\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	_, err := prepareVagrantTransfer(source.directory, filepath.Join(t.TempDir(), "transfer"))
	if err == nil {
		t.Fatal("prepare unexpectedly accepted a checksum for different canonical bytes")
	}
}

func TestPrepareVagrantTransferRequiresTheExactChecksumPath(t *testing.T) {
	paths := []string{"../vagrant.box", "/tmp/vagrant.box", "other/vagrant.box"}
	for _, checksumPath := range paths {
		t.Run(checksumPath, func(t *testing.T) {
			source := newArtifactFixture(t, []testEntry{{name: "metadata.json", contents: "{}"}})
			checksum := source.sha256 + "\t" + checksumPath + "\n"
			writeFile(t, filepath.Join(source.directory, checksumFilename), []byte(checksum))

			if _, err := prepareVagrantTransfer(source.directory, filepath.Join(t.TempDir(), "transfer")); err == nil {
				t.Fatal("prepare unexpectedly accepted a checksum for a different path")
			}
		})
	}
}

func TestReconstructVagrantTransferFailsClosed(t *testing.T) {
	tests := []struct {
		name   string
		mutate func(*testing.T, string)
	}{
		{
			name: "unsupported manifest",
			mutate: func(t *testing.T, transfer string) {
				mutateManifest(t, transfer, func(value map[string]any) { value["schema"] = "artifact-transfer/vagrant-box/v2" })
			},
		},
		{
			name: "malformed manifest",
			mutate: func(t *testing.T, transfer string) {
				writeFile(t, filepath.Join(transfer, manifestFilename), []byte(`{"schema":`))
			},
		},
		{
			name: "corrupt raw tar",
			mutate: func(t *testing.T, transfer string) {
				path := filepath.Join(transfer, rawTarFilename)
				contents := readFile(t, path)
				contents[len(contents)/2] ^= 0xff
				writeFile(t, path, contents)
			},
		},
		{
			name: "ambiguous payload",
			mutate: func(t *testing.T, transfer string) {
				writeFile(t, filepath.Join(transfer, "unexpected.bin"), []byte("ambiguous"))
			},
		},
		{
			name: "wrong canonical identity",
			mutate: func(t *testing.T, transfer string) {
				mutateManifest(t, transfer, func(value map[string]any) {
					value["canonical"].(map[string]any)["sha256"] = "0000000000000000000000000000000000000000000000000000000000000000"
				})
			},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			source := newArtifactFixture(t, []testEntry{{name: "metadata.json", contents: "{}"}})
			transfer := filepath.Join(t.TempDir(), "transfer")
			if _, err := prepareVagrantTransfer(source.directory, transfer); err != nil {
				t.Fatal(err)
			}
			test.mutate(t, transfer)
			output := filepath.Join(t.TempDir(), "artifact")

			if _, err := reconstructVagrantTransfer(transfer, output); err == nil {
				t.Fatal("reconstruction unexpectedly accepted invalid input")
			}
			if _, err := os.Stat(output); !os.IsNotExist(err) {
				t.Fatalf("failed reconstruction left a canonical artifact: %v", err)
			}
		})
	}
}

type testEntry struct {
	name     string
	contents string
	link     string
	typeflag byte
}

type artifactFixture struct {
	directory string
	box       []byte
	sha256    string
}

func newArtifactFixture(t *testing.T, entries []testEntry) artifactFixture {
	t.Helper()
	var raw bytes.Buffer
	writer := tar.NewWriter(&raw)
	for _, entry := range entries {
		typeflag := entry.typeflag
		if typeflag == 0 {
			typeflag = tar.TypeReg
		}
		header := &tar.Header{Name: entry.name, Linkname: entry.link, Mode: 0o644, Size: int64(len(entry.contents)), Typeflag: typeflag}
		if typeflag != tar.TypeReg && typeflag != tar.TypeRegA {
			header.Size = 0
		}
		if err := writer.WriteHeader(header); err != nil {
			t.Fatal(err)
		}
		if header.Size > 0 {
			if _, err := writer.Write([]byte(entry.contents)); err != nil {
				t.Fatal(err)
			}
		}
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}

	var compressed bytes.Buffer
	gzipWriter, err := pgzip.NewWriterLevel(&compressed, flate.DefaultCompression)
	if err != nil {
		t.Fatal(err)
	}
	if err := gzipWriter.SetConcurrency(packerBlockSize, runtime.GOMAXPROCS(-1)); err != nil {
		t.Fatal(err)
	}
	if _, err := writePackerScheduleForTest(gzipWriter, bytes.NewReader(raw.Bytes())); err != nil {
		t.Fatal(err)
	}
	if err := gzipWriter.Close(); err != nil {
		t.Fatal(err)
	}

	directory := filepath.Join(t.TempDir(), "artifact")
	if err := os.MkdirAll(filepath.Join(directory, filepath.Dir(canonicalBoxPath)), 0o755); err != nil {
		t.Fatal(err)
	}
	box := compressed.Bytes()
	writeFile(t, filepath.Join(directory, canonicalBoxPath), box)
	hash := sha256.Sum256(box)
	digest := hex.EncodeToString(hash[:])
	writeFile(t, filepath.Join(directory, checksumFilename), []byte(digest+"\tvagrant.box\n"))
	return artifactFixture{directory: directory, box: append([]byte(nil), box...), sha256: digest}
}

func writePackerScheduleForTest(destination io.Writer, source io.Reader) (int64, error) {
	var total int64
	header := make([]byte, tarBlockSize)
	buffer := make([]byte, packerFileWriteSize)
	for {
		if _, err := io.ReadFull(source, header); err != nil {
			return total, err
		}
		if _, err := destination.Write(header); err != nil {
			return total, err
		}
		total += int64(len(header))
		if bytes.Equal(header, make([]byte, tarBlockSize)) {
			if _, err := io.ReadFull(source, header); err != nil {
				return total, err
			}
			if _, err := destination.Write(header); err != nil {
				return total, err
			}
			return total + int64(len(header)), nil
		}
		size, err := testTarSize(header)
		if err != nil {
			return total, err
		}
		written, err := io.CopyBuffer(destination, io.LimitReader(source, size), buffer)
		total += written
		if err != nil {
			return total, err
		}
		padding := (tarBlockSize - size%tarBlockSize) % tarBlockSize
		written, err = io.CopyN(destination, source, padding)
		total += written
		if err != nil {
			return total, err
		}
	}
}

func testTarSize(header []byte) (int64, error) {
	value := bytes.Trim(header[124:136], " \x00")
	var size int64
	for _, digit := range value {
		size = size*8 + int64(digit-'0')
	}
	return size, nil
}

func mutateManifest(t *testing.T, transfer string, mutate func(map[string]any)) {
	t.Helper()
	path := filepath.Join(transfer, manifestFilename)
	var value map[string]any
	if err := json.Unmarshal(readFile(t, path), &value); err != nil {
		t.Fatal(err)
	}
	mutate(value)
	contents, err := json.MarshalIndent(value, "", "  ")
	if err != nil {
		t.Fatal(err)
	}
	writeFile(t, path, append(contents, '\n'))
}

func readFile(t *testing.T, path string) []byte {
	t.Helper()
	contents, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	return contents
}

func writeFile(t *testing.T, path string, contents []byte) {
	t.Helper()
	if err := os.WriteFile(path, contents, 0o644); err != nil {
		t.Fatal(err)
	}
}
