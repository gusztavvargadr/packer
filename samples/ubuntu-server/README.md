# Packer samples for Ubuntu Server

This folder contains Packer templates for building `Ubuntu Server` images.

## Overview

See the links below for the details of the available templates:

- [22.04 LTS](#2204-lts)
- [20.04 LTS](#2004-lts)

## 22.04 LTS

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/ubuntu-server-2204-lts) | [Vagrant alias](https://app.vagrantup.com/gusztavvargadr/boxes/ubuntu-server)  

The template has the following settings:

- Ubuntu Server `22.04 LTS`
- [Core settings](#core)

## 20.04 LTS

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/ubuntu-server-2004-lts)  

The template has the following settings:

- Ubuntu Server `20.04 LTS`
- [Core settings](#core)

## Core

All the templates above share the following settings:

- OpenSSH Server
- Vagrant
  - User `vagrant` with password `vagrant` and Vagrant's insecure key
  - 2 vCPUs
  - 2 GB RAM
