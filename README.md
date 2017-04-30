# Packer

**Contents** [Overview] | [Contributing] | [Resources]  

This repository contains [Packer] templates to build Windows boxes for .NET development purposes using [VirtualBox] and [Chef].

## Overview

See below the details of the boxes this repository builds.

[Overview]: #overview

### Notes

All the components the boxes use, including the core operating systems, are:

* Based on their publicly available versions.
  * You might need to provide your own license(s) (for example, a valid Windows license) to start or keep using them after their evaluation period expires.
  * Evaluation periods start when creating a machine for the first time from a given box, not when the box was built.
  * Machines built from the boxes can be destroyed and recreated.
* Installed using their latest available versions.
  * Their latest patches (for example, all the Windows Updates) are applied as well.

### Base boxes

The following boxes contain the core operating systems with the minimum configuration required to make Vagrant work and some commonly used tools and options for easier provisioning. They can be used for generic expirments on the respective platforms. All the other boxes below are based on these configurations as well.

* [Windows Server 2016 Standard][w16s]
* [Windows 10 Enterprise][w10e]

[w16s]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s
[w10e]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e

#### Operating system

* Evaluation version
* Administrator user with user name `vagrant` and password `vagrant` set to never expire  
* WinRM enabled
* UAC disabled
* Windows Updates disabled
* Windows Defender disabled
* Remote Desktop enabled
* Generalized with Sysprep

#### Tools

* Chocolatey
* 7zip
* Chef Client
* VirtualBox Guest Additions

#### Vagrant

* WinRM communicator
* 1 CPU
* 1 GB RAM
* Port forwarding for RDP to 33389 on the host

### Development boxes

The following boxes can be used for setting up development workstations.

* Windows Server 2016 Standard
  * [SQL Server 2014 Developer, Visual Studio 2015 Community][w16s-sql14d-vs15c]
  * [SQL Server 2014 Developer, Visual Studio 2010 Professional, Visual Studio 2015 Professional][w16s-sql14d-vs10p-vs15p]
* Windows 10 Enterprise
  * [SQL Server 2014 Developer][w10e-sql14d]
  * [SQL Server 2014 Developer, Visual Studio 2015 Community][w10e-sql14d-vs15c]
  * [SQL Server 2014 Developer, Visual Studio 2010 Professional, Visual Studio 2015 Professional][w10e-sql14d-vs10p-vs15p]

[w16s-sql14d-vs15c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-sql14d-vs15c
[w16s-sql14d-vs10p-vs15p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-sql14d-vs10p-vs15p

[w10e-sql14d]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e-sql14d
[w10e-sql14d-vs15c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e-sql14d-vs15c
[w10e-sql14d-vs10p-vs15p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w10e-sql14d-vs10p-vs15p

#### SQL Server 2014

* Developer edition
* Engine
* Management Studio

#### Visual Studio 2010

* Professional Evaluation version
* .NET Framework 3.5 and 4.0
* C# and F#
* Web Developer Tools
* SQL Server Data Tools

#### Visual Studio 2015

* Community / Professional Evaluation version
* .NET Framework 3.5 and 4.6.1
* C# and F#
* Web Developer Tools
* SQL Server Data Tools
* .NET Core Tools

### Hosting boxes

The following boxes can be used for hosting scenarios.

* Windows Server 2016 Standard
  * [IIS][w16s-iis]
  * [SQL Server 2014 Developer][w16s-sql14d]

[w16s-iis]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-iis
[w16s-sql14d]: https://atlas.hashicorp.com/gusztavvargadr/boxes/w16s-sql14d

#### IIS

* .NET Framework 3.5 and 4.6.1
* .NET Core Windows Server Hosting bundle

#### SQL Server 2014

* Developer edition
* Engine
* Management Studio

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

This repository borrows awesome ideas and solutions from the following sources:

* [Matt Wrock]
* [Jacqueline]
* [Joe Fitzgerald]
* [Boxcutter]

[Resources]: #resources

[Packer]: https://www.packer.io/
[VirtualBox]: https://www.virtualbox.org/
[Chef]: https://chef.io/chef/

[Matt Wrock]: https://github.com/mwrock/packer-templates
[Jacqueline]: https://github.com/jacqinthebox/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
