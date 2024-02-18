# Packer

[Overview] | [Usage] | [Contributing] | [Resources]  

This repository contains [Packer] templates for creating Windows and Ubuntu images in various development scenarios.

> [!IMPORTANT]  
> The templates have been upgraded from Packer's legacy JSON format to use the newer [HCL format][PackerJSONToHCL], resulting in breaking changes in the image build proces.  
>  
> To upgrade your fork or other customizations to the newer HCL format, please follow the documentation on [contributing]. Feature updates and bug fixes will be available only in this version in the future.
>  
> To continue using the version based on the legacy JSON format, use the tag of the [2310.0.0][LastJSONRelease] release. Feature updates and bug fixes will not be backported to this version in the future.

[PackerJSONToHCL]: https://developer.hashicorp.com/packer/docs/templates/json_to_hcl
[LastJSONRelease]: https://github.com/gusztavvargadr/packer/tree/2310.0.0

## Overview

Ready-to-use [Vagrant] boxes built using this repository are published on [Vagrant Cloud][VagrantCloudBoxes].

See the [documentation][WikiOverview] for more details on the available images.

[Overview]: #overview

[VagrantCloudBoxes]: https://app.vagrantup.com/gusztavvargadr

[WikiOverview]: https://github.com/gusztavvargadr/packer/wiki#overview

## Usage

Simple [Vagrant] environments demonstrating the capabilities of the published boxes are available [in this repository][WikiUsage].

See the [documentation][WikiUsage] for more details on using the images.

[Usage]: #usage

[WikiUsage]: https://github.com/gusztavvargadr/packer/wiki#usage

## Contributing

To report bugs, request new features, propose changes or provide feedback in general, please take a look at the [discussions] or [issues] first. [Pull requests] are also welcome and are greatly appreciated.

See the [documentation][WikiContributing] for more details on building the images.

[Contributing]: #contributing

[Discussions]: https://github.com/gusztavvargadr/packer/discussions
[Issues]: https://github.com/gusztavvargadr/packer/issues
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls

[WikiContributing]: https://github.com/gusztavvargadr/packer/wiki#contributing

## Resources

This repository could not exist without the following excellent tools and technologies:

- [Packer]
- [Vagrant]
- [Hyper-V]
- [VirtualBox]
- [VMware]
- [Chef]

This repository builds on awesome ideas and solutions from the following authors and sources:

- [Matt Wrock]
- [Jacqueline]
- [Joe Fitzgerald]
- [Boxcutter]
- [Bento]

[Resources]: #resources

[Packer]: https://www.packer.io
[Vagrant]: https://www.vagrantup.com
[Chef]: https://www.chef.io
[Hyper-V]: https://learn.microsoft.com/en-us/virtualization/
[VirtualBox]: https://www.virtualbox.org
[VMware]: https://www.vmware.com/products/workstation-pro.html

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
[Bento]: https://github.com/chef/bento
