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

;; https://guix.gnu.org/manual/en/html_node/Using-the-Configuration-System.html
;; Build: guix system image raspberry-pi.scm --skip-checks --verbosity=3 --no-grafts

 ;; guix build -f kernel.scm --target=arm-linux-gnueabihf --no-grafts -v3 -K
;; (define-public linux-touchscreen-6.1
;;   (package
;;     (inherit linux-libre-6.1)
;;     (name "linux-touchscreen")
;;     (version "6.1-free")
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                     (url "https://github.com/torvalds/linux")
;;                     (commit "830b3c68c1fb1e9176028d02ef86f3cf76aa2476")))
;;                                         ;(commit "7c626ce4bae1ac14f60076d00eafe71af30450ba")))
;;               (file-name (string-append "linux-" version))
;;               (sha256
;;                (base32
;;                 "0y8yrk80c04l49z3a5xk8qdssavw8lsf3b56gk1a5v7zlczp6w7c"))))))

;; (customize-linux  #:name "bla" #:linux linux-touchscreen-6.1
;;                   #:defconfig touchscreen-defconfig)

;; bla

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
;; (define-public linux-touchscreen-6.1
;;   (package
;;     (inherit
;;      (customize-linux #:name "linux"
;;                       #:linux linux-libre-6.1
;;                       #:source (origin
;;                                  (method git-fetch)
;;                                  (uri (git-reference
;;                                        (url "https://github.com/torvalds/linux")
;;                                        (commit "830b3c68c1fb1e9176028d02ef86f3cf76aa2476")))
;;                                  (sha256
;;                                   (base32
;;                                    "0y8yrk80c04l49z3a5xk8qdssavw8lsf3b56gk1a5v7zlczp6w7c")))
;;                       #:configs '()
;;                       #:defconfig touchscreen-defconfig))
;;     (version "6.1")
;;     (home-page "https://www.kernel.org")
;;     (synopsis "Kernel for touchscreen board")
;;     (arguments
;;      (substitute-keyword-arguments (package-arguments linux-libre-5.15)
;; 	   ((#:phases phases)
;; 		#~(modify-phases #$phases

;; 			(replace 'configure
;; 			  (lambda* (#:key inputs target #:allow-other-keys)
;; 				(invoke "make" "defconfig")
;; 				))))))))



;; linux-touchscreen-6.1

;; (define bla (substitute-keyword-arguments (package-arguments linux-touchscreen-6.1)
;;               ((#:phases phases)
;;                #~ (modify-phases #$phases
;;                     (replace 'configure (lambda* (#:key inputs target #:allow-other-keys)
;;                                           (setenv "KCONFIG_NOTIMESTAMP" "1")))))))
