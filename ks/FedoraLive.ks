# SAL's Live CD

# LiveUSB creation:
# LANG=C setarch i686 livecd-creator -v -c FedoraLive.ks
# WITH_HOME="--home-size-mb 512 --unencrypted-home"
# livecd-iso-to-disk --msdos --multi --noverify $WITH_HOME \
#   livecd-FedoraLive-*.iso /dev/sdx1

%include /usr/share/spin-kickstarts/fedora-live-desktop.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks

repo --name=rpmfusion-free --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch
repo --name=rpmfusion-free-updates --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-$releasever&arch=$basearch
repo --name=rpmfusion-nonfree --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch
repo --name=rpmfusion-nonfree-updates --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch
repo --name=Salstar --baseurl=http://www.salstar.sk/pub/fedora/$releasever/$basearch/

# Slovak support
lang sk_SK.UTF-8
timezone Europe/Bratislava

# packages
%include http://boot.salstar.sk/ks/live.pkgs

%post
systemctl --no-reload enable chronyd.service 2> /dev/null || :

sed -i 's/liveuser/ondrejj/' /etc/rc.d/init.d/livesys
sed -i 's/Live System User/SAL/' /etc/rc.d/init.d/livesys
#sed -i 's/ useradd / useradd -u 500 -g 500 /' /etc/rc.d/init.d/livesys

%end
