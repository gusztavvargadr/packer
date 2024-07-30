# Packer samples

This folder contains Packer templates for building `Windows` and `Ubuntu` images.

## Overview

See the links below for the details of the available images.

### Operating systems

- [Windows Server](./windows-server/README.md)
- [Windows 11](./windows-11/README.md)
- [Windows 10](./windows-10/README.md)
- [Ubuntu Server](./ubuntu-server/README.md)
- [Ubuntu Desktop](./ubuntu-desktop/README.md)

### Hosting

- [Docker Windows](./docker-windows/README.md)
- [Docker Linux](./docker-linux/README.md)
- [IIS](./iis/README.md)
- [SQL Server](./sql-server/README.md)

### Development

- [Kitchen Windows](./kitchen-windows/README.md)
- [Kitchen Ubuntu](./kitchen-ubuntu/README.md)
- [Visual Studio](./visual-studio/README.md)

## Usage

See the steps below for the details of using the images.

> [!NOTE]  
> This section assumes that you are familiar with the basics of [Vagrant][VagrantTutorials] and the [provider][VagrantProviders] being used.  

[VagrantTutorials]: https://developer.hashicorp.com/vagrant/tutorials/getting-started
[VagrantProviders]: https://developer.hashicorp.com/vagrant/docs/providers

### Getting started

Start with installing the following tools:

- [Vagrant][VagrantInstallation]
- At least one of the supported providers
  - [Hyper-V][HyperVInstallation]
  - [VirtualBox][VirtualBoxInstallation]
  - [VMware][VMwareInstallation]

[VagrantInstallation]: https://developer.hashicorp.com/vagrant/install
[HyperVInstallation]: https://developer.hashicorp.com/vagrant/docs/providers/hyperv
[VirtualBoxInstallation]: https://developer.hashicorp.com/vagrant/docs/providers/virtualbox
[VMwareInstallation]: https://developer.hashicorp.com/vagrant/docs/providers/vmware

### Using the images

<!--
vagrant status
vagrant up
-->

### Next steps

<!--
vagrant repo
workstations repo
building
-->

## Contributing

See the steps below for the details of building the images.

<!--
getting started

> **Note** The rest of this document covers the details of building virtual machine images and Vagrant boxes, and assumes that you are familiar with the basics of [Packer] and [Vagrant]. If that's not the case, it's recommended that you take a quick look at the [getting][PackerGettingStarted] [started][VagrantGettingStarted] guides.  

> **Note** Building the Packer templates have been tested on Windows and Ubuntu hosts only, but they are supposed to run on any other platform as well, given that the actual virtualization provider (e.g. VirtualBox) supports it. [Let me know][Contributing] if you encounter any issues and I'm glad to help.  

Follow the steps below to install the latest version of the required tools:

1. Install the [.NET Core SDK][NETCoreSDKInstallation].
1. Install [Packer][PackerInstallation].
1. Install [Chef Workstation][ChefWorkstationInstallation].

You are now ready to build a virtual machine image and a Vagrant box.

> **Note** It is recommended to set up [caching for Packer][PackerCaching], so you can reuse the downloaded resources (e.g. OS ISOs) across different builds. Make sure you have a bunch of free disk space for the cache and the build artifacts.  

[PackerGettingStarted]: https://developer.hashicorp.com/packer/tutorials

[NETCoreSDKInstallation]: https://dotnet.microsoft.com/download
[PackerInstallation]: https://developer.hashicorp.com/packer/install
[ChefWorkstationInstallation]: https://downloads.chef.io/chef-workstation/

[PackerCaching]: https://www.packer.io/docs/other/environment-variables.html#packer_cache_dir

**Contents** [Building base images] | [Building images for distribution] | [Chaining builds further] | [Testing] | [Cleaning up]

This repository uses some [custom wrapper scripts][SourceCoreCake] using [Cake] to generate the Packer templates and the related resources (e.g. the unattended install configuration) required to build the virtual machine images. Besides supporting easier automation, this approach helps with reusing parts of the templates and the
related resources, and makes chaining builds and creating new configurations quite easy.

[SourceCoreCake]: src/core/cake/
[Cake]: http://cakebuild.net/

