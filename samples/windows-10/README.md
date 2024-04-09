# Packer samples for Windows 10

This folder contains Packer templates for building `Windows 10` images.

## Overview

See the links below for the details of the available images:

- [22H2 Enterprise](#22h2-enterprise)
- [21H2 Enterprise](#21h2-enterprise)
- [21H2 Enterprise LTSC](#21h2-enterprise-ltsc)
- ~~[1809 Enterprise LTSC](#1809-enterprise-ltsc) Deprecated~~

## 22H2 Enterprise

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-10-22h2-enterprise) | [Vagrant alias](https://app.vagrantup.com/gusztavvargadr/boxes/windows-10)  

The template has the following settings:

- Windows 10 `Version 22H2 Enterprise Evaluation`
- [Core settings](#core)

## 21H2 Enterprise

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-10-21h2-enterprise)  

The template has the following settings:

- Windows 10 `Version 21H2 Enterprise Evaluation`
- [Core settings](#core)

## 21H2 Enterprise LTSC

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-10-21h2-enterprise-ltsc)  

The template has the following settings:

- Windows 10 `Version 21H2 Enterprise LTSC Evaluation`
- [Core settings](#core)

## 1809 Enterprise LTSC

**This template is ~~deprecated~~. Please use one of the other templates.**

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-10-1809-enterprise-ltsc)  

The template has the following settings:

- Windows 10 `Version 1809 Enterprise LTSC Evaluation`
- [Core settings](#core)

## Core

All the templates above share the following settings:

- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 4 GB RAM
