;; Build:  guix build -f kernel.scm --target=arm-linux-gnueabihf --no-grafts

;; # guix build -f kernel.scm --targets=arm-linux-gnueabihf -v3 -c2 -M2

(use-modules (gnu))
(use-modules (gnu packages linux))
(use-modules (gnu system))
(use-modules (gnu packages tls))
(use-modules (gnu))
(use-modules (gnu packages))
(use-modules (gnu packages base))
(use-modules (gnu packages compression))
(use-modules (gnu packages linux))
(use-modules (guix gexp))
(use-modules (guix profiles))
(use-modules (guix packages))
(use-modules (guix utils))
(use-modules (guix download))
(use-modules (guix git-download))
(use-modules (guix build-system copy))
(use-modules (guix build-system gnu))
(use-modules (guix build-system linux-module))
(use-modules (guix build-system trivial))
(use-modules (guix platform))
(use-modules (ice-9 match))
(use-modules (nonguix licenses))        ;
(use-modules (gnu bootloader))
(use-modules (gnu packages bootloaders))
(use-modules (gnu bootloader u-boot))
(use-modules (guix transformations))

(define touchscreen-defconfig
  (local-file "/home/icepic/guix/raspberry/touchscreen/defconfig-touchscreen"))

(define patch-dtb
  (local-file "/home/icepic/guix/raspberry/touchscreen/0001-Add-device-tree-for-touchscreen-board.patch"))

(define ub (make-u-boot-package "touchscreen" "arm-linux-gnueabihf"))

(define %u-boot-allow-disabling-openssl-patch (@@ (gnu packages bootloaders) %u-boot-allow-disabling-openssl-patch))
(define %u-boot-build-without-libcrypto-patch (@@ (gnu packages bootloaders) %u-boot-build-without-libcrypto-patch))

(define-public u-boot-touchscreen-arm
  (package
    (inherit ub)
    (version "2024.01")
    (source (origin
              (patches (list "0001-Add-board-description-for-touchscreen.patch"
                             %u-boot-build-without-libcrypto-patch
                             %u-boot-allow-disabling-openssl-patch))
              (method url-fetch)
              (uri (string-append
                    "https://ftp.denx.de/pub/u-boot/"
                    "u-boot-" version ".tar.bz2"))
              (sha256
               (base32
                "1czmpszalc6b8cj9j7q6cxcy19lnijv3916w3dag6yr3xpqi35mr"))))))
;; 
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

;; linux-touchscreen-6.1
u-boot-touchscreen-arm
