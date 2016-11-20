# Packer

**Quick links** [Vagrant environments] | [Vagrant boxes]  
**Contents** [Overview] | [Contributing] | [Resources]  

This repository contains [Packer] templates to build [Vagrant] boxes for .NET development purposes.

If you are interested in setting up your (virtual) development environments instead, check out the [Vagrant environments] repo.

[Vagrant environments]: https://github.com/gusztavvargadr/vagrant

## Overview

This repository builds the following boxes. See [all of them][Vagrant boxes] in [Atlas].

[Overview]: #overview
[Vagrant boxes]: https://atlas.hashicorp.com/gusztavvargadr

### Windows 10

Id | SQL Server 2014 | Visual Studio 2010 | Visual Studio 2015
:--- | :--- | :--- | :---
[windows10ee] | :no_entry: | :no_entry: | :no_entry:
[windows10ee-vs2015c] | :no_entry: | :no_entry: | :white_check_mark: Community
[windows10ee-vs2015p] | :no_entry: | :no_entry: | :white_check_mark: Professional
[windows10ee-vs2010p] | :no_entry: | :white_check_mark: Professional | :no_entry:
[windows10ee-vs2010p-vs2015p] | :no_entry: | :white_check_mark: Professional | :white_check_mark: Professional
[windows10ee-sql2014de] | :white_check_mark: Developer | :no_entry: | :no_entry:
[windows10ee-sql2014de-vs2015c] | :white_check_mark: Developer | :no_entry: | :white_check_mark: Community
[windows10ee-sql2014de-vs2015p] | :white_check_mark: Developer | :no_entry: | :white_check_mark: Professional
[windows10ee-sql2014de-vs2010p] | :white_check_mark: Developer | :white_check_mark: Professional | :no_entry:
[windows10ee-sql2014de-vs2010p-vs2015p] | :white_check_mark: Developer | :white_check_mark: Professional | :white_check_mark: Professional

#### Box contents

All of the above boxes share the following baseline confguration:

* Windows 10 Enterprise Evaluation
  * User name / Password: vagrant / vagrant 
  * Windows Updates disabled
  * Windows Defender disabled
  * UAC disabled
  * Remote Desktop enabled
  * Generalized with Sysprep
* VirtualBox Guest Additions
* Chocolatey
* Chef Client
* 7zip
* Boxstarter
* Vagrant defaults
  * 1 CPU
  * 1 GB RAM
  * Port forwarding for RDP to 33389 on the host

In addition, the components marked with :white_check_mark: add the features as below:

* SQL Server 2014
  * Developer: SQL Server 2014 Developer Edition with Service Pack 2
* Visaul Studio 2010
  * Professional: Visual Studio 2010 Professional with Service Pack 1
* Visual Studio 2015
  * Community: Visual Studio 2015 Community with Update 3
  * Professional: Visual Studio 2015 Professional with Update 3

See the [Vagrant environments] repo for usage samples.

[windows10ee]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee
[windows10ee-vs2015c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-vs2015c
[windows10ee-vs2015p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-vs2015p
[windows10ee-vs2010p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-vs2010p
[windows10ee-vs2010p-vs2015p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-vs2010p-vs2015p
[windows10ee-sql2014de]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-sql2014de
[windows10ee-sql2014de-vs2015c]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-sql2014de-vs2015c
[windows10ee-sql2014de-vs2015p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-sql2014de-vs2015p
[windows10ee-sql2014de-vs2010p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-sql2014de-vs2010p
[windows10ee-sql2014de-vs2010p-vs2015p]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows10ee-sql2014de-vs2010p-vs2015p

### Windows Server 2012 R2

Id | IIS | SQL Server 2014
:--- | :--- | :---
[windows2012r2se] | :no_entry: | :no_entry:
[windows2012r2se-sql2014de] | :no_entry: | :white_check_mark: Developer
[windows2012r2se-iis] | :white_check_mark: | :no_entry:
[windows2012r2se-iis-sql2014de] | :white_check_mark: | :white_check_mark: Developer

#### Box contents

All of the above boxes share the following baseline confguration:

* Windows Server 2012 R2 Standard Evaluation
  * User name / Password: vagrant / vagrant 
  * Windows Updates disabled
  * UAC disabled
  * Remote Desktop enabled
  * Generalized with Sysprep
* VirtualBox Guest Additions
* Chocolatey
* Chef Client
* 7zip
* Boxstarter
* Vagrant defaults
  * 1 CPU
  * 1 GB RAM
  * Port forwarding for RDP to 33389 on the host

In addition, the components marked with :white_check_mark: add the features as below:

* SQL Server 2014
  * Developer: SQL Server 2014 Developer Edition with Service Pack 2
* IIS
  * .NET Framework 3.5, .NET Framework 4.6.1, IIS 8.5

See the [Vagrant environments] repo for usage samples.

[windows2012r2se]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows2012r2se
[windows2012r2se-sql2014de]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows2012r2se-sql2014de

## Contributing

Any feedback, [issues] or [pull requests] are welcome and greatly appreciated.

[Contributing]: #contributing
[Issues]: https://github.com/gusztavvargadr/packer/issues
[Pull requests]: https://github.com/gusztavvargadr/packer/pulls

## Resources

This repository could not exist without the following great tools:

* [Packer]
* [Vagrant]
* [Atlas]

This repository borrows awesome ideas and solutions from the following sources:

* [Matt Wrock]
* [Joe Fitzgerald]
* [Boxcutter]

[Resources]: #resources
[Packer]: https://www.packer.io/
[Vagrant]: https://www.vagrantup.com/
[Atlas]: https://www.hashicorp.com/atlas.html
[Matt Wrock]: https://github.com/mwrock/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows
