(define-module (wsl2-custom)
  #:use-module (gnu image)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages linux)

  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services virtualization)

  #:use-module (gnu system)
  #:use-module (gnu system accounts)
  #:use-module (gnu system shadow)
  #:use-module (gnu system image)
  #:use-module (gnu system images wsl2)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-19)
  #:use-module (srfi srfi-26)


  #:export (wsl2-os-custom
            wsl2-image-custom))

(define qemu-binfmt-shepherd-services (@@ (gnu services virtualization) qemu-binfmt-shepherd-services))

(define <qemu-binfmt-configuration> (@@ (gnu services virtualization) <qemu-binfmt-configuration>))

(define qemu-platform->binfmt (@@ (gnu services virtualization) qemu-platform->binfmt))

(define %binfmt-mount-point (@@ (gnu services virtualization) %binfmt-mount-point))

(define %binfmt-register-file (@@ (gnu services virtualization ) %binfmt-register-file ))

(define qemu-binfmt-shepherd-custom-services
  (match-lambda
    (($ <qemu-binfmt-configuration> qemu platforms)
     (list (shepherd-service
            (provision '(qemu-binfmt))
            (documentation "Install binfmt_misc handlers for QEMU.")
            (start #~(lambda ()
                       ;; Register the handlers for all of PLATFORMS.
                       (for-each (lambda (str)
                                   (call-with-output-file
                                       #$%binfmt-register-file
                                     (lambda (port)
                                       (display str port))))
                                 (list
                                  #$@(map (cut qemu-platform->binfmt qemu
                                               <>)
                                          platforms)))
                       #t))
            (stop #~(lambda (_)
                      ;; Unregister the handlers.
                      (for-each (lambda (name)
                                  (let ((file (string-append
                                               #$%binfmt-mount-point
                                               "/qemu-" name)))
                                    (call-with-output-file file
                                      (lambda (port)
                                        (display "-1" port)))))
                                '#$(map qemu-platform-name platforms))
                      #f)))))))

(define qemu-binfmt-custom-service-type
  ;; TODO: Make a separate binfmt_misc service out of this?
  (service-type (name 'qemu-binfmt)
                (extensions
                 (list
                  (service-extension shepherd-root-service-type
                                     qemu-binfmt-shepherd-custom-services)))
                (default-value (qemu-binfmt-configuration))
                (description
                 "This service supports transparent emulation of binaries
compiled for other architectures using QEMU and the @code{binfmt_misc}
functionality of the kernel Linux.")))


(define wsl2-os-custom
  (operating-system
    (inherit wsl-os)
    (users (cons* (user-account
                   (name "icepic")
                   (group "users")
                   (supplementary-groups '("wheel"))
                   (password "$6$felix$Z1mRpNsE85mqUw8MOilWyfw61Z4mLK97jMI88TMrXWHFAItb6B97vBDKWgJws0YZiCIPzJ.Xudrh4E3h9BVhg.")
                   (comment "Wsl user"))
                  (user-account
                   (inherit %root-account)
                   (shell (wsl-boot-program "icepic")))
                  %base-user-accounts))
    (services
     (list
      (service guix-service-type)
      (service special-files-service-type
               `(("/bin/sh" ,(file-append bash "/bin/bash"))
                 ("/bin/mount" ,(file-append util-linux "/bin/mount"))
                 ("/usr/bin/env" ,(file-append coreutils "/bin/env"))))
      (service qemu-binfmt-custom-service-type
               (qemu-binfmt-configuration
                (platforms (lookup-qemu-platforms "aarch64" ))))
      (service udev-service-type )))))


(define wsl2-image-custom
  (image
   (inherit
    (os->image wsl2-os-custom #:type wsl2-image-type))
   (name 'wsl2-image-custom)))

wsl2-image-custom


