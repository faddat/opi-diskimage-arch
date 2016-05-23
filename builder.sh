cd ~/
export HOME=$(pwd)
mkdir opi-diskimage-arch
cd opi-diskimage-arch
mkdir imagemount
git clone https://github.com/faddat/linux -b working-image --depth=1
git clone https://github.com/u-boot/u-boot --depth=1
cd linux
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
cd ../u-boot
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- orangepi_pc_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
sudo -s
dd if=/dev/zero of=~/opi-arch-fresh.img bs=1024 count=1048576
export card=/dev/loop1
dd if=/dev/zero of=${card} bs=1k count=1023 seek=1
dd if=~/opi-diskimage-arch/u-boot/u-boot-sunxi-with-spl.bin of=${card} bs=1024 seek=8
losetup /dev/loop1 ~/myDisk.img
fdisk -u -p /dev/loop1 <<EOF
n
p
1

w
EOF
kpartx -v -a /dev/loop1
mkfs.ext4 /dev/mapper/loop1p1
mount /dev/mapper/loop1p1 $HOME/opi-diskimage-arch/imagemount
wget http://archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
bsdtar -xpf ArchLinuxARM-armv7-latest.tar.gz -C $HOME/opi-diskimage-arch/imagemount
sync



