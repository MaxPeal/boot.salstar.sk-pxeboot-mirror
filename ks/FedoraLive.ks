# SAL's Live CD

# LiveUSB creation:
# LANG=C setarch i686 livecd-creator -v -c ks/FedoraLive.ks
# livecd-iso-to-disk \
#  --msdos --multi --noverify --home-size-mb 512 --unencrypted-home \
#  livecd-FedoraLive-201206151415.iso /dev/sdx1

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

# new repos

%packages
# First, no office
-libreoffice-*
-planner

# Drop the Java plugin
-icedtea-web
-java-*-openjdk

# No printing
-foomatic-db-ppds
-foomatic
-man-pages*

# Help and art can be big, too
-gnome-user-docs
-evolution-help
-gnome-games-help
-desktop-backgrounds-basic
-*backgrounds-extras

-anaconda

# Drop some system-config things
-system-config-boot
-system-config-language
-system-config-network
-system-config-rootpassword
-system-config-services
-policycoreutils-gui

# SAL's changes

dhclient
yum
yum-utils
openssh-clients
openssh-server
screen
wget
rsync
which
iptables
joe
mc
parted
-sendmail

elinks
mutt
pv
hdparm

@DNS Name Server
#@Slovak Support
@slovak-support
-m17n*
-scim*
-ibus*
-iok*
roxterm

# Fonts
-@Fonts
# don't install unnecessary fonts
#-abyssinica-fonts
-cjkuni*fonts*
-jomolhari*fonts*
-kacst*fonts*
-khmeros*fonts*
-lklug*fonts*
-lohit*fonts*
#-padauk*fonts*
-paktype*fonts*
-smc*fonts*
-stix*fonts*
-thai*fonts*
#-un-core-fonts-dotum
-vlgothic*fonts*
dejavu-sans-fonts
dejavu-sans-mono-fonts
dejavu-serif-fonts
liberation-mono-fonts
liberation-sans-fonts
liberation-serif-fonts

-@Administration Tools

@System Tools
-BackupPC
-jigdo
-prelink
-sssd
-ypbind
-rpcbind
-nfs-utils

# GNOME shell extensions
gnome-tweak-tool
gnome-shell-extension-native-window-placement
gnome-shell-extension-weather
gnome-shell-extension-alternative-status-menu
gnome-shell-extension-cpu-temperature
gnome-shell-extension-alternate-tab
gnome-shell-extension-system-monitor-applet

# rpmfusion packages
rpmfusion-free-release
rpmfusion-nonfree-release
vlc
python-vlc
#mplayer
gstreamer-ffmpeg
gstreamer-plugins-bad
gstreamer-plugins-bad-nonfree
gstreamer-plugins-ugly

# svplayer dependencies
git

%end

%post
%end
