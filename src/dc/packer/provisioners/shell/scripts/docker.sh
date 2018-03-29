#!/bin/sh -eux

curl -L https://get.docker.com/ | bash
usermod -aG docker vagrant
