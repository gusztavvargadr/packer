# Packer

[Overview] | [Usage] | [Contributing] | [Resources]  

> [!IMPORTANT]  
> The repository has been upgraded from Packer's legacy JSON templates to use the newer [HCL format][PackerJSONToHCL], resulting in breaking changes in the image build proces.  
>  
> To upgrade your fork or other customizations to the HCL format, please follow the documentation on [contributing].
>  
> To get the latest version of the JSON templates, use the tag of the [2310.0.0][LastJSONRelease] release.

[PackerJSONToHCL]: https://developer.hashicorp.com/packer/docs/templates/json_to_hcl
[LastJSONRelease]: https://github.com/gusztavvargadr/packer/tree/2310.0.0

This repository contains [Packer] samples for creating Windows and Ubuntu images in various development scenarios.

## Overview

Ready-to-use [Vagrant] boxes are available on [Vagrant Cloud][VagrantCloudBoxes].

See the documentation of the [samples][SamplesOverview] for more details on the available images.

[Overview]: #overview

[VagrantCloudBoxes]: https://app.vagrantup.com/gusztavvargadr

[SamplesOverview]: ./samples/README.md#overview

## Usage

See the documentation of the [samples][SamplesUsage] for more details on using the images.

[Usage]: #usage

[SamplesUsage]: ./samples/README.md#usage

## Contributing

To report bugs, request new features, propose changes or provide feedback in general, please take a look at the [discussions] or [issues] first. [Pull requests] are also welcome and are greatly appreciated.

See the documentation of the [samples][SamplesContributing] for more details on building the images.

[Contributing]: #contributing

[Discussions]: https://github.com/gusztavvargadr/packer/issues
[Issues]: https://github.com/gusztavvargadr/packer/issues
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls

[SamplesContributing]: ./samples/README.md#contributing

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

[Packer]: https://packer.io
[Vagrant]: https://vagrantup.com
[Hyper-V]: https://en.wikipedia.org/wiki/Hyper-V
[VirtualBox]: https://virtualbox.org
[VMware]: https://www.vmware.com/products/workstation-pro.html
[Chef]: https://chef.io

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
[Bento]: https://github.com/chef/bento
