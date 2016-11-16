# Packer

**Quick links** [Vagrant samples] | [Vagrant boxes]  
**Contents** [Overview] | [Resources]  

This repository contains [Packer] templates to build [Vagrant] base boxes for .NET development purposes.

Check the [Vagrant samples] repo for the details of setting up your own environments based on them.

[Vagrant samples]: https://github.com/gusztavvargadr/vagrant 

## Overview

This repository is used to build the following boxes. See [all their versions][Vagrant boxes] in [Atlas].

[Overview]: #overview
[Vagrant boxes]: https://atlas.hashicorp.com/gusztavvargadr

### Windows 10 Enterprise Evaluation

Id | SQL Server 2014 | Visual Studio 2010 | Visual Studio 2015
--- | --- | --- | ---
[windows10ee] | :no_entry: | :no_entry: | :no_entry:
[windows10ee-vs2015c] | :no_entry: | :no_entry: | :white_check_mark: Community
[windows10ee-vs2015p] | :no_entry: | :no_entry: | :white_check_mark: Professional
[windows10ee-vs2010p] | :no_entry: | :white_check_mark: Professional | :no_entry:
[windows10ee-vs2010p-vs2015p] | :no_entry: | :white_check_mark: Professional | :white_check_mark: Professional
[windows10ee-sql214de] | :white_check_mark: Developer | :no_entry: | :no_entry:

[windows10ee]: src/windows10ee
[windows10ee-vs2010p]: src/windows10ee-vs2010p
[windows10ee-vs2010p-vs2015p]: src/windows10ee-vs2010p-vs2015p
[windows10ee-vs2015c]: src/windows10ee-vs2015c
[windows10ee-vs2015p]: src/windows10ee-vs2015p
[windows10ee-sql214de]: src/windows10ee-sql214de

### Windows Server 2012 R2

Id | SQL Server 2014
--- | ---
[windows2012r2se] | :no_entry:
[windows2012r2se-sql214de] | :white_check_mark: Developer

[windows2012r2se]: src/windows2012r2se
[windows2012r2se-sql214de]: src/windows2012r2se-sql214de

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
[Matt Wrock]: https://github.com/mwrock/packer-templates
[Joe Fitzgerald]: https://github.com/joefitzgerald/packer-windows
[Boxcutter]: https://github.com/boxcutter/windows

[Packer]: https://www.packer.io/
[Vagrant]: https://www.vagrantup.com/
[Atlas]: https://www.hashicorp.com/atlas.html
