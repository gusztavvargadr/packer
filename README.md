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

The following boxes be used for generic expirments on the respective platforms.

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

The boxes contain the respective Visual Studio version with the commonly used options and are based on the core images of the [operating sytems].

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

The boxes contain the respective hosting tools with the default configuration are based on the core images of the [operating sytems].

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

The rest of this document covers the details of building Vagrant boxes using Packer. If you are intested in using the already available [boxes][Vagrant boxes], check out the [workstation] samples for some common usage scenarios.

<!--
TODO: prerequisites - packer, env vars, chef, windows
TODO: tool knowledge
TODO: sample
-->

[Getting started]: #getting-started

[Workstations]: https://github.com/gusztavvargadr/workstations

## Usage

<!--
TODO: cake usage details
TODO: custom build samples
-->

[Usage]: #usage

## Contributing

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
