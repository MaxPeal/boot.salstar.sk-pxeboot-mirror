#!/bin/bash

set -e -x

if [ -z "$1" ]; then
  echo "Usage: $0 /dev/sdx1 [/dev/sdx2 [http://mirror.site/and/path]]"
  exit 1
fi

if [ -z "$3" ]; then
  MIRROR="http://ftp.upjs.sk/pub"
else
  MIRROR="$3"
fi

PART=$1
LIVE=$2
DEV=${PART:0:-1}
MOUNT=/mnt/t
FEDORA=17
FEDORA_PREV=$((FEDORA-1))
CENTOS=6
HDT=0.5.0
MEMTEST=4.20
PMAGIC=`grep item pmagic.ipxe | head -1 | cut -d" " -f2`
CFG=$MOUNT/syslinux/syslinux.cfg
DIR=$MOUNT/syslinux

copy() {
  # Skip copy if already present
  #FN=`basename $1`
  #if [ -d $1 ]; then
  #  if [ -f $1/$FN ]; then
  #    echo "$1/$FN already present, use force to overrwrite."
  #    return
  #  fi
  #fi
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

getmods() {
  echo `cd /usr/lib/grub/i386-pc; ls -1 $1.mod | sed 's/\\.mod//g'`
}

fedora_live() {
  #GRUBDIR=$MOUNT/boot/grub2/i386-pc
  GRUBDIR=$DIR/grub2
  CONFIG=$GRUBDIR/grub.cfg
  #grub2-mknetdir --net-directory=$MOUNT
  mkdir -p $GRUBDIR
  UUID=`dumpe2fs -h $LIVE 2>/dev/null | awk '/Filesystem UUID:/ { print $3 }'`
  (
    echo "set prefix=/boot/grub2"
    echo "search --no-floppy --fs-uuid --set=root $UUID"
    echo "normal /boot/grub2/grub.cfg"
  ) > $CONFIG
  DISK_MODS="pata scsi"
  USB_MODS="ahci ohci uhci usb usbms"
  FS_MODS="biosdisk ext2 btrfs xfs fat exfat ntfs"
  PART_MODS="part_msdos part_gpt"
  HW_MODS="at_keyboard usb_keyboard keystatus keylayouts sendkey"
  MODS="$DISK_MODS $USB_MODS $FS_MODS $PART_MODS $HW_MODS $USB_MODS"
  MODS="$MODS search normal"
  MODS="$MODS ls cat echo test gzio hexdump lspci help hdparm reboot"
  MODS="$MODS linux linux16 chain boot"
  MODS="$MODS net pxe pxechain"
  MODS="$MODS lvm `getmods '*raid*'`"
  MODS="$MODS serial loopback"
  grub2-mkimage -o $GRUBDIR/grub.0 -O i386-pc-pxe \
    --prefix='/boot/grub2' --config=$CONFIG $MODS
  rm -f $CONFIG
}

cfg_fedora_live() {
  if [ "$LIVE" ]; then
    echo "LABEL fedora_live"
    echo "  MENU LABEL ^Fedora $FEDORA Live"
    echo "  KERNEL grub2/grub.0"
  fi
}

umount $MOUNT 2>/dev/null || true
#mkfs.vfat $PART

mount $PART $MOUNT
[ -f $DIR ] && rm -f $DIR
mkdir -p $DIR
umount $MOUNT

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
MENU ROWS 14
MENU TABMSGROW 21
MENU CMDLINEROW 21
MENU TIMEOUTROW 23
TIMEOUT 300
TOTALTIMEOUT 9000

LABEL ipxe
  MENU DEFAULT
  MENU LABEL ^iPXE menu
  KERNEL ipxe.lkrn
  APPEND -

`cfg_fedora_live`

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
cfgos fedora$FEDORA x86_64 "^Fedora $FEDORA"

addos fedora$FEDORA i386 $RELEASES/$FEDORA/Fedora/i386/os
cfgos fedora$FEDORA i386 "Fedora $FEDORA"

addos fedora$FEDORA_PREV x86_64 $RELEASES/$FEDORA_PREV/Fedora/x86_64/os
cfgos fedora$FEDORA_PREV x86_64 "Fedora $FEDORA_PREV"

addos fedora$FEDORA_PREV i386 $RELEASES/$FEDORA_PREV/Fedora/i386/os
cfgos fedora$FEDORA_PREV i386 "Fedora $FEDORA_PREV"

RELEASES=$MIRROR/centos
addos centos$CENTOS x86_64 $RELEASES/$CENTOS/os/x86_64
cfgos centos$CENTOS x86_64 "^CentOS $CENTOS"

addos centos$CENTOS i386 $RELEASES/$CENTOS/os/i386
cfgos centos$CENTOS i386 "CentOS $CENTOS"

# Parted Magic
if [ "$PMAGIC" ]; then
  RELEASES=/home/ftp/pub/mirrors/pmagic
  for arch in x86_64 "" i486; do
    mkdir -p $DIR/pmagic/$arch
    if [ -f $DIR/pmagic/$arch/bzImage ]; then
      echo "Pmagic bzImage present, use force to overwrite."
    else
      copy $RELEASES/$arch/pmagic_pxe_$PMAGIC/pmagic/ $DIR/pmagic/$arch/
    fi
  done
  cfgpmagic x86_64 ^
  cfgpmagic ""
  cfgpmagic i486
fi

# Fedora Live (installed on HDD)
if [ "$LIVE" ]; then
  fedora_live
fi

find $DIR
df -h $DIR

umount $MOUNT

sync
echo 3 > /proc/sys/vm/drop_caches
sync

exit 0

# Update those on Live system:

yum remove -y selinux\* policycoreutils\*
yum install -y salpack roxterm hdparm \
  xorg-x11-drv-\* --exclude='*-devel'

sed -i 's/.none./usb.salstar.sk/' /etc/sysconfig/network
sed -i 's/defaults/noatime/' /etc/fstab
dracut -f

echo "hdparm -S 10 /dev/sda" >> /etc/rc.d/rc.local

#edit firewall
