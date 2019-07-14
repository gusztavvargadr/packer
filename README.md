# Packer

**Contents** [TL;DR] | [Overview] | [Getting started] | [Usage] | [Next steps] | [Contributing] | [Resources]  

This repository contains common [Packer] helper tools and sample templates for [Visual Studio], [Docker], [IIS] and [SQL Server] on [Windows] and [Ubuntu], building virtual machine images and [Vagrant] boxes for [VirtualBox], [Hyper-V], [Azure] and [AWS], provisioned with [Chef].

## TL;DR

- [Vagrant boxes] ready to use for virtualizing hosting and development scenarios.
- [Virtual workstations] for automating the configuration of your development environments.
- Blogs with an overview of the [why][BlogWhy], [how][BlogHow] and what of Packer.

[TL;DR]: #tldr

## Overview

**Contents** [Operating systems] | [Development] | [Hosting]  

> **Note** This section covers the details of the published [Vagrant boxes] this repository builds. See the [Getting started] section to build your own virtual machine images. See [virtual workstations] for samples of automating the configuration of your development environments using them and [these][BlogWhy] [blogs][BlogHow] for more background and motivation.  

This repository contains [Packer] sample template for the following virtualization scenarios:

- [Operating systems] for generic experiments with [Windows] and [Ubuntu].
- [Development] using [Visual Studio].
- [Hosting] using [Docker], [IIS] and [SQL Server].

The virtual machine images and [Vagrant] boxes are built for [VirtualBox], [Hyper-V], [Azure] and [AWS], and are provisioned using [Chef].

> **Note** All the components, including the core operating systems, share the following characteristics:
> 
> * They are based on their publicly available versions. You might need to provide your own license(s) (for example, a valid Windows or Visual Studio license) to start or keep using them after their evaluation periods expire.
> * They are installed using their latest available versions. The latest patches (for example, all the Windows Updates) are applied as well.
> * Unless noted otherwise, they are installed using the default configuration options.

[Overview]: #overview

[Vagrant boxes]: https://app.vagrantup.com/gusztavvargadr/
[Virtual workstations]: https://github.com/gusztavvargadr/workstations/
[BlogWhy]: https://bit.ly/wdywttt5
[BlogHow]: https://bit.ly/wdywttt7

[Packer]: https://www.packer.io/
[Vagrant]: https://www.vagrantup.com/
[VirtualBox]: https://www.virtualbox.org/
[Hyper-V]: https://en.wikipedia.org/wiki/Hyper-V
[Azure]: https://azure.microsoft.com/
[AWS]: https://aws.amazon.com/
[Chef]: https://www.chef.sh/

### Operating systems

The following Vagrant boxes can be used for generic experiments on the respective platforms. They contain the core operating system with the minimum configuration required to make Vagrant work, and some of the commonly used tools installed and options configured for easier provisioning. All the other Vagrant boxes below are based on these configurations as well.

[Operating systems]: #operating-systems

#### Windows

- [**Windows 10 Version 1903 Enterpise**][windows-10]
- [**Windows Server 2019 Standard and Standard Core**][windows-server]

[Windows]: #windows

[windows-10]: https://app.vagrantup.com/gusztavvargadr/boxes/windows-10/
[windows-server]: https://app.vagrantup.com/gusztavvargadr/boxes/windows-server/

#### Ubuntu

- [**Ubuntu Desktop 1604 LTS**][ubuntu-desktop]
- [**Ubuntu Server 1604 LTS**][ubuntu-server]

[Ubuntu]: #ubuntu

[ubuntu-desktop]: https://app.vagrantup.com/gusztavvargadr/boxes/ubuntu-desktop/
[ubuntu-server]: https://app.vagrantup.com/gusztavvargadr/boxes/ubuntu-server/

### Development

The following Vagrant boxes can be used for development scenarios including setting up [virtual workstations]. They contain the respective development tools with the common configuration and are based on the core [operating systems].

[Development]: #development

#### Visual Studio

- [**Visual Studio 2019 and 2017 Community** on Windows 10 Version 1903 Enterprise and Windows Server 2019 Standard][box-visual-studio]

[Visual Studio]: #visual-studio

[box-visual-studio]: https://app.vagrantup.com/gusztavvargadr/boxes/visual-studio/

