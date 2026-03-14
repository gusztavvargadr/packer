# Packer VM Builder - AI Agent Guidelines

## Project Overview
This repository uses HashiCorp Packer with Chef provisioning to automate building customizable Windows and Ubuntu VM images and Vagrant boxes across multiple hypervisors (VirtualBox, VMware, Hyper-V, QEMU) and cloud providers (AWS EC2).

## Architecture

**Directory Structure:**
- `src/{ubuntu,windows}/` - Platform-specific Packer HCL templates with modular provider configurations
- `samples/` - Ready-to-use build configurations per image variant (e.g., `ubuntu-server/`, `windows-11/`)
- `lib/gusztavvargadr/chef/` - Shared Chef Policyfile base definitions
- `src/{platform}/chef/` - Platform-specific Chef cookbooks for provisioning
- `src/{platform}/boot/` - Unattended installation scripts (cloud-init for Ubuntu, autounattend.xml for Windows)
- `artifacts/` - Build outputs (images, vagrant boxes, manifests)

**Key Files:**
- [src/ubuntu/core.pkr.hcl](src/ubuntu/core.pkr.hcl) - Base Packer variables (author, version, image metadata)
- [build.cake](build.cake) - CakeBuild orchestration script for multi-stage Packer builds
- [samples/ubuntu-server/images.pkrvars.hcl](samples/ubuntu-server/images.pkrvars.hcl) - Example image configuration pattern

## Build System

**Build Command Pattern:**
```bash
dotnet cake build.cake --target={TARGET} --configuration={SAMPLE}/{IMAGE}/{PROVIDER}/{BUILD} --version={VERSION}
```

**Configuration parameters:**
- `SAMPLE`: e.g., `ubuntu-server`, `windows-11`, `development-ubuntu`
- `IMAGE`: e.g., `2404-lts` (Ubuntu), `25h2-enterprise` (Windows)
- `PROVIDER`: `virtualbox`, `vmware`, `hyperv`, `qemu`, `amazon-ebs`
- `BUILD`: `native` (ISO-based), `vagrant` (box-based)
- `TARGET`: `init`, `restore`, `build`, `test`, `publish`, `clean` (or `default` = init→restore→build→test)

**Example builds:**
```bash
# Full pipeline for Ubuntu Server via VirtualBox
dotnet cake build.cake --configuration=ubuntu-server/2404-lts/virtualbox/native

# Build only for Windows 11
dotnet cake build.cake --target=build --configuration=windows-11/25h2-enterprise/hyperv/native

# Clean artifacts
dotnet cake build.cake --target=clean
```

## Code Patterns

**Packer File Organization:**
- `source.*.pkr.hcl` - Provider-specific source blocks (virtualbox, vmware, hyperv, qemu, amazon-ebs)
- `source.core.pkr.hcl` - Shared locals (VM naming, memory defaults ~4-8GB, communicator settings)
- `build.native.pkr.hcl` - ISO-based native builds with 2-stage provisioning (restore, build)
- `build.vagrant.pkr.hcl` - Vagrant box building from native images with test stage

**Image Configuration Pattern** (`images.pkrvars.hcl`):
```hcl
images = {
  "2404-lts" = {
    core = { image_description = "Ubuntu Server 24.04 LTS" }
    native = { source_iso_checksum = "sha256:...", source_iso_url_remote = "https://..." }
    vagrant = { box_alias = "ubuntu-server" }
    virtualbox = { guest_os_type = "Ubuntu_64" }
    vmware = { guest_os_type = "ubuntu-64" }
  }
}
```

**Build Stage Structure:**
Each build type follows four stages: `{build}-{stage}.*`
1. `restore` - Export Chef cookbooks locally
2. `build` - Initialize host, provision with Chef
3. `test` - Validate with Vagrant
4. `publish` - Post-processors (manifest, checksum, vagrant box)

**Chef Provisioning Pattern:**
- Ubuntu uses bash scripts: `initialize.sh` (install Chef), `apply.sh` (run chef-client)
- Windows uses PowerShell: `initialize.ps1`, `apply.ps1`
- Policyfile.rb pattern: inherit from platform base, add sample-specific run_list

**Provider Conventions:**
- VirtualBox: EFI firmware, VMSVGA graphics (128MB), no guest additions
- VMware: Minimal provider config with provider-specific guest_os_type
- Hyper-V: Gen 2 VMs, config v10.0, EFI enabled
- QEMU: KVM acceleration, q35 machine, EFI with OVMF firmware
- Amazon EBS: Spot pricing, t3.xlarge, gp3 EBS (31GB default)

## Provisioning & Naming

**Variables & Locals** ([src/ubuntu/core.pkr.hcl](src/ubuntu/core.pkr.hcl)):
- Input: `author` (default: "gusztavvargadr"), `version` (default: "2601"), `image`, `provider`, `build`
- Computed: `image_name = "${basename(path.cwd)}/${image}"`, `image_version = custom_or_default.version`
- Artifact path: `${artifacts_directory}/${image_name}/${provider}/${build}`

**Naming Conventions:**
- Image IDs: Version + release (e.g., `2404-lts`, `25h2-enterprise`)
- VM names: `{image}-{timestamp}` (e.g., `ubuntu-server-2404-lts-250214-093045`)
- Vagrant boxes: `{author}/{image}` (e.g., `gusztavvargadr/ubuntu-server`)

## Dependencies

**Required Tools:**
- Packer: ~> 1.14.2
- Chef Workstation (for Policyfile operations)
- .NET SDK (for Cake build script)
- Vagrant: for box building and testing
- Hypervisor plugins: VirtualBox 1.1.3+, VMware 1.1.x, Hyper-V 1.1.5, QEMU 1.1.4, Amazon ECS 1.8.0

**Ubuntu Provisioning:**
- Chef 18.8.11 (installed via omnitruck)
- SSH communicator with `vagrant:vagrant` credentials

**Windows Provisioning:**
- PowerShell 5.1+
- Chef 18.8.11 + Chocolatey
- WinRM communicator

## Testing & Validation

- **Packer validation**: Checked during `packer build` (HCL2 parser validates all *.pkr.hcl)
- **Chef validation**: Policyfile.rb validated via `chef install` during restore stage
- **Vagrant testing**: `{build}-test` stage validates provisioning via Vagrant
- Exit code 0: Successful build; Exit code 35: Chef run with changes (acceptable)

## Key Integrations

- **Chef Policyfile**: Declares dependencies and run lists; differs from recipes directory pattern
- **Vagrant provisioner**: Uses exported chef-client artifacts from build stage
- **Post-processors**: Manifest generation, checksum verification, vagrant box creation
- **ISO Caching**: Sources downloaded to `~/Downloads/` for reuse across builds
