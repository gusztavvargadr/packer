package main

import (
	"archive/tar"
	"compress/gzip"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"testing"
)

func TestVerifyVirtualBoxSparseBoxPreservesCanonicalFiles(t *testing.T) {
	directory := t.TempDir()
	box := filepath.Join(directory, "source.box")
	manifestPath := filepath.Join(directory, "producer.json")
	resultPath := filepath.Join(directory, "result.json")
	ovf := `<Disk ovf:format="http://www.vmware.com/interfaces/specifications/vmdk.html#sparse"/>`
	vmdk := "uncompressed sparse disk"
	nvram := "firmware state"
	writeTestBox(t, box, []testEntry{
		{name: "Vagrantfile", contents: "Vagrant.configure(\"2\")"},
		{name: "box.ovf", contents: ovf},
		{name: "fixture.nvram", contents: nvram},
		{name: "fixture.vmdk", contents: vmdk},
		{name: "metadata.json", contents: `{"architecture":"amd64","provider":"virtualbox"}`},
	})

	var producer virtualBoxProducerManifest
	producer.CanonicalDisk.FormatVariant = "dynamic default"
	producer.Canonical.Files = []virtualBoxCanonicalFile{
		testCanonicalFile("image/fixture.ovf", ovf),
		testCanonicalFile("image/fixture.vmdk", vmdk),
		testCanonicalFile("image/fixture.nvram", nvram),
	}
	if err := writeJSON(manifestPath, producer); err != nil {
		t.Fatal(err)
	}
	if err := verifyVirtualBoxSparseBox(box, manifestPath, "amd64", resultPath); err != nil {
		t.Fatal(err)
	}

	var result virtualBoxSparseBoxState
	contents, err := os.ReadFile(resultPath)
	if err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(contents, &result); err != nil {
		t.Fatal(err)
	}
	if result.Schema != "vagrant-transfer/virtualbox-sparse-box/v1" || result.Provider != "virtualbox" || len(result.Entries) != 5 {
		t.Fatalf("unexpected sparse box result: %#v", result)
	}
}

func testCanonicalFile(path, contents string) virtualBoxCanonicalFile {
	hash := sha256.Sum256([]byte(contents))
	return virtualBoxCanonicalFile{
		Path:         path,
		LogicalBytes: int64(len(contents)),
		SHA256:       hex.EncodeToString(hash[:]),
	}
}

func TestCanonicalizeHyperVRemovesBoxXMLAndPreservesVMCX(t *testing.T) {
	directory := t.TempDir()
	source := filepath.Join(directory, "source.box")
	canonical := filepath.Join(directory, "canonical.box")
	resultPath := filepath.Join(directory, "result.json")
	writeTestBox(t, source, []testEntry{
		{name: "metadata.json", contents: "{}"},
		{name: "Virtual Machines/example.vmcx", contents: "machine"},
		{name: "Virtual Machines/box.xml", contents: "obsolete"},
	})

	if err := canonicalizeHyperV(source, canonical, resultPath); err != nil {
		t.Fatal(err)
	}

	raw := filepath.Join(directory, "canonical.tar")
	decodeGzip(t, canonical, raw)
	archive, err := inspectTar(raw)
	if err != nil {
		t.Fatal(err)
	}
	if archive.VMCXFiles != 1 || archive.HyperVBoxXMLs != 0 || archive.RegularFiles != 2 {
		t.Fatalf("unexpected canonical archive state: %#v", archive)
	}

	var result canonicalizationState
	contents, err := os.ReadFile(resultPath)
	if err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(contents, &result); err != nil {
		t.Fatal(err)
	}
	if result.Schema != "vagrant-transfer/hyperv-canonical-box/v1" || len(result.Removed) != 1 || result.Canonical.Bytes == 0 {
		t.Fatalf("unexpected canonicalization result: %#v", result)
	}
}

func TestCanonicalizeHyperVRequiresVMCX(t *testing.T) {
	directory := t.TempDir()
	source := filepath.Join(directory, "source.box")
	writeTestBox(t, source, []testEntry{
		{name: "metadata.json", contents: "{}"},
		{name: "Virtual Machines/box.xml", contents: "obsolete"},
	})

	err := canonicalizeHyperV(source, filepath.Join(directory, "canonical.box"), filepath.Join(directory, "result.json"))
	if err == nil || err.Error() != "canonical archive contains no .vmcx file" {
		t.Fatalf("unexpected error: %v", err)
	}
}

type testEntry struct {
	name     string
	contents string
}

func writeTestBox(t *testing.T, output string, entries []testEntry) {
	t.Helper()
	rawPath := filepath.Join(t.TempDir(), "source.tar")
	raw, err := os.Create(rawPath)
	if err != nil {
		t.Fatal(err)
	}
	writer := tar.NewWriter(raw)
	for _, entry := range entries {
		header := &tar.Header{Name: entry.name, Mode: 0o644, Size: int64(len(entry.contents))}
		if err := writer.WriteHeader(header); err != nil {
			t.Fatal(err)
		}
		if _, err := writer.Write([]byte(entry.contents)); err != nil {
			t.Fatal(err)
		}
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}
	if err := raw.Close(); err != nil {
		t.Fatal(err)
	}
	if err := compressRawTar(rawPath, output); err != nil {
		t.Fatal(err)
	}
}

func decodeGzip(t *testing.T, source, output string) {
	t.Helper()
	in, err := os.Open(source)
	if err != nil {
		t.Fatal(err)
	}
	defer in.Close()
	reader, err := gzip.NewReader(in)
	if err != nil {
		t.Fatal(err)
	}
	defer reader.Close()
	out, err := os.Create(output)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := io.Copy(out, reader); err != nil {
		t.Fatal(err)
	}
	if err := out.Close(); err != nil {
		t.Fatal(err)
	}
}
