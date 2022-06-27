(use-modules (guix packages))
(use-modules (guix download))
(use-modules (guix git-download))
(use-modules (guix gexp))
(use-modules ((guix licenses) #:prefix license:))
(use-modules (guix build-system linux-module))

(include "rpi-kernel.scm")

(define-public bq24179-charger-linux-module
  (package
    (name "bq24179-charger-linux-module")
    (version "0.1")
    (source
     (file-append (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git")
             (commit "589dab165f7a55eec0cc5fa25cc0bf892f4aa52c")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "002y8x0dmglhfgm60az6059jjnfm5q1zxdfp0b4s8dqybhjbdhb5")))
		 "/modules/bq24179_charger")
		)
    (build-system linux-module-build-system)
    (arguments
     (list #:tests? #f #:linux linux-raspberry-5.10))                ; no test suite, RPI Linux
    (home-page "https://github.com/Seeed-Studio/seeed-linux-dtoverlays/tree/master/modules/bq24179_charger")
    (synopsis "Linux kernel module for bq24179_charger found in Seed Studio ReTerminal")
    (description
     "This is the Linux kernel bq24179_charger driver")
    (license license:gpl2)))

(define-public lis3lv02d-linux-module
  (package
    (name "lis3lv02d-linux-module")
    (version "0.1")
    (source
     (file-append (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git")
             (commit "589dab165f7a55eec0cc5fa25cc0bf892f4aa52c")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "002y8x0dmglhfgm60az6059jjnfm5q1zxdfp0b4s8dqybhjbdhb5")))
		 "/modules/lis3lv02d")
		)
    (build-system linux-module-build-system)
    (arguments
     (list #:tests? #f #:linux linux-raspberry-5.10))                ; no test suite, RPI Linux
    (home-page "https://github.com/Seeed-Studio/seeed-linux-dtoverlays/tree/master/modules/lis3lv02d")
    (synopsis "Linux kernel module for GROVE 3-Axis Digital Accelerometer found in Seed Studio ReTerminal")
    (description
     "This is the Linux kernel GROVE 3-Axis Digital Accelerometer driver")
    (license license:gpl2)))

(define-public ltr30x-linux-module
  (package
    (name "ltr30x-linux-module")
    (version "0.1")
    (source
     (file-append (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git")
             (commit "589dab165f7a55eec0cc5fa25cc0bf892f4aa52c")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "002y8x0dmglhfgm60az6059jjnfm5q1zxdfp0b4s8dqybhjbdhb5")))
		 "/modules/ltr30x")
		)
    (build-system linux-module-build-system)
    (arguments
     (list #:tests? #f #:linux linux-raspberry-5.10))                ; no test suite, RPI Linux
    (home-page "https://github.com/Seeed-Studio/seeed-linux-dtoverlays/tree/master/modules/ltr30x")
    (synopsis "Linux kernel module for ltr30x ambient light and proximity sensor found in Seed Studio ReTerminal")
    (description
     "This is the Linux kernel ltr30x ambient light and proximity sensor driver")
    (license license:gpl2)))

(define-public mipi_dsi-linux-module
  (package
    (name "mipi_dsi-linux-module")
    (version "0.1")
    (source
     (file-append (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git")
             (commit "589dab165f7a55eec0cc5fa25cc0bf892f4aa52c")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "002y8x0dmglhfgm60az6059jjnfm5q1zxdfp0b4s8dqybhjbdhb5")))
		 "/modules/mipi_dsi")
		)
    (build-system linux-module-build-system)
    (arguments
     (list #:tests? #f #:linux linux-raspberry-5.10))                ; no test suite, RPI Linux
    (home-page "https://github.com/Seeed-Studio/seeed-linux-dtoverlays/tree/master/modules/mipi_dsi")
    (synopsis "Linux kernel module for MIPI-DSI panel with touch panel attached to I2C bus found in Seed Studio ReTerminal")
    (description
     "This is a linux kernel driver for MIPI-DSI panel with touch panel attached to I2C bus.")
    (license license:gpl2)))

mipi_dsi-linux-module