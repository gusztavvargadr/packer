# Packer

**Contents** [Overview] | [Contributing] | [Resources] | [Images] | [Workstations]  

This repository contains [Packer] templates to build Windows-based [images] for [.NET development purposes][Overview] using [VirtualBox] and [Chef].

Check out the [workstations] using these images for some real-life usage samples with [Vagrant].

## Overview

This repository contains [Packer] templates to build Windows-based [images] for the following scenarios:

* Core [operating systems] for generic experiments with Windows 10 and Windows Server 2016.
* [.NET development] using Visual Studio 2010, 2015 and 2017.
* [.NET hosting] using IIS and SQL Server 2014.

The images are built for [VirtualBox] and are provisioned with [Chef]. All the components, including the core operating systems, share the following characteristics:

* They are based on their publicly available versions. You might need to provide your own license(s) (for example, a valid Windows license) to start or keep using them after their evaluation periods expire.
* They are installed using their latest available versions. The latest patches (for example, all the Windows Updates) are applied as well.
* Unless noted otherwise, they are installed using the default configuration options.

For example, you can use the images to build your [workstations] using [Vagrant].

[Overview]: #overview
[Images]: https://atlas.hashicorp.com/gusztavvargadr
[Workstations]: https://github.com/gusztavvargadr/workstations

### Operating systems

The following images contain the core operating systems with the minimum configuration required to make [Vagrant] work, and some of the commonly used tools and options for easier provisioning. They can be used for generic expirments on the respective platforms. All the other images below are based on these configurations as well.

* [Windows Server 2016 Standard][w16s]
* [Windows 10 Enterprise][w10e]

In the box:

* **Operating system configuration**
  * Administrator user with user name `vagrant` and password `vagrant` set to never expire
  * WinRM enabled
  * UAC disabled
  * Windows Updates disabled
  * Windows Defender disabled
  * Remote Desktop enabled
  * Generalized with Sysprep
* **Tools installed**
  * Chocolatey
  * 7zip
  * Chef Client
  * VirtualBox Guest Additions
* **Vagrant default options**
  * WinRM communicator
  * 1 CPU
  * 1 GB RAM
  * Port forwarding for RDP to 33389 on the host

[Operating systems]: #operating-systems
[w16s]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s
[w10e]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e

### .NET development

The following images can be used for setting up .NET development [workstations].

* Windows Server 2016 Standard
  * [Visual Studio 2010 Professional][w16s-vs10p]
  * [Visual Studio 2015 Community][w16s-vs15c]
  * [Visual Studio 2015 Professional][w16s-vs15p]
  * [Visual Studio 2017 Community][w16s-vs17c]
  * [Visual Studio 2017 Professional][w16s-vs17p]

In the box:

* **Visual Studio 2010**
  * .NET Framework 3.5, 4.0
  * C# and F#
  * Web Developer Tools
  * SQL Server Data Tools
  * .NET Core Tools
* **Visual Studio 2015 and 2017**
  * .NET Framework 3.5, 4.0 and 4.6.2
  * C# and F#
  * Web Developer Tools
  * SQL Server Data Tools
  * .NET Core Tools

[.NET development]: #net-development
[w16s-vs10p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs10p
[w16s-vs15c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs15c
[w16s-vs15p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs15p
[w16s-vs17c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs17c
[w16s-vs17p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-vs17p

### .NET hosting

The following images can be used for .NET hosting scenarios.

* Windows Server 2016 Standard
  * [IIS][w16s-iis]
  * [SQL Server 2014 Developer][w16s-sql14d]

In the box:

* **IIS**
  * .NET Framework 3.5 and 4.6.1
  * .NET Core Windows Server Hosting bundle
* **SQL Server 2014**
  * Database Engine
  * Management Studio

[.NET hosting]: #net-hosting
[w16s-iis]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-iis
[w16s-sql14d]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-sql14d

## Contributing

Any feedback, [issues] or [pull requests] are welcome and greatly appreciated.

[Contributing]: #contributing

[Issues]: https://github.com/gusztavvargadr/packer/issues
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls

## Resources

This repository could not exist without the following great tools:

* [Packer]
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
[VirtualBox]: https://www.virtualbox.org/
[Chef]: https://chef.io/chef/
[Vagrant]: https://www.vagrantup.com/

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
