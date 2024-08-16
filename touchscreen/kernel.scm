;; Build:  guix build -f kernel.scm --target=arm-linux-gnueabihf --no-grafts

(use-modules (gnu))
(use-modules (gnu packages linux))
(use-modules (gnu system))

(use-modules (gnu))
(use-modules (gnu packages))
(use-modules (gnu packages base))
(use-modules (gnu packages compression))
(use-modules (gnu packages linux))
(use-modules (guix gexp))
(use-modules (guix licenses))
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


(define touchscreen-defconfig
  (local-file "/home/icepic/guix/raspberry/touchscreen/defconfig-touchscreen"))

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
                                 (sha256
                                  (base32
                                   "0y8yrk80c04l49z3a5xk8qdssavw8lsf3b56gk1a5v7zlczp6w7c")))
                      #:defconfig touchscreen-defconfig))
    (version "6.1")
    (home-page "https://www.kernel.org")
    (synopsis "Kernel for touchscreen board")))

linux-touchscreen-6.1
