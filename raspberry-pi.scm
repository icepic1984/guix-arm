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

(define-module (gnu system images pinebook-pro)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages image)
  #:use-module (gnu platforms arm)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (srfi srfi-26)
  #:export (raspbery-pi-barebones-os
            raspbery-pi-image-type
            raspbery-pi-barebones-raw-image))

(use-modules (gnu)
             (gnu bootloader u-boot))
(use-package-modules bootloaders screen ssh)
(use-modules (nongnu packages linux))

(include "rpi-kernel.scm")

(define u-boot-rpi-4
  (make-u-boot-package "rpi_4" "aarch64-linux-gnu"))

(define install-rpi-4-u-boot
  #~(lambda (bootloader root-index image)
      #t))

(define u-boot-rpi-4-bootloader
  (bootloader
   (inherit u-boot-bootloader)
   (package u-boot-rpi-4)
   (disk-image-installer install-rpi-4-u-boot)))

(define raspberry-pi-barebones-os
  (operating-system
    (host-name "viso")
    (timezone "Europe/Paris")
    (locale "en_US.utf8")
    (bootloader (bootloader-configuration
               (bootloader  u-boot-rpi-4-bootloader)
               (targets '("/dev/vda"))))
    (initrd-modules '())
    (kernel linux-raspberry-5.10)
    (firmware (list raspberrypi-firmware))
    (file-systems (append (list 
                          (file-system
                          (device (file-system-label "BOOT"))
                          (mount-point "/boot/firmware")
                          (type "fat32"))
                          (file-system
                          (device (file-system-label "RASPIROOT"))
                          (mount-point "/")
                          (type "ext4")))
                        %base-file-systems))
    (services %base-services)
    (users (cons (user-account
                (name "pi")
                (comment "raspberrypi user")
                (password (crypt "123" "123$456"))
                (group "users")
                (supplementary-groups '("wheel")))
                %base-user-accounts))))

(define rpi-boot-partition
  (partition
         (size (* 128 (expt 2 20)))
         (label "BOOT")
         (file-system "vfat")
         (initializer (gexp initialize-efi-partition))))
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
   (name 'raspberry-pi-barebones-raw-image)))

;; Return the default image.
raspberry-pi-barebones-raw-image
