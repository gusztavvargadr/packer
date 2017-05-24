# Packer

**Quick links** [Vagrant boxes] | [Workstation samples][Workstations]  

This repository contains Packer templates to build Windows-based Vagrant boxes for .NET development purposes using Hyper-V / VirtualBox and Chef.

**Contents** [Overview] | [Getting started] | [Usage] | [Contributing] | [Resources]  

## Overview

This repository contains [Packer] templates to build Windows-based [Vagrant boxes] for the following scenarios:

- Core [operating systems] for generic experiments with Windows 10 and Windows Server 2016.
- [.NET development] [workstations] using Visual Studio 2017, 2015 and 2010.
- [.NET hosting] using IIS and SQL Server 2014.

The boxes are built for [Hyper-V] - supporting [nested virtualization] - and [VirtualBox] and are provisioned using [Chef]. All the components, including the core operating systems, share the following characteristics:

* They are based on their publicly available versions. You might need to provide your own license(s) (for example, a valid Windows or Visual Studio license) to start or keep using them after their evaluation periods expire.
* They are installed using their latest available versions. The latest patches (for example, all the Windows Updates) are applied as well.
* Unless noted otherwise, they are installed using the default configuration options.

[Overview]: #overview

[Vagrant boxes]: https://atlas.hashicorp.com/gusztavvargadr
[Nested virtualization]: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization

### Operating systems

The following boxes can be used for generic expirments on the respective platforms.

The boxes contain the core operating system with the minimum configuration required to make Vagrant work, and some of the commonly used tools installed and options configured for easier provisioning. All the other boxes below are based on these configurations as well.

- **Windows Server 2016**
  - **[Standard][w16s]**
- **Windows 10**
  - **[Enterpise][w10e]**

In the box:

