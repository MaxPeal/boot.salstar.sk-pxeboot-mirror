#!/bin/bash

set -e -x

if [ -z "$1" ]; then
  echo "Usage: $0 /dev/sdx1 [http://mirror.site/and/path]"
  exit 1
fi

if [ -z "$2" ]; then
  MIRROR="http://ftp.upjs.sk/pub"
else
  MIRROR="$2"
fi

PART=$1
DEV=${PART:0:-1}
MOUNT=/mnt/t
FEDORA=16
FEDORAM1=$((FEDORA-1))
CENTOS=6
HDT=0.5.0
MEMTEST=4.20
PMAGIC=2012_05_14
CFG=$MOUNT/syslinux/syslinux.cfg
DIR=$MOUNT/syslinux

copy() {
  rsync -crtvP --inplace "$@"
}

addos() {
  NAME=$1
  ARCH=$2
  URL=$3
  mkdir -p $DIR/$NAME/$ARCH
  pushd $DIR/$NAME/$ARCH/
  for i in initrd.img vmlinuz isolinux.bin isolinux.cfg boot.msg memtest splash.png vesamenu.c32; do
    wget -c $URL/isolinux/$i || echo "File missing: $i"
  done
  # update root=live: path
  sed -i "s|root=live:CDLABEL=[^ ]*|repo=$URL|" isolinux.cfg
  popd
}

cfgos() {
cat >> $CFG << EOF
LABEL $1$2
  MENU LABEL $3 $2
  CONFIG $1/$2/isolinux.cfg $1/$2/
EOF
}

cfgpmagic() {
cat >> $CFG << EOF
LABEL pmagic$1
  MENU LABEL $2Parted Magic $PMAGIC $1
  KERNEL pmagic/$1/bzImage
  INITRD pmagic/$1/initrd.img
  APPEND edd=off load_ramdisk=1 prompt_ramdisk=0 rw vga=normal loglevel=9 max_loop=256 firewall
EOF
}

umount /mnt/t || true
#mkfs.vfat $PART

# install syslinux
syslinux --install --mbr --active --directory syslinux ${PART}
# copy boot sector
dd if=/usr/share/syslinux/mbr.bin of=${DEV} conv=notrunc bs=440 count=1

mount $PART $MOUNT

# IPXE menu
copy /usr/share/syslinux/menu.c32 $MOUNT/syslinux
copy /usr/share/syslinux/memdisk $MOUNT/syslinux
wget -c -O $MOUNT/syslinux/hdt.iso \
  http://hdt-project.org/raw-attachment/wiki/hdt-$HDT/hdt-$HDT.iso
copy /boot/memtest86+-${MEMTEST} $MOUNT/syslinux/memtest
cat > $CFG << EOF
DEFAULT menu.c32
PROMPT 0

MENU TITLE SAL's BOOT MENU
TIMEOUT 300
TOTALTIMEOUT 9000

LABEL ipxe
  MENU DEFAULT
  MENU LABEL ^iPXE menu
  KERNEL ipxe.lkrn
  APPEND -

LABEL hdt
  MENU LABEL ^HDT
  KERNEL memdisk
  INITRD hdt.iso
  APPEND iso

LABEL memtest
  MENU LABEL ^MemTest86+
  KERNEL memtest
  APPEND -

EOF
wget --no-check-certificate -O $MOUNT/syslinux/ipxe.lkrn \
  https://boot.salstar.sk/ipxe/ipxe.lkrn
#cp -a ~ondrejj/svn/pxeboot/ipxe/ipxe.lkrn $MOUNT/syslinux/

RELEASES=$MIRROR/fedora/linux/releases
addos fedora$FEDORA x86_64 $RELEASES/$FEDORA/Fedora/x86_64/os
cfgos fedora$FEDORA x86_64 "^Fedora $FEDORA x86_64"

addos fedora$FEDORA i386 $RELEASES/$FEDORA/Fedora/i386/os
cfgos fedora$FEDORA i386 "Fedora $FEDORA i386"

addos fedora$FEDORAM1 x86_64 $RELEASES/$FEDORAM1/Fedora/x86_64/os
cfgos fedora$FEDORAM1 x86_64 "Fedora $FEDORAM1 x86_64"

addos fedora$FEDORAM1 i386 $RELEASES/$FEDORAM1/Fedora/i386/os
cfgos fedora$FEDORAM1 i386 "Fedora $FEDORAM1 i386"

RELEASES=$MIRROR/centos
addos centos$CENTOS x86_64 $RELEASES/$CENTOS/os/x86_64
cfgos centos$CENTOS x86_64 "^CentOS $CENTOS x86_64"

addos centos$CENTOS i386 $RELEASES/$CENTOS/os/i386
cfgos centos$CENTOS i386 "CentOS $CENTOS i386"

# Parted Magic
RELEASES=/home/ftp/pub/mirrors/pmagic
for arch in x86_64 "" i486; do
  mkdir -p $DIR/pmagic/$arch
  copy $RELEASES/$arch/pmagic_pxe_$PMAGIC/pmagic/ $DIR/pmagic/$arch/
done
cfgpmagic x86_64 ^
cfgpmagic ""
cfgpmagic i486

find $DIR
df -h $DIR

umount $MOUNT

sync
echo 3 > /proc/sys/vm/drop_caches
sync
