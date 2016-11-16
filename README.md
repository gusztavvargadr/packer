# Packer

**Quick links** [Vagrant samples] | [Vagrant boxes]  
**Contents** [Overview] | [Resources]  

This repository contains [Packer] templates to build [Vagrant] base boxes for .NET development purposes.

Check the [Vagrant samples] repo for the details of setting up your own environments based on them.

[Vagrant samples]: https://github.com/gusztavvargadr/vagrant 

## Overview

This repository is used to build the following boxes:

* Windows 10
  * [Enterprise Evaluation][windows10ee]
  * [Enterprise Evaluation with Visual Studio 2010 Professional][windows10ee-vs2010p]
  * [Enterprise Evaluation with Visual Studio 2010 Professional and Visual Studio 2015 Professional][windows10ee-vs2010p-vs2015p]
  * [Enterprise Evaluation with Visual Studio 2015 Community][windows10ee-vs2015c]
  * [Enterprise Evaluation with Visual Studio 2015 Professional][windows10ee-vs2015p]
* Windows Server 2012 R2
  * [Standard Evaluation][windows2012r2se]

See [all their versions][Vagrant boxes] in [Atlas].

[Overview]: #overview
[windows10ee]: src/windows10ee
[windows10ee-vs2010p]: src/windows10ee-vs2010p
[windows10ee-vs2010p-vs2015p]: src/windows10ee-vs2010p-vs2015p
[windows10ee-vs2015c]: src/windows10ee-vs2015c
[windows10ee-vs2015p]: src/windows10ee-vs2015p
[windows2012r2se]: src/windows2012r2se
[Vagrant boxes]: https://atlas.hashicorp.com/gusztavvargadr

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