### Hosting

The following Vagrant boxes can be used for hosting scenarios. They contain the respective hosting tools with the default configuration are based on the core [operating systems].

[Hosting]: #hosting

#### Docker

- [**Docker 1809 Community and Enterprise** on Windows 10 Version 1903 Enterprise, Windows Server 2019 Standard and Standard Core][docker-windows]
- [**Docker 1809 Community** on Ubuntu Server and Desktop 1604 LTS][docker-linux]

[Docker]: #docker

[docker-windows]: https://app.vagrantup.com/gusztavvargadr/boxes/docker-windows/
[docker-linux]: https://app.vagrantup.com/gusztavvargadr/boxes/docker-linux/

#### IIS

- [**IIS 10** on Windows Server 2019 Standard and Standard Core][box-iis]

[IIS]: #iis

[box-iis]: https://app.vagrantup.com/gusztavvargadr/boxes/iis/

#### SQL Server

- [**SQL Server 2017 Developer** on Windows Server 2019 Standard][box-sql-server]

[SQL Server]: #sql-server

[box-sql-server]: https://app.vagrantup.com/gusztavvargadr/boxes/sql-server/

## Getting started

> **Note** The rest of this document covers the details of building virtual machine images and Vagrant boxes, and assumes that you are familiar with the basics of [Packer] and [Vagrant]. If that's not the case, it's recommended that you take a quick look at the [getting][PackerGettingStarted] [started][VagrantGettingStarted] guides.  

> **Note** Building the Packer templates have been tested on Windows hosts only, but they are supposed to run on any other platform as well, given that the actual virtualization provider (e.g. VirtualBox) supports it. [Let me know][Contributing] if you encounter any issues and I'm glad to help.  

Follow the steps below to install the required tools:

1. Install the [.NET Core SDK][NETCoreSDKInstallation] with [Cake Build][CakeBuildInstallation].
1. Install [Packer][PackerInstallation] and [Vagrant][VagrantInstallation].
1. Install [Chef Workstation][ChefWorkstationInstallation].
1. Install the tools for the virtualization provider you want to use.
    - **VirtualBox** Install [VirtualBox][VirtualBoxInstallation].
    - **Hyper-V** Enable [Hyper-V][HyperVEnabling].

You are now ready to build a virtual machine image and a Vagrant box.

> **Note** It is recommended to set up [caching for Packer][PackerCaching], so you can reuse the downloaded resources (e.g. OS ISOs) across different builds. Make sure you have a bunch of free disk space for the cache and the build artifacts.  

[Getting started]: #getting-started

[PackerGettingStarted]: https://www.packer.io/intro/getting-started/install.html
[VagrantGettingStarted]: https://www.vagrantup.com/intro/getting-started/index.html

[NETCoreSDKInstallation]: https://dotnet.microsoft.com/download
[CakeBuildInstallation]: https://www.nuget.org/packages/Cake.Tool/
[PackerInstallation]: https://www.packer.io/docs/install/index.html
[VagrantInstallation]: https://www.vagrantup.com/docs/installation/
[ChefWorkstationInstallation]: https://downloads.chef.io/chef-workstation/
[VirtualBoxInstallation]: https://www.virtualbox.org/wiki/Downloads/
[HyperVEnabling]: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v

[PackerCaching]: https://www.packer.io/docs/other/environment-variables.html#packer_cache_dir

## Usage

**Contents** [Building base images] | [Building images for distribution] | [Chaining builds further] | [Testing] | [Cleaning up]

This repository uses some [custom wrapper scripts][SourceCoreCake] using [Cake] to generate the Packer templates and the related resources (e.g. the unattended install configuration) required to build the virtual machine images. Besides supporting easier automation, this approach helps with reusing parts of the templates and the
related resources, and makes chaining builds and creating new configurations quite easy.

[Usage]: #usage

[SourceCoreCake]: src/core/cake/
[Cake]: http://cakebuild.net/

### Building base images

Clone this repo [including the submodules][GitCloneRecursive], and navigate to the root directory of the clone using PowerShell. Type the following command to list all the available templates you can build:

```shell
$ dotnet cake [--target=info]
```

The output will be contain the section `info` with the list of the templates:

