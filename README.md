# Packer

**See also** [Virtual workstations] | [Packer templates] | [Infrastructure components]  

[Infrastructure components]: https://github.com/gusztavvargadr/infrastructure

[This repository][Packer templates] contains Packer templates to build Vagrant boxes for .NET development scenarios with Hyper-V, VirtualBox and AWS.

[Packer templates]: https://github.com/gusztavvargadr/packer

**Contents** [Overview] | [Getting started] | [Usage] | [Contributing] | [Resources]  

## Overview

This repository contains [Packer] templates to build [Vagrant boxes] and native virtual machine images for the following scenarios:

- Core [operating systems] for generic experiments with Windows 10 and Windows Server 2016.
- [.NET development] using Visual Studio 2017, 2015 and 2010.
- [.NET hosting] using IIS and SQL Server 2014.

The virtual machine images are built for [Hyper-V] - supporting [nested virtualization] -, [VirtualBox] and [AWS] and are provisioned using [Chef].

All the components, including the core operating systems, share the following characteristics:

* They are based on their publicly available versions. You might need to provide your own license(s) (for example, a valid Windows or Visual Studio license) to start or keep using them after their evaluation periods expire.
* They are installed using their latest available versions. The latest patches (for example, all the Windows Updates) are applied as well.
* Unless noted otherwise, they are installed using the default configuration options.

[Overview]: #overview

[Vagrant boxes]: https://atlas.hashicorp.com/gusztavvargadr
[Nested virtualization]: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization

### Operating systems

The following Vagrant boxes can be used for generic expirments on the respective platforms.

They contain the core operating system with the minimum configuration required to make Vagrant work, and some of the commonly used tools installed and options configured for easier provisioning. All the other Vagrant boxes below are based on these configurations as well.

- **Windows 10**
  - **[Enterpise][w10e]**
- **Windows Server 2016**
  - **[Standard][w16s]**

In the box:

- **Windows 10 1703** and **Windows Server 2016 1607** 
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
    - **Hyper-V** Generation 1, Configuration Version 8.0
      - Requires Windows 10 or Windows Server 2016 version 1607 or later on the host
    - **VirtualBox** [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) 5.1.22
      - Recommended to have VirtualBox version 5.1.22 or later on the host
  - Vagrant box
    - WinRM communicator
    - 1 CPU
    - 1 GB RAM
    - **Hyper-V** IP address reporting timeout of 5 minutes
    - **VirtualBox** Port forwarding for RDP from 3389 to 33389 with auto correction

[Operating systems]: #operating-systems

[w10e]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e
[w16s]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s

### .NET development

The following Vagrant boxes can be used for setting up [virtual workstations] for .NET development .

They contain the respective Visual Studio version with the commonly used options and are based on the core [operating systems].

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

The following Vagrant boxes can be used for .NET hosting scenarios.

They contain the respective hosting tools with the default configuration are based on the core [operating systems].

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

**Note** The rest of this document covers the details of building Vagrant boxes or native virtual machine images using Packer. If you are interested in just using the already available [Vagrant boxes] instead, check out the samples of [virtual workstations] for some common usage scenarios.  

**Note** Building the Packer templates have been tested on Windows hosts only, but they are supposed to run on any other platform as well, given that the actual virtualization provider (e.g. VirtualBox) supports it. [Let me know][Contributing] if you encounter any issues and I'm glad to help.  

Follow the steps below to install the required tools:

1. Install [Packer][PackerInstallation].
1. Install the [Chef Development Kit][ChefDKInstallation].
1. Install the tools for the virtualization provider you want to use.
    - **Hyper-V** Enable [Hyper-V][HyperVEnabling].
    - **VirtualBox** Install [VirtualBox][VirtualBoxInstallation].
    - **AWS** Install the [AWS Command Line Interface][AWSCLIInstallation].

You are now ready to build a Vagrant box.

[Getting started]: #getting-started

[Virtual workstations]: https://github.com/gusztavvargadr/workstations
[PackerInstallation]: https://www.packer.io/docs/install/index.html
[ChefDKInstallation]: https://downloads.chef.io/chefdk
[HyperVEnabling]: https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
[VirtualBoxInstallation]: https://www.virtualbox.org/wiki/Downloads
[AWSCLIInstallation]: https://aws.amazon.com/cli/

## Usage

**Note** This section assumes you are familiar with the basics of [Packer]. If that's not the case, it's recommended that you take a quick look at its [getting started guide][PackerGettingStarted].  

**Note** It is recommended to set up [caching for Packer][PackerCaching], so you can reuse the downloaded resources (e.g. OS ISOs) across different builds. Make sure you have a bunch of free disk space for the cache and the build artifacts.  

This repository uses some [custom wrapper scripts][SourceCoreCake] using [Cake] to generate the Packer templates and the related resources (e.g. the unattended install configuration) required to build the virtual machine images. Besides supporting easier automation, this approach helps with reusing parts of the templates and the
related resources, and makes chaining builds and creating new configurations quite easy.

[Usage]: #usage

[PackerCaching]: https://www.packer.io/docs/other/environment-variables.html#packer_cache_dir
[PackerGettingStarted]: https://www.packer.io/intro/getting-started/install.html
[SourceCoreCake]: src/core/cake
[Cake]: http://cakebuild.net/

### Building a native virtual machine image

Clone this repo, and navigate to the root directory of the clone using PowerShell. Type the following command to list all the available templates you can build:

```powershell
$ .\ci.ps1 [info]
```

The output will be contain the section `packer-info` with the list of the templates:

