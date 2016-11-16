# Windows Server 2012 R2 Standard Evaluation

**Quick links** [Home] | [Vagrant box]  

This folder contains the [Packer] template to build a [Vagrant] base box for Windows Server 2012 R2 Standard Evaluation.

This box contains the following components:

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

See [all the versions][Vagrant box] in [Atlas].

[Home]: ../../README.md
[Vagrant box]: https://atlas.hashicorp.com/gusztavvargadr/boxes/windows2012r2se

[Packer]: https://www.packer.io/
[Vagrant]: https://www.vagrantup.com/
[Atlas]: https://www.hashicorp.com/atlas.html