- **Windows Server 2016 1607** and **Windows 10 1703**
  - Operating system
    - Administrator user with user name `vagrant` and password `vagrant` set to never expire
    - WinRM enabled
    - UAC disabled
    - Windows Updates disabled
    - Windows Defender disabled
    - Remote Desktop enabled
    - Generalized with Sysprep
  - Tools
    - [Chocolatey](https://chocolatey.org/packages/chocolatey/) 0.10.5
    - [7-Zip](https://chocolatey.org/packages/7zip/) 16.4.0
    - [Chef Client](https://chocolatey.org/packages/chef-client) 12.14.77
    - **VirtualBox** [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) 5.1.22
  - Vagrant box
    - WinRM communicator
    - 1 CPU
    - 1 GB RAM
    - **Hyper-V** IP address reporting timeout of 5 minutes
    - **VirtualBox** Port forwarding for RDP from 3389 to 33389 with auto correction

[Operating systems]: #operating-systems

[w16s]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s
[w10e]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e

### .NET development

The following boxes can be used for setting up .NET development [workstations].

The boxes contain the respective Visual Studio version with the commonly used options and are based on the core images of the [operating systems].

- **Visual Studio 2017**
  - **[Community][w16s-vs17c]** with Windows Server 2016
  - **[Professional][w16s-vs17p]** with Windows Server 2016
- **Visual Studio 2015**
  - **[Community][w16s-vs15c]** with Windows Server 2016
  - **[Professional][w16s-vs15p]** with Windows Server 2016
- **Visual Studio 2010**
  - **[Professional][w16s-vs10p]** with Windows Server 2016

In the box:

- **Visual Studio 2017 Update 2**
  - C# and F#
  - .NET Framework 3.5 and 4.0-4.6
  - .NET Core cross-platform development
  - .NET desktop development
  - ASP.NET and web development
  - Data storage and processing
  - Azure development
- **Visual Studio 2015 Update 3**
  - C# and F#
  - .NET Framework 3.5 and 4.0-4.6
  - .NET Core Tools Preview
  - Web Developer Tools
  - SQL Server Data Tools
- **Visual Studio 2010 SP1**
  - C# and F#
  - .NET Framework 3.5 and 4.0
  - Web Developer Tools
  - SQL Server Data Tools

[.NET development]: #net-development

[w16s-vs17c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs17c
[w16s-vs17p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs17p
[w16s-vs15c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs15c
[w16s-vs15p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs15p
[w16s-vs10p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs10p

### .NET hosting

The following boxes can be used for .NET hosting scenarios.

The boxes contain the respective hosting tools with the default configuration are based on the core images of the [operating systems].

- **IIS 10**
  - **[OS component][w16s-iis]** with Windows Server 2016
- **SQL Server 2014**
  - **[Developer][w16s-sql14d]** with Windows Server 2016

In the box:

* **IIS 10**
  * .NET Framework 3.5 and 4.0-4.6
  * .NET Core Windows Server Hosting bundle
* **SQL Server 2014 SP2**
  * Database Engine
  * Management Studio

[.NET hosting]: #net-hosting

[w16s-iis]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-iis
[w16s-sql14d]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-sql14d

## Getting started

**Note** The rest of this document covers the details of building Vagrant boxes using Packer. If you are interested in just using the already available [boxes][Vagrant boxes] instead, check out the samples of [workstations] for some common usage scenarios.  
**Note** Building the Packer templates have been tested on Windows hosts only, but they are supposed to run on any other platform as well, given that the actual virtualization provider (e.g. VirtualBox) supports it. [Let me know][Contributing] if you encounter any issues and I'm glad to help.  

Follow the steps below to install the required tools:

1. Install [Packer][PackerInstallation].
1. Install the [Chef Development Kit][ChefDKInstallation].
1. Install the tools for the virtualization provider you want to use.
    - **Hyper-V** Enable [Hyper-V][HyperVEnabling].
    - **VirtualBox** Install [VirtualBox][VirtualBoxInstallation].

Then, clone this repo, and navigate to the root directory of the clone using PowerShell. Type the following commands to verify the installations:

```powershell
$ cd .\src\w16s
$ .\ci.ps1 restore virtualbox-ovf
```

If the build script completes without errors, and the folder `build/w16s/virtualbox-ovf` in the root of your clone contains the file `template.json`, that means that you have set up everything correctly.

You are now ready to build a Vagrant box.

[Getting started]: #getting-started

[Workstations]: https://github.com/gusztavvargadr/workstations
[PackerInstallation]: https://www.packer.io/docs/install/index.html
[ChefDKInstallation]: https://downloads.chef.io/chefdk
[HyperVEnabling]: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
[VirtualBoxInstallation]: https://www.virtualbox.org/wiki/Downloads

## Usage

**Note** This section assumes you are familiar with the basics of [Packer]. If that's not the case, it's recommended that you take a quick look at its [getting started guide][PackerGettingStarted].  
**Note** It is recommended to set up [caching for Packer][PackerCaching], so you can reuse the downloaded resources (e.g. OS ISOs) across different builds. Make sure you have a bunch of free disk space for the cache and the build artifacts.  

This repository uses some [custom wrapper scripts][SourceCoreCake] using [Cake] to generate the templates and the related resources (e.g. the unattended install configuration) required to build the boxes. Besides supporting easier automation, this approach helps with reusing parts of the templates and the
related resources, and makes chaining builds and creating new configurations quite easy.

[Usage]: #usage

[PackerCaching]: https://www.packer.io/docs/other/environment-variables.html#packer_cache_dir
[PackerGettingStarted]: https://www.packer.io/intro/getting-started/install.html
[SourceCoreCake]: src/core/cake
[Cake]: http://cakebuild.net/

### Building a native box

Start by navigating to the [source] of the configuration you want to build using PowerShell. For example, to build a `Windows Server 2016 Standard` box, select `w16s` and enter the `info` command to list the available templates:

```powershell
$ cd .\src\w16s
$ .\ci.ps1 info
```

The output will contain a section similar to the one below:

```
========================================
packer-info
========================================
Executing task: packer-info
virtualbox-ovf: Info
virtualbox-vagrant: Info
hyperv-vagrant: Info
Finished executing task: packer-info
```

This means that this configuration supports building a box with the native VirtualBox image format (`virtualbox-ovf`), and also boxes to be used with Vagrant directly with the respective virtualization provider (`virtualbox-vagrant`, `hyperv-vagrant`). Under the hood, `virtualbox-vagrant` will simply reuse the output of `virtualbox-ovf`, so the build time can be reduced significantly.

Now, invoke the `restore` command with the name of the template you want to build to create the template and the related resources. For example, for the native VirtualBox image format, type the following command:

```powershell
$ .\ci.ps1 restore virtualbox-ovf
``` 

This will create the folder `build/w16s/virtualbox-ovf` in the root of your clone with all the files required to build the box. This setup is self-contained, so you can adjust the parameters manually in `template.json` and / or even copy it to a different machine and simply invoke `packer build template.json` there to build it. Most of the time though, you just simply want to build as it is, as the templates are already preconfigured. This can be done from the source directory as well:

```powershell
$ .\ci.ps1 build virtualbox-ovf
```

This will trigger the Packer build process, which usually requires only patience. Depending on the selected configuration, a few minutes or hours later, the build artifacts will be created, in this case in the `artifacts/w16s/virtualbox-ovf` in the root of your clone. Native images like this can now be directly imported into the respective virtualization provider.

[Source]: src

### Building a Vagrant box

As mentioned above, based on Packer's support for starting builds from some virtualization providers' native format, builds can reuse the artifacts of a previous one. To build the Vagrant box for the above configuration, type the following command:

```powershell
$ .\ci.ps1 build virtualbox-vagrant
```

Note that this will include restoring the build folder with the template and the related resources automatically and then invoking the build process in a single step. It will also reuse the output of the `virtualbox-ovf` build, so it does not need to do the same steps for a Vagrant box the original build already included (e.g. the core OS installation itself, installing Windows updates, etc.).

For Hyper-V this build chaining is not supported yet, though of course you can still build a Vagrant box, it's just that it will always start from scratch:

```powershell
$ .\ci.ps1 build hyperv-vagrant
```

As you can expect, for these samples the build artifacts will be created in the `artifacts/w16s` folder as well. You can use the standard options to [distribute them][VagrantDistribute] to be consumed in Vagrant.

[VagrantDistribute]: https://www.vagrantup.com/docs/boxes/base.html#distributing-the-box

### Chaining builds further

Similarly to the process above, you can use build chaining to build more complex boxes. For example, the configuration for `Windows Server 2016 Standard` with `IIS` works like this.

```powershell
$ cd src\w16s-iis
$ .\ci.ps1 build virtualbox-ovf
$ .\ci.ps1 build virtualbox-vagrant
```

Unlike in the previous `w16s` sample, for this configuration the first `virtualbox-ovf` build will start from the native output of `w16s` instead of starting with the core OS installation. Chanining builds like this has no limitations, so you can use this approach to build boxes with any number of components very effectively.

For now, for Hyper-V you can simply start from scratch:

```powershell
$ .\ci.ps1 build hyperv-vagrant
```

Builds will take significantly longer, but the result will be exactly the same as for the VirtualBox chained builds.

## Contributing

<!--
**Note** This section assumes you are familiar with the basics of [Chef]. If that's not the case, it's recommended that you take a quick look at its [getting started guide][ChefGettingStarted].

TODO: custom template and build
-->

Any feedback, [issues] or [pull requests] are welcome and greatly appreciated. Chek out the [milestones] for the list of planned releases.

[Contributing]: #contributing

[Issues]: https://github.com/gusztavvargadr/packer/issues
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls
[Milestones]: https://github.com/gusztavvargadr/packer/milestones 

## Resources

This repository could not exist without the following great tools:

* [Packer]
* [Hyper-V]
* [VirtualBox]
* [Chef]
* [Vagrant]

This repository borrows awesome ideas and solutions from the following sources:

* [Matt Wrock]
* [Jacqueline]
* [Joe Fitzgerald]
* [Boxcutter]

[Resources]: #resources

[Packer]: https://www.packer.io/
[Hyper-V]: https://en.wikipedia.org/wiki/Hyper-V
[VirtualBox]: https://www.virtualbox.org/
[Chef]: https://chef.io/chef/
[Vagrant]: https://www.vagrantup.com/

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
