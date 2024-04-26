# Packer samples for SQL Server

This folder contains Packer templates for building `SQL Server` images.

## Overview

See the links below for the details of the available images:

- [2019 Developer Windows Server](#2019-developer-windows-server)
- [2019 Developer Windows Server Core](#2019-developer-windows-server-core)

## 2019 Developer Windows Server

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/sql-server-2019-developer-windows-server) | [Vagrant alias](https://app.vagrantup.com/gusztavvargadr/boxes/sql-server)  

The template has the following settings:

- [Windows Server `2022 Standard`](../windows-server/README.md#2022-standard)
- SQL Server `2019 Developer`
  - Database Engine
      - Windows Authentication with user `vagrant`
      - SQL Server Authentication with user `sa` and password `Vagrant42`
  - FullText
- SQL Server Management Studio

## 2019 Developer Windows Server Core

[Vagrant box](https://app.vagrantup.com/gusztavvargadr/boxes/sql-server-2019-developer-windows-server-core)  

The template has the following settings:

- [Windows Server `2022 Standard Core`](../windows-server/README.md#2022-standard-core)
- SQL Server `2019 Developer`
  - Database Engine
      - Windows Authentication with user `vagrant`
      - SQL Server Authentication with user `sa` and password `Vagrant42`
  - FullText
