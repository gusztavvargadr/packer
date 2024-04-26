# Packer samples for Windows Server

This folder contains Packer templates for building `Windows Server` images.

## Overview

See the links below for the details of the available images:

- [2022 Standard](#2022-standard)
- [2022 Standard Core](#2022-standard-core)
- ~~[2019 Standard](#2019-standard) Deprecated~~
- ~~[2019 Standard Core](#2019-standard-core) Deprecated~~
- [Insider Preview Standard](#insider-preview-standard)
- [Insider Preview Standard Core](#insider-preview-standard-core)

## 2022 Standard

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-2022-standard) | [Vagrant alias](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server)  

The template has the following settings:

- Windows Server `2022 Standard Evaluation`
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM

## 2022 Standard Core

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-2022-standard-core) | [Vagrant alias](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-core)  

The template has the following settings:

- Windows Server `2022 Standard Core Evaluation`
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM

## 2019 Standard

**This template is ~~deprecated~~. Please use one of the other templates.**

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-2019-standard)  

The template has the following settings:

- Windows Server `2019 Standard Evaluation`
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM

## 2019 Standard Core

**This template is ~~deprecated~~. Please use one of the other templates.**

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-2019-standard-core)  

The template has the following settings:

- Windows Server `2019 Standard Core Evaluation`
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM

## Insider Preview Standard

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-insider-preview-standard)  

The template has the following settings:

- Windows Server `Insider Preview Standard`
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM

## Insider Preview Standard Core

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/windows-server-insider-preview-standard-core)  

The template has the following settings:

- Windows Server `Insider Preview Standard Core`
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM
