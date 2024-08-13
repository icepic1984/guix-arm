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
(use-modules (nonguix licenses))


;; https://guix.gnu.org/manual/en/html_node/Using-the-Configuration-System.html
;; Build: guix system image raspberry-pi.scm --skip-checks --verbosity=3 --no-grafts
(define-public linux-touchscreen-6.11-rc3
  (package
   (inherit linux-libre-5.15)
   (name "linux-touchscreen")
   (version "6.11-rc3")
   (source (origin
             (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/torvalds/linux")
                   (commit "7c626ce4bae1ac14f60076d00eafe71af30450ba")))
             (file-name (string-append "linux-" version))
             (sha256
              (base32
               "12434r4y6gwjykwbjzp2chqlkdvl8449a9mrhn3wlr6ixazfg9fm"))))
   ;; (arguments
   ;;  (substitute-keyword-arguments (package-arguments linux-libre-5.15)
   ;;  			                  ((#:phases phases)
   ;;  			                   #~(modify-phases #$phases

   ;;  					                            (replace 'configure
   ;;  						                                 (lambda* (#:key inputs target #:allow-other-keys)
   ;;  							                               ;; Avoid introducing timestamps
   ;;  							                               (setenv "KCONFIG_NOTIMESTAMP" "1")
   ;;  							                               (setenv "KBUILD_BUILD_TIMESTAMP" (getenv "SOURCE_DATE_EPOCH"))

   ;;  							                               ;; Other variables useful for reproducibility.
   ;;  							                               (setenv "KBUILD_BUILD_USER" "guix")
   ;;  							                               (setenv "KBUILD_BUILD_HOST" "guix")

   ;;  							                               ;; Set ARCH and CROSS_COMPILE.
   ;;  							                               (let ((arch nil (platform-linux-architecture
   ;;                                                                              (lookup-platform-by-target-or-system
   ;;                                                                               (or (%current-target-system)
   ;;                                                                                   (%current-system))))))
   ;;                                                               (setenv "ARCH" arch)
   ;;                                                               (format #t "`ARCH' set to `~a'~%" (getenv "ARCH")))
   ;;  							                               (setenv "KERNEL" "kernel8")
   ;;  							                               (invoke "make" "bcm2711_defconfig")
   ;;  							                               ;; (let ((port (open-file ".config" "a"))
   ;;  								                           ;;       (extra-configuration #$(config->string %default-extra-linux-options)))
   ;;  								                           ;;   (display extra-configuration port)
   ;;  								                           ;;   (close-port port))

   ;;  							                               ))))))
   ))

linux-touchscreen-6.11-rc3
