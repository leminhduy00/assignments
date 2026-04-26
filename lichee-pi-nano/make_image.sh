#!/bin/bash
set -e

WORKDIR=$(pwd)
IMG_FILE="${WORKDIR}/licheepi-nano.img"

UBOOT="${WORKDIR}/prebuild-files/u-boot-sunxi-with-spl.bin"
KERNEL="${WORKDIR}/prebuild-files/zImage"
DTB="${WORKDIR}/prebuild-files/suniv-f1c100s-licheepi-nano.dtb"
ROOTFS="${WORKDIR}/prebuild-files/rootfs.tar"

BOOT_SIZE=16
IMG_SIZE=128

rm -f "$IMG_FILE"

echo "Creating blank image..."
dd if=/dev/zero of="$IMG_FILE" bs=1M count=$IMG_SIZE

LOOPDEV=$(sudo losetup -f --show "$IMG_FILE")

echo "Creating partitions..."
cat <<EOF | sudo sfdisk "$IMG_FILE"
1M,${BOOT_SIZE}M,c
,,L
EOF

sudo partx -u "$LOOPDEV"
sleep 1

echo "Formatting partitions..."
sudo mkfs.vfat ${LOOPDEV}p1
sudo mkfs.ext4 ${LOOPDEV}p2

echo "Writing U-Boot..."
sudo dd if="$UBOOT" of="$LOOPDEV" bs=1024 seek=8 conv=fsync

mkdir -p mnt_boot mnt_root

sudo mount ${LOOPDEV}p1 mnt_boot
sudo mount ${LOOPDEV}p2 mnt_root

echo "Copying kernel files..."
sudo cp "$KERNEL" mnt_boot/
sudo cp "$DTB" mnt_boot/

echo "Extracting rootfs..."
sudo tar -xpf "$ROOTFS" -C mnt_root/

sync

sudo umount mnt_boot
sudo umount mnt_root
sudo losetup -d "$LOOPDEV"

rmdir mnt_boot mnt_root

echo "Done:"
echo "$IMG_FILE"
