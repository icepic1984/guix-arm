;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(use-modules (gnu))
;(use-modules (gnu bootloader u-boot))
;(use-modules (gnu system images pine64))
(use-modules (gnu packages linux))
(use-modules (gnu system))
;(use-modules (gnu system file-systems))

(use-modules (gnu))
(use-modules (gnu packages))
(use-modules (gnu packages base))
(use-modules (gnu packages compression))
(use-modules (gnu packages linux))
(use-modules (guix licenses))
(use-modules (guix packages))
(use-modules (guix utils))
(use-modules (guix download))
(use-modules (guix git-download))
(use-modules (guix build-system copy))
(use-modules (guix build-system gnu))
(use-modules (guix build-system linux-module))
(use-modules (guix build-system trivial))
(use-modules (ice-9 match))
(use-modules (nonguix licenses))

(define (config->string options)
  (string-join (map (match-lambda
                      ((option . 'm)
                       (string-append option "=m"))
                      ((option . #t)
                       (string-append option "=y"))
                      ((option . #f)
                       (string-append option "=n")))
                    options)
               "\n"))

(define %default-extra-linux-options
  `(;; Some very mild hardening.
    ("CONFIG_SECURITY_DMESG_RESTRICT" . #t)
    ;; All kernels should have NAMESPACES options enabled
    ("CONFIG_NAMESPACES" . #t)
    ("CONFIG_UTS_NS" . #t)
    ("CONFIG_IPC_NS" . #t)
    ("CONFIG_USER_NS" . #t)
    ("CONFIG_PID_NS" . #t)
    ("CONFIG_NET_NS" . #t)
    ;; Various options needed for elogind service:
    ;; https://issues.guix.gnu.org/43078
    ("CONFIG_CGROUP_FREEZER" . #t)
    ("CONFIG_BLK_CGROUP" . #t)
    ("CONFIG_CGROUP_WRITEBACK" . #t)
    ("CONFIG_CGROUP_SCHED" . #t)
    ("CONFIG_CGROUP_PIDS" . #t)
    ("CONFIG_CGROUP_FREEZER" . #t)
    ("CONFIG_CGROUP_DEVICE" . #t)
    ("CONFIG_CGROUP_CPUACCT" . #t)
    ("CONFIG_CGROUP_PERF" . #t)
    ("CONFIG_SOCK_CGROUP_DATA" . #t)
    ("CONFIG_BLK_CGROUP_IOCOST" . #t)
    ("CONFIG_CGROUP_NET_PRIO" . #t)
    ("CONFIG_CGROUP_NET_CLASSID" . #t)
    ("CONFIG_MEMCG" . #t)
    ("CONFIG_MEMCG_SWAP" . #t)
    ("CONFIG_MEMCG_KMEM" . #t)
    ("CONFIG_CPUSETS" . #t)
    ("CONFIG_PROC_PID_CPUSET" . #t)
    ;; Allow disk encryption by default
    ("CONFIG_DM_CRYPT" . m)
    ;; Modules required for initrd:
    ("CONFIG_NET_9P" . m)
    ("CONFIG_NET_9P_VIRTIO" . m)
    ("CONFIG_VIRTIO_BLK" . m)
    ("CONFIG_VIRTIO_NET" . m)
    ("CONFIG_VIRTIO_PCI" . m)
    ("CONFIG_VIRTIO_BALLOON" . m)
    ("CONFIG_VIRTIO_MMIO" . m)
    ("CONFIG_FUSE_FS" . m)
    ("CONFIG_CIFS" . m)
    ("CONFIG_9P_FS" . m)))

(define-public linux-raspberry-5.10
  (package
    (inherit linux-libre-5.10)
    (name "linux-raspberry")
    (version "5.10")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/raspberrypi/linux")
                    ;; (commit "6cfe1a8b600aede17d8af723790eb58592d62f8a")))
                    ;; (commit "1.20211007")
		    (commit "1.20220120")
		    ))
              (file-name (string-append "linux-" version))
              (sha256
               (base32
                "1hawkjn9nyxpbkisfnifrp7m3a1abbyqmpab5mkw56zavksz281r"))))
    (arguments
     (substitute-keyword-arguments (package-arguments linux-libre-5.10)
       ((#:phases phases)
        `(modify-phases ,phases
           ;; stolen from https://www.mail-archive.com/help-guix@gnu.org/msg07219.html
           ;; required as long as 968f541c36c28c413f696558505f902d0a133d58
           ;; is not merged
           (add-before 'configure 'fix-CPATH
             (lambda _
               ;; Temporary hack to remove -checkout/include which breaks things. ;; Why is this not necessary when building in a ‘guix environment’ ;; and in the Guix linux-libre package? Git-checkout-related?
               (setenv "C_INCLUDE_PATH" (string-join
                                (cdr (string-split (getenv "C_INCLUDE_PATH") #\:))
                                ":"))

               (setenv "CPLUS_INCLUDE_PATH" (string-join
                                (cdr (string-split (getenv "CPLUS_INCLUDE_PATH") #\:))
                                ":"))

               (setenv "LIBRARY_PATH" (string-join
                                (cdr (string-split (getenv "LIBRARY_PATH") #\:))
                                ":"))
               #t))

         (replace 'configure
           (lambda* (#:key inputs native-inputs target #:allow-other-keys)
             ;; Avoid introducing timestamps
             (setenv "KCONFIG_NOTIMESTAMP" "1")
             (setenv "KBUILD_BUILD_TIMESTAMP" (getenv "SOURCE_DATE_EPOCH"))

             ;; Set ARCH and CROSS_COMPILE
             (let ((arch ,(system->linux-architecture
                           (or (%current-target-system)
                               (%current-system)))))
               (setenv "ARCH" arch)
               (format #t "`ARCH' set to `~a'~%" (getenv "ARCH"))

               (when target
                 (setenv "CROSS_COMPILE" (string-append target "-"))
                 (format #t "`CROSS_COMPILE' set to `~a'~%"
                         (getenv "CROSS_COMPILE"))))

             (invoke "make" "bcm2711_defconfig")

               (let ((port (open-file ".config" "a"))
                     (extra-configuration ,(config->string %default-extra-linux-options)))
                 (display extra-configuration port)
                 (close-port port))

             ))))))))