```
...
========================================
info
========================================
w10e-virtualbox-core: Info
w10e-virtualbox-vagrant: Info
w10e-hyperv-core: Info
w10e-hyperv-vagrant: Info
...
ws2019s-virtualbox-core: Info
ws2019s-virtualbox-vagrant: Info
ws2019s-hyperv-core: Info
ws2019s-hyperv-vagrant: Info
...
ws2019s-iis-virtualbox-core: Info
ws2019s-iis-virtualbox-vagrant: Info
ws2019s-iis-hyperv-core: Info
ws2019s-iis-hyperv-vagrant: Info
...
```

You can filter this further to list only the templates for a given virtual machine image type. For example, to list the templates based on the `Windows Server 2019 Standard` image, invoke the `info` command with the `ws2019s` argument:

```shell
$ dotnet cake [--target=info] --configuration=ws2019s
```

You can use this filtering with all the `dotnet cake` commands below as well. It selects all the templates which contain the specified argument as a substring, so you can filter for components (`w10e`, `ws2019s`, `iis`, etc.) or providers (`virtualbox`, `hyperv`, `azure`, `amazon`) easily.  

The output will contain only the matching templates:

```
...
========================================
info
========================================
ws2019s-virtualbox-core: Info
ws2019s-virtualbox-vagrant: Info
ws2019s-hyperv-core: Info
ws2019s-hyperv-vagrant: Info
...
```

This means that this configuration supports building native base images (`virtualbox-core`, `hyperv-core`) mainly for reusing them in other configurations, and also, Vagrant boxes for distribution (`virtualbox-vagrant`, `hyperv-vagrant`). Under the hood, the `vagrant` configurations will simply start from the output of the `core` ones, so build times can be reduced significantly.

Now, invoke the `restore` command with the name of the template you want to build to create the resources required by Packer. For example, for VirtualBox, type the following command:

```shell
$ dotnet cake --target=restore --configuration=ws2019s-virtualbox-core
``` 

This will create the folder `build/ws2019s/virtualbox-core` in the root of your clone with all the files required to invoke the Packer build. This setup is self-contained, so you can adjust the parameters manually in `template.json` or the other resources and / or even copy it to a different machine and simply invoke `packer build template.json` there. Most of the time though, you just simply want to build as it is, as the templates are already preconfigured with some reasonable defaults. This can be done of course with the build script as well:

```shell
$ dotnet cake --target=build --configuration=ws2019s-virtualbox-core
```

This will trigger the Packer build process, which usually requires only patience. Depending on the selected configuration, a few minutes or hours later, the build output will be created, in this case in the `build/ws2019s/virtualbox-core/output` directory in the root of your clone. Virtual machine images like this can be directly used with the respective virtualization provider on the host machine.

[Building base images]: #building-base-images

[GitCloneRecursive]: https://stackoverflow.com/a/4438292

### Building images for distribution

As mentioned above, based on Packer's support for starting builds from some virtualization providers' native image format, builds can reuse the output of a previous build. To build and image which can be distributed (e.g. after applying [Sysprep] as well), type the following command:

```shell
$ dotnet cake --target=build --configuration=ws2019s-virtualbox-vagrant
```

Note that this will include restoring the build folder with the template and the related resources automatically, and then invoking the build process in a single step. It will also reuse the output of the `ws2019s-virtualbox-core` build, so it does not need to do the same steps for a Vagrant box the original build already included (e.g. the core OS installation itself, installing Windows updates, etc.). Once the build completes, the Vagrant box will be available in the `build/ws2019s/virtualbox-vagrant/output` folder.

The same approach works for Hyper-V as well:

```shell
$ dotnet cake --target=build --configuration=ws2019s-hyperv-core
$ dotnet cake --target=build --configuration=ws2019s-hyperv-vagrant
```

As you can expect, for these samples the build artifacts will be created in the `builds/ws2019s` folder as well, this time under the `hyperv-vagrant/output` subfolder. You can use the standard options to [distribute them][VagrantDistribute] to be consumed in Vagrant.

[Building images for distribution]: #building-images-for-distribution

[Sysprep]: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation
[VagrantDistribute]: https://www.vagrantup.com/docs/boxes/base.html#distributing-the-box

### Chaining builds further