### Building base images

Clone this repo [including the submodules][GitCloneRecursive], and navigate to the root directory of the clone in your shell. Type the following command to list all the available templates you can build:

```shell
$ dotnet tool restore
$ dotnet cake [--target=info]
```

The output will be contain the section `info` with the list of the templates:

```
...
========================================
info
========================================
...
ws2022s-virtualbox-core: Info
ws2022s-virtualbox-vagrant: Info
ws2022s-vmware-core: Info
ws2022s-vmware-vagrant: Info
ws2022s-hyperv-core: Info
ws2022s-hyperv-vagrant: Info
...
w1022h2e-virtualbox-core: Info
w1022h2e-virtualbox-vagrant: Info
w1022h2e-vmware-core: Info
w1022h2e-vmware-vagrant: Info
w1022h2e-hyperv-core: Info
w1022h2e-hyperv-vagrant: Info
...
ws2022s-iis-virtualbox-core: Info
ws2022s-iis-virtualbox-vagrant: Info
ws2022s-iis-vmware-core: Info
ws2022s-iis-vmware-vagrant: Info
ws2022s-iis-hyperv-core: Info
ws2022s-iis-hyperv-vagrant: Info
...
```

You can filter this further to list only the templates for a given virtual machine image type. For example, to list the templates based on the `Windows Server 2022 Standard` image, invoke the `info` command with the `ws2022s` argument:

```shell
$ dotnet cake [--target=info] --configuration=ws2022s
```

You can use this filtering with all the `dotnet cake` commands below as well. It selects all the templates which contain the specified argument as a substring, so you can filter for components (`ws2022s`, `w1022h2e`, `iis`, etc.) or providers (`virtualbox`, `vmware`, `hyperv`) easily.  

The output will contain only the matching templates:

```
...
========================================
info
========================================
ws2022s-virtualbox-core: Info
ws2022s-virtualbox-vagrant: Info
ws2022s-vmware-core: Info
ws2022s-vmware-vagrant: Info
ws2022s-hyperv-core: Info
ws2022s-hyperv-vagrant: Info
...
```

This means that this configuration supports building native base images (`virtualbox-core`, `vmware-core`, `hyperv-core`) mainly for reusing them in other configurations, and also, Vagrant boxes for distribution (`virtualbox-vagrant`, `vmware-vagrant`, `hyperv-vagrant`). Under the hood, the `vagrant` configurations will simply start from the output of the `core` ones, so build times can be reduced significantly.

Now, invoke the `restore` command with the name of the template you want to build to create the resources required by Packer. For example, for VirtualBox, type the following command:

```shell
$ dotnet cake --target=restore --configuration=ws2022s-virtualbox-core
``` 

This will create the folder `artifacts/ws2022s/virtualbox-core` in the root of your clone with all the files required to invoke the Packer build. This setup is self-contained, so you can adjust the parameters manually in `template.json` or the other resources and / or even copy it to a different machine and simply invoke `packer build template.json` there. Most of the time though, you just simply want to build as it is, as the templates are already preconfigured with some reasonable defaults. This can be done of course with the build script as well:

```shell
$ dotnet cake --target=build --configuration=ws2022s-virtualbox-core
```

This will trigger the Packer build process, which usually requires only patience. Depending on the selected configuration, a few minutes or hours later, the build output will be created, in this case in the `artifacts/ws2022s/virtualbox-core/output` directory in the root of your clone. Virtual machine images like this can be directly used with the respective virtualization provider on the host machine.

[Building base images]: #building-base-images

[GitCloneRecursive]: https://stackoverflow.com/a/4438292

### Building images for distribution

As mentioned above, based on Packer's support for starting builds from some virtualization providers' native image format, builds can reuse the output of a previous build. To build and image which can be distributed (e.g. after applying [Sysprep] as well), type the following command:

```shell
$ dotnet cake --target=build --configuration=ws2022s-virtualbox-vagrant
```

