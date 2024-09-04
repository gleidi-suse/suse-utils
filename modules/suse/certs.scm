;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2023-2024 Giacomo Leidi <giacomo.leidi@suse.com>

(define-module (suse certs)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define %channel-root
  (string-append (current-source-directory) "/.."))

(define-public suse-certs
  (let ((revision "0"))
    (package
     (name "suse-certs")
     (version (string-append "0.0.0-" revision))
     (source
      (local-file (string-append %channel-root "/SUSE_Trust_Root.crt")))
     (build-system copy-build-system)
     (arguments
      (list #:install-plan #~'(("./SUSE_Trust_Root.crt" "/etc/ssl/certs/SUSE_Trust_Root.pem"))))
     (synopsis "CA certificates from SUSE")
     (description
      "This package provides certificates for SUSE's internal Certification
Authorities (CA).")
     (home-page "https://confluence.suse.com/display/enginfra/Getting+Started+with+SUSE+internal+CA")
     (license #f))))
