cd /tmp
mkdir opi-diskimage-arch
cd opi-diskimage-arch
mkdir imagemount
git clone https://github.com/montjoie/linux --depth=1
git clone https://github.com/u-boot/u-boot --depth=1
cd linux
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- sunxi_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
cd ../u-boot
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- orangepi_pc_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
umount /dev/loop1
umount /dev/mapper/loop1p1
sudo dd if=/dev/zero of=/opi-arch-fresh.img bs=1024 count=1048576
export card=/dev/loop1
sudo dd if=/dev/zero of=${card} bs=1k count=4096 seek=1
sudo dd if=~/opi-diskimage-arch/u-boot/u-boot-sunxi-with-spl.bin of=${card} bs=1024 seek=8
sudo losetup /dev/loop1 /opi-arch-fresh.img
sudo fdisk -u /dev/loop1 <<EOF
d
n
p
1


w
EOF
partprobe
sudo kpartx -v -a /dev/loop1
sudo mkfs.ext4 /dev/mapper/loop1p1
sudo mount /dev/mapper/loop1p1 /tmp/opi-diskimage-arch/imagemount
sudo wget http://archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
sudo bsdtar -xpf ArchLinuxARM-armv7-latest.tar.gz -C /tmp/opi-diskimage-arch/imagemount
sudo rm ~/opi-diskimage-arch/imagemount/boot/dtbs/*.*
sudo cp ~/opi-diskimage-arch/u-boot/arch/arm/dts/*.dtb ~/opi-diskimage-arch/imagemount/boot/dtbs
sudo cp /tmp/opi-diskimage-arch/linux/arch/arm/boot/zImage /tmp/opi-diskimage-arch/imagemount/boot/zImage
sudo sync
sudo dd if=/dev/loop1 of=/finishedproduct.raw
umount /dev/loop1
umount /dev/mapper/loop1p1
