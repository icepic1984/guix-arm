;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2020 Mathieu Othacehe <m.othacehe@gmail.com>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu system images raspberry-pi)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages image)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (guix platforms arm)
  #:use-module (srfi srfi-26)

  #:export (raspbery-pi-barebones-os
            raspbery-pi-image-type
            raspbery-pi-barebones-raw-image))

(use-modules (gnu)
             (gnu bootloader u-boot))
(use-package-modules bootloaders screen ssh)
(use-modules (nongnu packages linux))
(use-modules (guix gexp))

(include "rpi-kernel.scm")
(include "reterminal.scm")


(define (install-rpi-efi-loader grub-efi esp)
  "Install in ESP directory the given GRUB-EFI bootloader.  Configure it to
load the Grub bootloader located in the 'Guix_image' root partition."
  (let ((uboot-binary "/libexec/u-boot.bin"))
    (copy-file #$(file-append (u-boot-rpi-arm64) uboot-binary ) "/")))

(define u-boot-rpi-arm64
  (make-u-boot-package "rpi_arm64" "aarch64-linux-gnu"))

(define install-rpi-arm64-u-boot
  #~(lambda (bootloader root-index image)
      #t))

(define u-boot-rpi-arm64-bootloader
  (bootloader
   (inherit u-boot-bootloader)
   (package u-boot-rpi-arm64)
   (disk-image-installer install-rpi-arm64-u-boot)))

(define raspberry-pi-barebones-os
  (operating-system
   (host-name "viso")
   (timezone "Europe/Paris")
   (locale "en_US.utf8")
   (bootloader (bootloader-configuration
		(bootloader  u-boot-rpi-arm64-bootloader)
		(targets '("/dev/vda"))))
   (kernel linux-raspberry-5.10)
   ;;(kernel-arguments (cons* "console=serial0,9600" "console=ttyAMA0,9600" "8250.nr_uarts=1" "kgdboc=serial0,9600" "module_blacklist=vc4"
	 ;;		  %default-kernel-arguments))
   (initrd-modules (cons* "fuse" "8021q" "garp" "stp" "llc" "joydev" "snd_soc_hdmi_codec" "rtc_pcf8563" "industrialio_triggered_buffer" "kfifo_buf" "industrialio" "gpio_pca953x" "pinctrl_mcp23s08" "regmap_i2c" "brcmfmac" "brcmutil" "vc4" "cec" "cfg80211" "v3d" "rfkill" "gpu_sched" "dwc2" "drm_kms_helper" "raspberrypi_hwmon" "roles" "bcm2835_v4l2" "bcm2835_codec" "bcm2835_isp" "i2c_brcmstb" "videobuf2_vmalloc" "bcm2835_mmal_vchiq" "v4l2_mem2mem" "videobuf2_dma_contig" "videobuf2_memops""i2c_bcm2835" "drm" "drm_panel_orientation_quirks" "snd_bcm2835" "vc_sm_cma" "snd_soc_core" "snd_compress" "snd_pcm_dmaengine" "snd_timer" "syscopyarea" "sysfillrect" "rpivid_mem" "sysimgblt" "nvmem_rmem" "fb_sys_fops" "backlight" "uio_pdrv_genirq" "uio" "gpio_keys" "i2c_dev" "aes_neon_bs" "sha256_generic" "aes_neon_blk" "crypto_simd" "cryptd" "ip_tables" "x_tables" "ipv6" %base-initrd-modules))
   (firmware (list raspberrypi-firmware))
   (file-systems (append (list 
                          (file-system
                           (device (file-system-label "BOOT"))
                           (mount-point "/boot/firmware")
                           (type "vfat"))
                          (file-system
                           (device (file-system-label "RASPIROOT"))
                           (mount-point "/")
                           (type "ext4")))
                         %base-file-systems))
   (services %base-services)
   (packages %base-packages)
   (users (cons (user-account
                 (name "pi")
                 (comment "raspberrypi user")
                 (password (crypt "123" "123$456"))
                 (group "users")
                 (supplementary-groups '("wheel")))
                %base-user-accounts))
   (kernel-loadable-modules %reterminal-kernel-modules)
   ))

(define rpi-boot-partition
  (partition
   (size (* 128 (expt 2 20)))
   (label "BOOT")
   (file-system "fat32")
   (flags '())
   (initializer (gexp (lambda* (root #:key
                                 grub-efi
                                 #:allow-other-keys)
                               (use-modules (guix build utils))
                               (mkdir-p root)
                               (copy-recursively #$(file-append u-boot-rpi-arm64 "/libexec/u-boot.bin" )
						 (string-append root "/u-boot.bin"))
                               (copy-recursively #$(file-append raspberrypi-firmware "/" ) root)
                               (copy-recursively #$(local-file "config.txt")
						 (string-append root "/config.txt"))
                               (copy-recursively #$(local-file "cmdline.txt")
						 (string-append root "/cmdline.txt"))
			       )))))

(define rpi-root-partition
  (partition
   (size 'guess)
   (label "RASPIROOT")
   (file-system "ext4")
   (flags '(boot))
   (initializer (gexp initialize-root-partition))))

(define raspberry-pi-image
  (image
   (format 'disk-image)
   (partitions (list rpi-boot-partition rpi-root-partition))))

(define raspberry-pi-image-type
  (image-type
   (name 'raspberry-pi-raw)
   (constructor (cut image-with-os raspberry-pi-image <>))))

(define raspberry-pi-barebones-raw-image
  (image
   (inherit
    (os+platform->image raspberry-pi-barebones-os aarch64-linux
                        #:type raspberry-pi-image-type))
   (partition-table-type 'mbr)
   (name 'raspberry-pi-barebones-raw-image)))

;; Return the default image.
raspberry-pi-barebones-raw-image
