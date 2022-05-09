# How to setup GUIX/Pantherx on raspberry
Tested on PantherX only

## Build rootfs
On x86 pantherx machine
```
guix system init --target=aarch64-linux-gnu --skip-checks ./test-0227.scm ./rpi_root_v2
```
On aarch64 machine
```
guix system init --skip-checks ./test-0227.scm ./rpi_root_v2
```
It is important to know that due to upstream bugs it's not possible to build aarch64 rootfs on aarch64 host at the moment. Check this [issue](https://git.pantherx.org/development/hardware/raspberry/-/issues/2) to learn more.

## Build uboot
On Pinebook Pro or any other aarch64 board
```
git clone git://git.denx.de/u-boot.git
make rpi_4_defconfig
make -j4
```
On other machines (such as x86) one should also configure cross compiler with `export CROSS_COMPILE=aarch64-linux-gnu-`

## Partition SD card
I used gparted to create two partitions.
- 128mb boot partition with label `BOOT` type fat32
- rootfs partition with label `RASPIROOT` (can be changed to be anything, actually) type ext4 (I guess can be different, didn't test). It is recommended to make this partition not less than 2gb to fit all the GUIX/Pantherx files.
Partition label here should also match one in `test-0277.scm` to avoid problems.

Set MBR boot flag on rootfs partition (`RASPIROOT`). Bootloader won't locate and execute extlinux.conf otherwise!

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
Replace `RASPIROOT` with whatever partition label you have set partitioning your sd card. I tried setting both to `GUIX`, it really doesn't matter.


## Deployment
Copy rootfs files from previously generated `rpi_root_v2` to rootfs (`RASPIROOT`) partition of sdcard.
With remote build machine (both behind NAT) it can be done as follows:
- Setup reverse SSH from remote build machine to VPN server
```
ssh -R 43022:localhost:22 root@81.2.237.5
```
- Forward SSH port from local machine to VPN server:
 ```
ssh -fNL 43022:localhost:43022 root@81.2.237.5
```
- Run rsync to update local files (in .) with the latest GUIX build. One should do that in `RASPIROOT` partition mount path
```
sudo rsync -a -e 'ssh -p 43022' panther@localhost:/home/panther/factory/rpi_root_v2/ ./ -v --stats --progress --delete
```
One can also use tar.gz archive, but it can be too slow as it lacks delta updates