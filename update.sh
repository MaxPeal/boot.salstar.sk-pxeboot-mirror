#!/bin/sh

# creating logo.16 image:
# gm convert solar.png -background black -colors 16 -scale 640x400'!' /tmp/solar.pnm
# ppmtolss16 < /tmp/solar.pnm > logo.16

if [ -z "$1" ]; then
  echo "Usage: ./$0 VERSION [PORT]"
  echo "   or: ./$0 iVERSION [PORT]"
  echo "Example: ./$0 i16 12345"
  echo "         ./$0 17-Aplha"
  echo "         ./$0 centos6"
  echo "         ./$0 icentos6"
  exit 1
fi

if [ "$2" ]; then
  port=:$2
fi

if echo $1 | grep -q '[-.]' > /dev/null; then
  # test version
  TEST="test/"
else
  # final
  TEST=""
fi

if echo $1 | grep -q 'i' > /dev/null; then
  ARCH="i386"
  VER="`echo $1 | sed -e 's/^i//'`"
  BITS="32bit"
else
  ARCH="x86_64"
  VER="$1"
  BITS="64bit"
fi

if echo $VER | grep -q '^centos' > /dev/null; then
  OS=CentOS
  OSCFG=centos
  PREFIX=centos
  VER="`echo $1 | sed -e 's/^[centosxi]*//'`"
  #URL="ftp://ftp.linux.cz/pub/linux/centos/$VER/os/i386"
  URL="http://ftp.energotel.sk/pub/linux/centos/$VER/os/$ARCH"
  DIR="`dirname $BITS/$VER`/$PREFIX$VER"
elif echo $VER | grep -q '^devel' > /dev/null; then
  OS=Fedora
  OSCFG=fedora
  PREFIX=""
  URL="http://ftp.upjs.sk/pub/fedora/linux/development/$ARCH/os/"
else
  OS=Fedora
  OSCFG=fedora
  PREFIX=""
  URL="http://ftp.upjs.sk$port/pub/fedora/linux/releases/$TEST$VER/Fedora/$ARCH/os"
fi

DIR="$BITS/$VER"
CFG=pxelinux.cfg/$OSCFG

mkdir -p $DIR
cd $DIR
rm -f vmlinuz initrd.img
wget $URL/isolinux/vmlinuz $URL/isolinux/initrd.img
cd - >/dev/null

if grep -q "^LABEL $1\$" $CFG >/dev/null; then
echo "Boot menu line already added for $1, skipping update."
else
cat << EOF >> $CFG

LABEL $1
MENU LABEL ${BITS}bit $OS $VER
KERNEL $DIR/vmlinuz
APPEND nodhcp initrd=$DIR/initrd.img method=$URL
EOF
fi
