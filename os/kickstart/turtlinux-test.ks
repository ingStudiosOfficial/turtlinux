repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

url --url="https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/"

clearpart --all --initlabel

network --bootproto=dhcp --device=link --activate

bootloader --append="selinux=0"

rootpw --plaintext turtlinux

part / --fstype=ext4 --size=15360 --grow

%packages
@core
@standard
@kde-desktop
-fedora-logos
-fedora-release
generic-logos
generic-release
dracut-live
grub2-efi-x64
grub2-pc
syslinux
shim-x64
kernel
sddm
%end

%post --log=/root/ks-post-install.log
systemctl set-default graphical.target
systemctl enable sddm.service

sed -i 's/menu background.*/menu background #000000/g' /isolinux/isolinux.cfg
sed -i 's/menu color title.*/menu color title 1 33;40 #ffffff #000000/g' /isolinux/isolinux.cfg
sed -i 's/menu color unsel.*/menu color unsel 0 37;40 #ffffff #000000/g' /isolinux/isolinux.cfg
%end