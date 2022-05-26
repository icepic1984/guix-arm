# How to setup GUIX/Pantherx on raspberry
Tested on GUIX and PantherX

## Build system image
On aarch64 or x86_64 host
```
guix system image raspberry-pi.scm --skip-checks --verbosity=3```
```

## Flash Image to sd card
I use either Balena Etcher or dd.

## Build uboot
On Pinebook Pro, Raspberry PI or any other aarch64 board
```
git clone git://git.denx.de/u-boot.git
make rpi_4_defconfig
make -j4
```
On other platforms (such as x86) one should also configure cross compiler with `export CROSS_COMPILE=aarch64-linux-gnu-`

## Reartition SD card
Manually reformat `BOOT` partition (fat16) to fat32.

## Prepare /boot/ partition
Mount `BOOT` partition. Manually place uboot.img on its root.
Download raspberry pi firmware with GIT tag corresponding to your kernel version. It's [1.20220120](https://github.com/raspberrypi/firmware/tree/1.20220120) at the moment.
Put `config.txt` on `BOOT` partition with the following content:
```
enable_uart=1
uart_2ndstage=1
arm_64bit=1
kernel=u-boot.bin
```
Also, put `config.txt` with
```
root=LABEL=RASPIROOT rw rootwait console=serial0,115200 console=tty1 console=ttyAMA0,115200 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=serial0,115200
```

# Final steps
Insert SD card into Raspberry, enter user `pi` and password `123`. You will be asked to change it on first login.