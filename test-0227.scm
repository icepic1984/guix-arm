(use-modules (gnu)
             (gnu bootloader u-boot))
;(use-service-modules networking ssh)
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

(operating-system
 (host-name "rpi-terminal")
  (timezone "Asia/Tehran")
  (locale "en_US.utf8")

  (kernel linux-raspberry-5.10)
  (firmware (list raspberrypi-firmware))
  (initrd-modules '())

  (bootloader (bootloader-configuration
               ;; (bootloader u-boot-pine64-lts-bootloader)
               (bootloader  u-boot-rpi-4-bootloader)
               (targets '("/dev/vda"))))
  (file-systems (cons (file-system
                        (device (file-system-label "RASPIROOT"))
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  (users (cons (user-account
                (name "pi")
                (comment "raspberrypi user")
                (password (crypt "123" "123$456"))
                (group "users")
                (supplementary-groups '("wheel")))
               %base-user-accounts))
  (services %base-services)

)