```
...
========================================
packer-info
========================================
Executing task: packer-info
w10e-virtualbox-base: Info
w10e-virtualbox-sysprep: Info
w10e-hyperv-sysprep: Info
w16s-virtualbox-base: Info
w16s-virtualbox-sysprep: Info
w16s-hyperv-sysprep: Info
w16s-amazon-sysprep: Info
w16s-iis-virtualbox-base: Info
...
```

You can filter this further to list only the templates for a given virtual machine image type. For example, to list the templates of the `Windows 10 Enterprise` image, invoke the `info` command with the `w10e` parameter:

```powershell
$ .\ci.ps1 info w10e
```

The output will contain only the matching templates:

```
...
========================================
packer-info
========================================
Executing task: packer-info
w10e-virtualbox-base: Info
w10e-virtualbox-sysprep: Info
w10e-hyperv-sysprep: Info
Finished executing task: packer-info
...
```

This means that this configuration supports building an image with the native VirtualBox image format (`virtualbox-base`), and also a box to be used with Vagrant directly with the respective virtualization provider (`virtualbox-sysprep`, `hyperv-sysprep`). Under the hood, `virtualbox-sysprep` will simply reuse the output of `virtualbox-base`, so the build time can be reduced significantly.

Now, invoke the `restore` command with the name of the template you want to build to create resources required by Packer. For example, for the native VirtualBox image format, type the following command:

```powershell
$ .\ci.ps1 restore w10e-virtualbox-base
``` 

This will create the folder `build/w10e/virtualbox-base` in the root of your clone with all the files required to invoke the Packer build. This setup is self-contained, so you can adjust the parameters manually in `template.json` or the other resources and / or even copy it to a different machine and simply invoke `packer build template.json` there. Most of the time though, you just simply want to build as it is, as the templates are already preconfigured with some reasonable defaults. This can be done of course with the build script as well:

```powershell
$ .\ci.ps1 build virtualbox-ovf
```

This will trigger the Packer build process, which usually requires only patience. Depending on the selected configuration, a few minutes or hours later, the build artifacts will be created, in this case in the `artifacts/w10e/virtualbox-base` directory in the root of your clone. Native virtual machine images like this can now be directly imported into the respective virtualization provider.

### Building a Vagrant box

As mentioned above, based on Packer's support for starting builds from some virtualization providers' native image format, builds can reuse the artifacts of a previous build. To build the Vagrant box for the above configuration, type the following command:

```powershell
$ .\ci.ps1 build w10e-virtualbox-sysprep
```

Note that this will include restoring the build folder with the template and the related resources automatically and then invoking the build process in a single step. It will also reuse the output of the `w10e-virtualbox-base` build, so it does not need to do the same steps for a Vagrant box the original build already included (e.g. the core OS installation itself, installing Windows updates, etc.).

For Hyper-V this build chaining is not supported yet, though of course you can still build a Vagrant box, it's just that it will always start from scratch:

```powershell
$ .\ci.ps1 build w10e-hyperv-sysprep
```

As you can expect, for these samples the build artifacts will be created in the `artifacts/w10e` folder as well, this time under the `hyperv-sysprep` subfolder. You can use the standard options to [distribute them][VagrantDistribute] to be consumed in Vagrant.

[VagrantDistribute]: https://www.vagrantup.com/docs/boxes/base.html#distributing-the-box

### Chaining builds further

Similarly to the process above, you can use build chaining to build more complex Vagrant boxes. For example, the configuration for `Windows Server 2016 Standard` with `IIS` can be built like this:

```powershell
$ .\ci.ps1 build w16s-virtualbox-base
$ .\ci.ps1 build w16s-iis-virtualbox-base
$ .\ci.ps1 build w16s-iis-virtualbox-sysprep
```

Similar to the previous `w10e` sample, for this configuration the `w16s-iis-virtualbox-base` build will start from the output of `w16s-virtualbox-base` instead of starting with the core OS installation. Chanining builds like this has no limitations, so you can use this approach to build Vagrant boxes with any number of components very effectively.

Note that the script can invokethe build of the dependencies automatically, so for the previous example you can simply type:

```powershell
$ .\ci.ps1 build w16s-iis-virtualbox-sysprep --recursive=true
```

This will in turn invoke the `restore` and `build` stages for the `w16s-virtualbox-base` and `w16s-iis-virtualbox-base` images. By default, `restore` and `build` is skipped if the artifacts from a previous build exist. You can force the build to run again using the `rebuild` command instead.

For now, for Hyper-V you can simply start from scratch:

```powershell
$ .\ci.ps1 build w16s-iis-hyperv-sysprep
```

The build will take somewhat longer, but the result will be exactly the same as for the VirtualBox chained builds.

### Cleaning up

Though the `build` and `artifacts` folders are excluded by default from the repository, they can consume significant disk space. You can manually delete the folders, but the build script provides support for this as well:

```
$ .\ci.ps1 clean w16s-iis-virtualbox-sysprep
```

The build script parameter specifying the template to work with uses simple pattern matching on the names of the available templates, so you can use this to select multiple templates easily. For example, to clean up the artifacts of all the VirtualBox builds, you can type:

```powershell
$ .\ci.ps1 clean virtualbox
```

Omitting this parameter will apply the command to all the templates, so this command will clean up everything.

```powershell
$ .\ci.ps1 clean virtualbox
```

The pattern matching used for cleanup works with all the other commands (`info`, `restore`, `build`) mentioned earlier.

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
* [AWS]
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
[AWS]: https://aws.amazon.com/
[Chef]: https://chef.io/chef/
[Vagrant]: https://www.vagrantup.com/

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
