;; Build:  guix build -f kernel.scm --target=arm-linux-gnueabihf --no-grafts

;; # guix build -f kernel.scm --targets=arm-linux-gnueabihf -v3 -c2 -M2

;; Algorithm to search ftd file from kernel folder
;; ;; https://patchwork.ozlabs.org/project/uboot/patch/1390506927-15687-1-git-send-email-swarren@wwwdotorg.org/
(define-module (gnu system images touchscreen)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader u-boot)
  #:use-module (gnu image)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages image)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu system)

  #:use-module (gnu system file-systems)
  #:use-module (gnu system image)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix platforms arm)
  #:use-module (srfi srfi-26)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages version-control)

  #:export (touchscreen-os
            touchscreen-image-type
            touchscreen-raw-image))

;; (use-modules (gnu))
;; (use-modules (gnu packages linux))
;; (use-modules (gnu system))
;; (use-modules (gnu packages tls))
;; (use-modules (gnu))
;; (use-modules (gnu image))
;; (use-modules (gnu packages))
;; (use-modules (gnu packages base))
;; (use-modules (gnu packages compression))
;; (use-modules (gnu packages linux))
;; (use-modules (gnu packages image))
;; (use-modules (gnu system))
;; (use-modules (gnu system file-systems))
;; (use-modules (gnu system image))
;; (use-modules (gnu services base))
;; (use-modules (guix gexp))
;; (use-modules (guix profiles))
;; (use-modules (guix packages))
;; (use-modules (guix utils))
;; (use-modules (guix download))
;; (use-modules (guix platforms arm))
;; (use-modules (guix git-download))
;; (use-modules (guix build-system copy))
;; (use-modules (guix build-system gnu))
;; (use-modules (guix build-system linux-module))
;; (use-modules (guix build-system trivial))
;; (use-modules (guix platform))
;; (use-modules (ice-9 match))
;; (use-modules (nonguix licenses))        ;
;; (use-modules (gnu bootloader))
;; (use-modules (gnu packages bootloaders))
;; (use-modules (gnu bootloader u-boot))
;; (use-modules (guix transformations))

(use-modules (gnu) (gnu bootloader u-boot))
(use-package-modules bootloaders networking screen ssh)
(use-service-modules networking ssh)
(use-modules (guix gexp))


(define touchscreen-defconfig
  (local-file "/home/icepic/guix/raspberry/touchscreen/defconfig-touchscreen"))

(define patch-dtb
  (local-file "/home/icepic/guix/raspberry/touchscreen/0001-Add-device-tree-for-touchscreen-board.patch"))

(define ub (make-u-boot-package "touchscreen" "arm-linux-gnueabihf"))

(define-public u-boot-touchscreen-arm
  (package
   (inherit ub)
   (version "2024.01")
   (source
    (origin
     (inherit (package-source ub))
     (patches (append (origin-patches (package-source ub))
                      '("/home/icepic/guix/raspberry/touchscreen/0001-Add-board-description-for-touchscreen.patch")))))))

(define-public linux-touchscreen-6.1
  (package
    (inherit
     (customize-linux #:name "linux"
                      #:linux linux-libre-6.1
                      #:source (origin
                                 (method git-fetch)
                                 (uri (git-reference
                                       (url "https://github.com/torvalds/linux")
                                       (commit "830b3c68c1fb1e9176028d02ef86f3cf76aa2476")))
                                 (patches '("0001-Add-device-tree-for-touchscreen-board.patch"))
                                 (sha256
                                  (base32
                                   "0y8yrk80c04l49z3a5xk8qdssavw8lsf3b56gk1a5v7zlczp6w7c")))
                      #:defconfig touchscreen-defconfig))
    (version "6.1")
    (home-page "https://www.kernel.org")
    (synopsis "Kernel for touchscreen board")))

(define install-u-boot-touchscreen
  #~(lambda (bootloader root-index image)
      #t))

(define u-boot-touchscreen-bootloader
  (bootloader
   (inherit u-boot-bootloader)
   (package u-boot-touchscreen-arm)
   (disk-image-installer install-u-boot-touchscreen)))

(define touchscreen-os
  (operating-system
    (host-name "komputilo")
    (timezone "Europe/Berlin")
    (locale "en_US.utf8")

    ;; Assuming /dev/mmcblk1 is the eMMC, and "my-root" is
    ;; the label of the target root file system.
    (bootloader (bootloader-configuration
                 (bootloader u-boot-touchscreen-bootloader)
                 (targets '("/dev/mmcblk1"))))

    ;; This module is required to mount the SD card.
    (initrd-modules '())
    (kernel linux-touchscreen-6.1)

    (file-systems (cons (file-system
                          (device (file-system-label "my-root"))
                          (mount-point "/")
                          (type "ext4"))
                        %base-file-systems))

    ;; This is where user accounts are specified.  The "root"
    ;; account is implicit, and is initially created with the
    ;; empty password.
    (users (cons (user-account
                  (name "alice")
                  (comment "Bob's sister")
                  (group "users")

                  ;; Adding the account to the "wheel" group
                  ;; makes it a sudoer.  Adding it to "audio"
                  ;; and "video" allows the user to play sound
                  ;; and access the webcam.
                  (supplementary-groups '("wheel"
                                          "audio" "video")))
                 %base-user-accounts))

    ;; Globally-installed packages.
    (packages (append (list screen openssh) %base-packages))

    (services (append (list (service dhcp-client-service-type)
                            ;; mingetty does not work on serial lines.
                            ;; Use agetty with board-specific serial parameters.
                            (service agetty-service-type
                                     (agetty-configuration
                                      (extra-options '("-L"))
                                      (baud-rate "115200")
                                      (term "vt100")
                                      (tty "ttymxc1"))))
                      %base-services))))

(define touchscreen-boot-partition
  (partition
   (size (* 128 (expt 2 20)))
   (label "BOOT")
   (file-system "fat32")
   (flags '())
   (initializer (gexp (lambda* (root #:key grub-efi #:allow-other-keys)
                        (use-modules (guix build utils))
                        (mkdir-p root)
                        ;; (copy-recursively (file-append u-boot-touchscreen-arm "/libexec/u-boot-dtb.imx")
                        ;;                   (string-append root "/u-boot-dtb.imx"))
                        )))))

(define touchscreen-root-partition
  (partition
   (size 'guess)
   (label "RASPIROOT")
   (file-system "ext4")
   (flags '(boot))
   (initializer (gexp initialize-root-partition))))

(define touchscreen-image
  (image-without-os
   (format 'disk-image)
   (partitions (list touchscreen-boot-partition touchscreen-root-partition))))

(define touchscreen-image-type
  (image-type
   (name 'touscreen-raw)
   (constructor (cut image-with-os touchscreen-image <>))))

(define touchscreen-raw-image
  (image
   (inherit
    (os+platform->image touchscreen-os armv7-linux
                        #:type touchscreen-image-type))
   (partition-table-type 'mbr)
   (name 'touchscreen-raw-image)))

touchscreen-raw-image
;; linux-touchscreen-6.1
;; u-boot-touchscreen-arm