Note that this will include restoring the build folder with the template and the related resources automatically, and then invoking the build process in a single step. It will also reuse the output of the `ws2022s-virtualbox-core` build, so it does not need to do the same steps for a Vagrant box the original build already included (e.g. the core OS installation itself, installing Windows updates, etc.). Once the build completes, the Vagrant box will be available in the `artifacts/ws2022s/virtualbox-vagrant/output` folder.

The same approach works for VMware and Hyper-V as well:

```shell
$ dotnet cake --target=build --configuration=ws2022s-hyperv-core
$ dotnet cake --target=build --configuration=ws2022s-hyperv-vagrant
```

As you can expect, for these samples the build artifacts will be created in the `artifacts/ws2022s` folder as well, this time under the `hyperv-vagrant/output` subfolder. You can use the standard options to [distribute them][VagrantDistribute] to be consumed in Vagrant.

[Building images for distribution]: #building-images-for-distribution

[Sysprep]: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation
[VagrantDistribute]: https://www.vagrantup.com/docs/boxes/base.html#distributing-the-box

### Chaining builds further

Similarly to the process above, you can use build chaining to build more complex boxes. For example, the configuration for `Windows Server 2022 Standard` with `IIS` can be built like this:

```shell
$ dotnet cake --target=build --configuration=ws2022s-virtualbox-core
$ dotnet cake --target=build --configuration=ws2022s-iis-virtualbox-core
$ dotnet cake --target=build --configuration=ws2022s-iis-virtualbox-vagrant
```

As in the previous `ws2022s` sample, for this configuration the `ws2022s-iis-virtualbox-core` build will start from the output of `ws2022s-virtualbox-core` instead of starting with the core OS installation. Chanining builds like this has no limitations, so you can use this approach to build images with any number of components very effectively.

Note that the script can invoke the build of the dependencies automatically, so for the previous example you can simply type:

```shell
$ dotnet cake --target=build --configuration=ws2022s-iis-virtualbox-vagrant --recursive true
```

This will in turn invoke the `restore` and `build` stages for the `ws2022s-virtualbox-core` and `ws2022s-iis-virtualbox-core` images as well. By default, `restore` and `build` is skipped if the output from a previous build exists. You can force the build to run again using the `rebuild` command instead, which will `clean` the build directories first.

Again, this works for VMware and Hyper-V as well:

```shell
$ dotnet cake --target=build --configuration=ws2022s-iis-hyperv-vagrant --recursive true
```

Similarly, this will in turn build the `ws2022s-hyperv-core` and `ws2022s-iis-hyperv-core` images first if they are missing.

[Chaining builds further]: #chaining-builds-further

### Testing

To help testing the build results, the reposiory contains a simple [Vagrantfile] to create virtual machines using directly the build outputs. You can play around with the [Vagrant CLI][VagrantCLI] yourself, or let the build script manage it for you.

For example, to test the `ws2022s` configuration, from the root of your clone you can type the following command to use the box files in the `build\ws2022s` folder:

```shell
$ dotnet cake --target=test --configuration=ws2022s-virtualbox-vagrant
```

This will import the locally built Vagrant box temporarily with the name `ws2022s-build` and will use that to spin up a new virtual machine. It also outputs some basic diagnostics information to help quickly checking the installations.

[Testing]: #testing

[Vagrantfile]: Vagrantfile
[VagrantCLI]: https://www.vagrantup.com/docs/cli/

### Cleaning up

Though the `build` folders are excluded by default from the repository, they can consume significant disk space. You can manually delete the folders, but the build script provides support for this as well:

```shell
$ dotnet cake --target=clean --configuration=ws2022s-iis-virtualbox-vagrant
```

Using the filtering, to clean up the artifacts of all the VirtualBox builds, you can type:

```shell
$ dotnet cake --target=clean --configuration=virtualbox
```

Omitting this parameter will apply the command to all the templates, so the following command will clean up everything:

```shell
$ dotnet cake --target=clean
```

> **Note** The `clean` command cleans up dependencies recursively, including the eventually imported Vagrant boxes and virtual machines created using the `test` command.  

[Cleaning up]: #cleaning-up

## Resources

The virtual machine images and [Vagrant] boxes are built for [Hyper-V], [VirtualBox] and [VMware], and are provisioned using [Chef].

-->

<!--
azure devops samples
-->

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
