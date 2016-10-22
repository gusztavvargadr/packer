# Packer

**Quick links** [Boxes]  
**Contents** [Overview] | [Resources]  

This repository contains [Packer] templates to build [Vagrant] base boxes for .NET development purposes.

## Overview

This repository is used to build the following boxes:

* [Windows 10][windows10ee]
* Windows Server 2012 R2
  * [Standard Evaluation][windows2012r2se]
  * [Standard Evaluation with Visual Studio 2015 Community][windows2012r2se-vs2015c]
  * [Standard Evaluation with Visual Studio 2015 Professional][windows2012r2se-vs2015p]

See [all the boxes][Boxes] in [Atlas].

[Overview]: #overview
[windows10ee]: windows10ee
[windows2012r2se]: windows2012r2se
[windows2012r2se-vs2015c]: windows2012r2se-vs2015c
[windows2012r2se-vs2015p]: windows2012r2se-vs2015p
[Boxes]: https://atlas.hashicorp.com/gusztavvargadr

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
