(use-modules
(guix build store-copy)
(guix build syscalls)
(guix build utils)
(guix store database)
(gnu build bootloader)
(gnu build install)
(gnu build linux-boot)
(gnu image)
(gnu system uuid)
(ice-9 ftw)
(ice-9 match)
(srfi srfi-19)
(srfi srfi-34)
(srfi srfi-35))

(define* (lambda initialize-raspberry-efi-partition root
                                   #:key
                                   grub-efi
                                   #:allow-other-keys)
  (display (+ grub-efi " " root))
  )