# SAL's Live CD

# LiveUSB creation:
# LANG=C setarch i686 livecd-creator -v -c FedoraLive.ks
# WITH_HOME="--home-size-mb 512 --unencrypted-home"
# livecd-iso-to-disk --msdos --multi --noverify $WITH_HOME \
#   livecd-FedoraLive-*.iso /dev/sdx1

%include /usr/share/spin-kickstarts/fedora-live-desktop.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks

part / --size 6144 --fstype ext4

# Fedora
repo --name=fedora --mirrorlist=http://www.salstar.sk/download/mirrors/$basearch/fedora-$releasever?arch=$basearch
repo --name=updates --mirrorlist=http://www.salstar.sk/download/mirrors/updates-released-$releasever?arch=$basearch
#repo --name=updates-testing --baseurl=http://ftp.upjs.sk/pub/fedora/linux/updates/testing/$releasever/$basearch/
#repo --name=rawhide --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch

# rpmfusion
#repo --name=rpmfusion-free --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch
#repo --name=rpmfusion-free-updates --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-$releasever&arch=$basearch
#repo --name=rpmfusion-nonfree --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch
#repo --name=rpmfusion-nonfree-updates --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch
repo --name=rpmfusion-free --mirrorlist=http://www.salstar.sk/download/mirrors/rpmfusion-free-$releasever?arch=$basearch
repo --name=rpmfusion-free-updates --mirrorlist=http://www.salstar.sk/download/mirrors/rpmfusion-free-updates-released-$releasever?arch=$basearch
repo --name=rpmfusion-nonfree --mirrorlist=http://www.salstar.sk/download/mirrors/rpmfusion-nonfree-$releasever?arch=$basearch
repo --name=rpmfusion-nonfree-updates --mirrorlist=http://www.salstar.sk/download/mirrors/rpmfusion-nonfree-updates-released-$releasever?arch=$basearch
repo --name=salstar --mirrorlist=http://www.salstar.sk/download/mirrors/salstar-fedora-$releasever?arch=$basearch

# Slovak support
lang sk_SK.UTF-8
timezone Europe/Bratislava

# No selinux required
selinux --disabled

# packages
%include http://boot.salstar.sk/ks/live.pkgs

%post
systemctl --no-reload enable chronyd.service 2> /dev/null || :
systemctl --no-reload enable systemd-ask-password-wall.service 2> /dev/null || :
for service in tcsd cups \
               abrtd abrt-ccpp abrt-oops abrt-vmcore abrt-xorg \
               ksm ksmtuned spice-vdagentd
do
  systemctl --no-reload disable $service.service 2> /dev/null || :
done

sed -i~ -f - /etc/rc.d/init.d/livesys << EOF
  /^livedir=/aLIVEUSER=liveuser\n\
LIVENAME="Live System User"
  /^# add fedora user/a[\ -r\ /home/.rcinit\ ]\ &&\ .\ /home/.rcinit
  s/\([^~]\)liveuser/\1\$LIVEUSER/g
  s/Live System User/\$LIVENAME/
EOF

%end