Similarly to the process above, you can use build chaining to build more complex boxes. For example, the configuration for `Windows Server 2019 Standard` with `IIS` can be built like this:

```shell
$ dotnet cake --target=build --configuration=ws2019s-virtualbox-core
$ dotnet cake --target=build --configuration=ws2019s-iis-virtualbox-core
$ dotnet cake --target=build --configuration=ws2019s-iis-virtualbox-vagrant
```

As in the previous `ws2019s` sample, for this configuration the `ws2019s-iis-virtualbox-core` build will start from the output of `ws2019s-virtualbox-core` instead of starting with the core OS installation. Chanining builds like this has no limitations, so you can use this approach to build images with any number of components very effectively.

Note that the script can invoke the build of the dependencies automatically, so for the previous example you can simply type:

```shell
$ dotnet cake --target=build --configuration=ws2019s-iis-virtualbox-vagrant
```

This will in turn invoke the `restore` and `build` stages for the `ws2019s-virtualbox-core` and `ws2019s-iis-virtualbox-core` images as well. By default, `restore` and `build` is skipped if the output from a previous build exists. You can force the build to run again using the `rebuild` command instead, which will `clean` the build directories first.

Again, this works for Hyper-V as well:

```shell
$ dotnet cake --target=build --configuration=ws2019s-iis-hyperv-vagrant
```

Similarly, this will in turn build the `ws2019s-hyperv-core` and `ws2019s-iis-hyperv-core` images first if they are missing.

[Chaining builds further]: #chaining-builds-further

### Testing

To help testing the build results, the reposiory contains a simple [Vagrantfile] to create virtual machines using directly the build outputs. You can play around with the [Vagrant CLI][VagrantCLI] yourself, or let the build script manage it for you.

For example, to test the `ws2019s` configuration, from the root of your clone you can type the following command to use the box files in the `build\ws2019s` folder:

```shell
$ dotnet cake --target=test --configuration=ws2019s-virtualbox-vagrant
```

This will import the locally built Vagrant box temporarily with the name `ws2019s-build` and will use that to spin up a new virtual machine. After outputting some basic diagnostics information, it destroys the newly created virtual machine and removes the temporary Vagrant box.

[Testing]: #testing

[Vagrantfile]: Vagrantfile
[VagrantCLI]: https://www.vagrantup.com/docs/cli/

### Cleaning up

Though the `build` folders are excluded by default from the repository, they can consume significant disk space. You can manually delete the folders, but the build script provides support for this as well:

```shell
$ dotnet cake --target=clean --configuration=ws2019s-iis-virtualbox-vagrant
```

Using the filtering, to clean up the artifacts of all the VirtualBox builds, you can type:

```shell
$ dotnet cake --target=clean --configuration=virtualbox
```

Omitting this parameter will apply the command to all the templates, so the following command will clean up everything:

```shell
$ dotnet cake --target=clean
```

> **Note** The `clean` command removes only the Packer build templates and artifacts, the eventually imported Vagrant boxes and virtual machines are taken care of the `test` command.  

[Cleaning up]: #cleaning-up

## Next steps

Take a look at the repository of [virtual workstations] to easily automate and share your development environment configurations using the Vagrant boxes above.

[Next steps]: #next-steps

## Contributing

Feedback, please - [issues] or [pull requests] are welcome and are greatly appreciated. Chek out the [milestones] for the list of planned releases.

[Contributing]: #contributing

[Issues]: https://github.com/gusztavvargadr/packer/issues/
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls/
[Milestones]: https://github.com/gusztavvargadr/packer/milestones/ 

## Resources

This repository could not exist without the following great tools:

- [Packer]
- [Vagrant]
- [VirtualBox]
- [Hyper-V]
- [Azure]
- [AWS]
- [Chef]

This repository borrows awesome ideas and solutions from the following sources:

- [Matt Wrock]
- [Jacqueline]
- [Joe Fitzgerald]
- [Boxcutter]
- [Bento]

[Resources]: #resources

[Matt Wrock]: https://github.com/mwrock/packer-templates/
[Jacqueline]: https://github.com/jacqinthebox/packer-templates/
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows/
[Boxcutter]: https://github.com/boxcutter/windows/
[Bento]: https://github.com/chef/bento/
