#!/bin/sh
echo "Welcome to Artix Linux install script!"
neofetch
echo "Checking for internet connection..."
ping -c 4 gnu.org
echo "Test succesful."
lsblk
echo "What is your swap partition? ex /dev/sda1"
read -r swappart
echo "What is your boot partition? ex /dev/sda2"
read -r bootpart
echo "What is your root partition? ex /dev/sda3"
read -r rootpart
echo "Your partitions will be formatted. ARE YOU SURE THAT YOU WANNA FORMAT YOUR PARTITIONS? (Y/N) " && read formatforsure
case $formatforsure in
	"Y") echo "Partitions will be formatted and mounted...";
	continue;;
	"N") echo "Exiting.";
	exit;;
	"y") echo "Partitions will be formatted and mounted...";
	continue;;
	"n") echo "Exiting.";
	exit;;
	* ) echo "Invalid answer";;
esac
mkswap $swappart
mkfs.fat -F32 $bootpart
mkfs.ext4 $rootpart
mount $rootpart /mnt
mkdir -p /mnt/boot
mount $bootpart /mnt/boot
swapon $swappart
echo "Installing base system..."
basestrap /mnt base base-devel openrc elogind-openrc
echo "Done."
echo "Installing kernel..."
basestrap /mnt linux linux-firmware
echo "Done."
echo "Generating fstab"
fstabgen -U /mnt >> /mnt/etc/fstab
echo "Done."
echo "You will be chrooted into your new system."
echo "Setting up timezone. What is your timezone? ex Europe/Brussels"
read -r timezone
echo "Linking $timezone to /etc/localtime..."
artix-chroot /mnt sh -c "ln -sf /usr/share/zoneinfo/$timezone /etc/localtime"
echo "hwclock --systohc..."
artix-chroot /mnt sh -c "hwclock --systohc"
artix-chroot /mnt sh -c "pacman -S nano"
echo "Add your locales in /etc/locale.gen. Opening nano in 5 seconds..."
sleep 5
artix-chroot /mnt sh -c "nano /etc/locale.gen"
locale-gen
echo "Installing bootloader... Default bootloader will be GRUB."
artix-chroot /mnt sh -c "pacman -S grub os-prober efibootmgr"
artix-chroot /mnt sh -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub"
artix-chroot /mnt sh -c "grub-mkconfig -o /boot/grub/grub.cfg"
echo "Changing password for root."
artix-chroot /mnt sh -c "passwd root"
echo "Network Configuration"
echo "Change your hostname. Opening nano in 5 seconds..."
sleep 5
artix-chroot /mnt sh -c "nano /etc/conf.d/hostname"
hostname > /etc/hostname
artix-chroot /mnt sh -c "printf "127.0.0.1 localhost\n::1 localhost" > /etc/hosts"
echo "Installing DHCP client..."
artix-chroot /mnt sh -c "pacman -S dhcpcd"
ip a
echo "Whats your network interface? Note that "lo" does not count. ex, eth0"
read -r networkinterface
echo "Linking network interface..."
ln -s /etc/init.d/net.lo /etc/init.d/net.$networkinterface
rc-update add net.$networkinterface default
echo "Installation of Artix Linux is done! You can reboot your system now."
echo "Unmounting drives..."
umount -l /mnt/boot
umount -R /mnt
echo "Exiting."
exit
