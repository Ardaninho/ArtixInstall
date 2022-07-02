#!/bin/sh
echo "Checking for internet connection..."
ping -c 4 google.com
echo "Test succesful."
lsblk
echo "What is your swap partition? ex /dev/sda1"
read -r swappart
echo "What is your boot partition? ex /dev/sda2"
read -r bootpart
echo "What is your root partition? ex /dev/sda3"
read -r rootpart
while true; do
read -r "Your partitions will be formatted. ARE YOU SURE THAT YOU WANNA FORMAT YOUT PARTITIONS? (Y/N) " formatforsure
case $formatforsure in
	[yY] ) echo "Partitions will be formatted and mounted...";
	break;;
	[nN] ) echo "Exiting.";
	exit;;
	* ) echo "Invalid answer";;
esac
done
mkswap $swappart
mkfs.fat -F32 $bootpart
mkfs.ext4 $rootpart
mount $rootpart /mnt
mkdir -p /mnt/boot
mount $bootpart /mnt/boot
swapon $swappart
echo "Installing base system..."
baseswap /mnt base base-devel openrc elogind-openrc
echo "Done."
echo "Installing kernel..."
basestrap /mnt linux linux-firmware
echo "Done."
echo "Generating fstab"
fstabgen -U /mnt >> /mnt/etc/fstab
echo "Done."
while true; do
read -r "Do you wanna chroot for second procedure? (Y/N) " chrootforsure
case $formatforsure in
	[yY] ) echo "Chrooting...";
	break;;
	[nN] ) echo "Exiting...";
	exit;;
	* ) echo "Invalid answer";;	 
esac
done
artix-chroot /mnt
