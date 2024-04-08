# Packer

This repository contains [Packer] templates for building Windows and Ubuntu images in various development scenarios.

> [!IMPORTANT]  
> The templates [have been upgraded][PackerJSONToHCL] from Packer's legacy JSON format to use the newer HCL format, resulting in breaking changes in the image build proces.  
>  
> To upgrade your fork or other customizations to the newer HCL format, please follow the documentation on [contributing]. Feature updates and bug fixes will be available only in this version in the future.
>  
> To continue using the version based on the legacy JSON format, use the tag of the [2310.0.0][LastJSONRelease] release. Feature updates and bug fixes will not be backported to this version in the future.

[PackerJSONToHCL]: https://developer.hashicorp.com/packer/docs/templates/json_to_hcl
[Contributing]: #contributing
[LastJSONRelease]: https://github.com/gusztavvargadr/packer/tree/2310.0.0

## Overview

Ready-to-use [Vagrant] boxes built using this repository are published on [Vagrant Cloud][VagrantCloudBoxes].

See the [documentation][DocumentationOverview] for more details on the available images for [Hyper-V], [VirtualBox] and [VMware].

[VagrantCloudBoxes]: https://app.vagrantup.com/gusztavvargadr

[DocumentationOverview]: ./samples/README.md#overview

## Usage

Simple [Vagrant] environments demonstrating the capabilities of the published boxes are available at the [samples][Samples].

See the [documentation][DocumentationUsage] for more details on using the images with [Hyper-V], [VirtualBox] and [VMware].

[DocumentationUsage]: ./samples/README.md#usage

## Contributing

Complete [Packer] templates used for building the published boxes are available at the [samples][Samples].

See the [documentation][DocumentationContributing] for more details on building the images for [Hyper-V], [VirtualBox] and [VMware] with [Chef].

To report bugs, propose changes, request new features or provide feedback in general, please take a look at the [discussions] or [issues] first. [Pull requests] are also welcome and are greatly appreciated.

[DocumentationContributing]: ./samples/README.md#contributing

[Discussions]: https://github.com/gusztavvargadr/packer/discussions
[Issues]: https://github.com/gusztavvargadr/packer/issues
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls

## Support

> [!TIP]
> Are you interested in more images and providers or deployments of custom environments based on them?  
>  
> The following services are also available on-demand in a professional setting:  
>  
> - Custom images with additional virtualization and cloud providers
> - Custom build schedules with new versions published as soon as the official updates are available
> - Custom environments like build agent pools, test matrices and deployment targets based on the images
>  
> Please reach out at [mail@gv4c.com][MailTo] for more details.

[MailTo]: mailto:mail@gv4c.com

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
[Hyper-V]: https://learn.microsoft.com/en-us/virtualization/
[VirtualBox]: https://www.virtualbox.org
[VMware]: https://www.vmware.com/products/workstation-pro.html
[Chef]: https://www.chef.io

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
[Bento]: https://github.com/chef/bento

[Samples]: ./samples
