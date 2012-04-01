#!/bin/sh

ARCH=i386
BITS=32
DIR=/raid0/ftp/pub/fedora/linux/development/$ARCH/os/isolinux

cp -af $DIR/vmlinuz $DIR/initrd.img ${BITS}bit/devel/
