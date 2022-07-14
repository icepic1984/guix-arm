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

(define-public linux-raspberry-5.15
  (package
   (inherit linux-libre-5.15)
   (name "linux-raspberry")
   (version "5.15.32")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/raspberrypi/linux")
		  (commit "1.20220331")))
            (file-name (string-append "linux-" version))
            (sha256
             (base32
              "1k18cwnsqdy5ckymy92kp8czckzwgn8wn2zdibzrrg9jxrflx6vl"))))
   (arguments
    (substitute-keyword-arguments (package-arguments linux-libre-5.15)
				  ((#:phases phases)
				   #~(modify-phases #$phases

						    (replace 'configure
							     (lambda* (#:key inputs target #:allow-other-keys)
								      ;; Avoid introducing timestamps
								      (setenv "KCONFIG_NOTIMESTAMP" "1")
								      (setenv "KBUILD_BUILD_TIMESTAMP" (getenv "SOURCE_DATE_EPOCH"))

								      ;; Other variables useful for reproducibility.
								      (setenv "KBUILD_BUILD_USER" "guix")
								      (setenv "KBUILD_BUILD_HOST" "guix")

								      ;; Set ARCH and CROSS_COMPILE.
								      (let ((arch #$(platform-linux-architecture
										     (lookup-platform-by-target-or-system
										      (or (%current-target-system)
											  (%current-system))))))
									(setenv "ARCH" arch)
									(format #t "`ARCH' set to `~a'~%" (getenv "ARCH"))

									(when target
									  (setenv "C_INCLUDE_PATH" (string-join
												    (cdr (string-split (getenv "C_INCLUDE_PATH") #\:))
												    ":"))

									  (setenv "CPLUS_INCLUDE_PATH" (string-join
													(cdr (string-split (getenv "CPLUS_INCLUDE_PATH") #\:))
													":"))

									  (setenv "LIBRARY_PATH" (string-join
												  (cdr (string-split (getenv "LIBRARY_PATH") #\:))
												  ":"))
									  (setenv "CROSS_COMPILE" (string-append target "-"))
									  (format #t "`CROSS_COMPILE' set to `~a'~%"
										  (getenv "CROSS_COMPILE"))))
								      (setenv "KERNEL" "kernel8")
								      (invoke "make" "bcm2711_defconfig")
								      (let ((port (open-file ".config" "a"))
									    (extra-configuration #$(config->string %default-extra-linux-options)))
									(display extra-configuration port)
									(close-port port))

								      ))))))))
