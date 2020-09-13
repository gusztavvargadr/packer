#!/bin/sh

mkisofs -J -l -R -V "Packer" -iso-level 4 -o $1.iso $1
