# Desktop with customizations to fit in a CD (package removals, etc.)
# Maintained by the Fedora Desktop SIG:
# http://fedoraproject.org/wiki/SIGs/Desktop
# mailto:desktop@lists.fedoraproject.org

%include /usr/share/spin-kickstarts/fedora-live-desktop.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks

%packages
# First, no office
-libreoffice-*
-planner

# Drop the Java plugin
-icedtea-web
-java-1.6.0-openjdk

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

@DNS Name Server
@Slovak Support
roxterm

# Fonts
-@Fonts
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

%end

%post
%end
