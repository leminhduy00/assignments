# Buildroot, Linux Kernel & U-Boot for Licheepi Nano (F1C100S Allwinner)

---

# Buildroot

## 1. Install required packages

```bash
sudo apt-get install gcc make cmake rsync wget unzip build-essential git bc swig libncurses-dev libpython3-dev libssl-dev python3-setuptools mkbootimg -y
```

---

## 2. Download buildroot 2024.02 source

```bash
git clone -b 2024.02 https://github.com/buildroot/buildroot.git
cd buildroot
```

---

## 3. Configure Buildroot

```bash
make menuconfig
```
### Select "Target options"
- Target Architecture → ARM (Little endian)
- Target Architecture Variant → arm926t

![Test](https://i.postimg.cc/QMqYw5gT/target.png)

### Select "Toolchain"
- Toolchain type → Buildroot toolchain
- C library → glibc
- Kernel Headers → Linux 4.14.x
- Enable C++ support

![Test](https://i.postimg.cc/rp9Z3WG4/toolchain.png)

### Save, exit and run make to build the toolchain and rootfile system

```bash
make -jx
# where x is the number of threads your computer can run.
```

---

## 4. Output
- Toolchain: buildroot/output/host/bin/
- Root filesystem: buildroot/output/images/

---

## 5. Setup Toolchain

```bash
export ARCH=arm
export CROSS_COMPILE=arm-buildroot-linux-gnueabi-
export PATH=$PATH:<YOUR_BUILDROOT_PATH>/output/host/bin/
```

---

# Linux Kernel

## 1. Download source

```bash
git clone https://github.com/robot9706/lichee-pi-nano-linux
cd lichee-pi-nano-linux
```

---

## 2. Build Kernel

```bash
export ARCH=arm
export CROSS_COMPILE=arm-buildroot-linux-gnueabi-
export PATH=$PATH:<YOUR_BUILDROOT_PATH>/output/host/bin/
```

```bash
wget http://dl.sipeed.com/LICHEE/Nano/SDK/config
cp config .config
make ARCH=arm menuconfig
make -jx
# where x is the number of threads your computer can run.
```

## 3. Output
- Kernel: arch/arm/boot/zImage
- Device Tree: arch/arm/boot/dts/suniv-f1c100s-licheepi-nano.dtb

---

# U-Boot

## 1. Download source

```bash
git clone -b v2024.01 https://source.denx.de/u-boot/u-boot.git
cd u-boot
```

---

## 2. Configure

```bash
export ARCH=arm
export CROSS_COMPILE=arm-buildroot-linux-gnueabi-
export PATH=$PATH:<YOUR_BUILDROOT_PATH>/output/host/bin/
```

```bash
make licheepi_nano_defconfig
make menuconfig
```

### Boot Configuration
Bootargs (Enable boot arguments to be Y):
```
console=ttyS0,115200 panic=5 rootwait root=/dev/mmcblk0p2 earlyprintk rw
```

Bootcmd (Enable a default value for bootcmd to be Y):
```
load mmc 0:1 0x80008000 zImage;
load mmc 0:1 0x80c08000 suniv-f1c100s-licheepi-nano.dtb;
bootz 0x80008000 - 0x80c08000;
```
![Test](https://i.postimg.cc/W47YCrmJ/uboot.png)

Save and Exit


## 3. Build

```bash
make -jx
# where x is the number of threads your computer can run.
```

## 4. Output
File: u-boot-sunxi-with-spl.bin

---

# Generate SD Card Image


## 1. Prepare input files

Before running the image generation script, put all generated output files into the prebuild-files folder:

Buildroot root filesystem (rootfs.tar)
Linux kernel (zImage)
Device tree (suniv-f1c100s-licheepi-nano.dtb)
U-Boot (u-boot-sunxi-with-spl.bin)

## 2. Run image generation script

```bash
chmod +x make_image.sh
./make_image.sh
```

## 3. Output

licheepi-nano.img

## 4. Flash to SD Card
```bash
sudo dd if=licheepi-nano.img of=/dev/sdX bs=4M conv=fsync status=progress
```

