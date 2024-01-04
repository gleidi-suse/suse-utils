;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2023-2024 Giacomo Leidi <giacomo.leidi@suse.com>

(define-module (suse release)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cdrom)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages php)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages swig)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject))

(define-public python-pycdio
  (package
   (inherit libcdio)
   (name "python-pycdio")
   (version "2.1.1")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "pycdio" version))
     (sha256
      (base32 "1y590j804f2chpw0dyvwlmrmk7rzbp0y58idrfib3dslqnw4swv1"))))
   (build-system python-build-system)
   (inputs
    (list libcdio))
   (native-inputs
    (list pkg-config python-setuptools swig python-nose))))

(define-public python-cmdln
  (package
    (name "python-cmdln")
    (version "2.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "cmdln" version ".zip"))
       (sha256
        (base32 "083ydl0yzfx88x4jcsizagxsf5wzf8q3g2va2vrzajabj64ns0wv"))))
    (build-system pyproject-build-system)
    (native-inputs (list unzip))
    (home-page "http://github.com/trentm/cmdln")
    (synopsis
     "An improved cmd.py for writing multi-command scripts and shells.")
    (description
     "An improved cmd.py for writing multi-command scripts and shells.")
    (license #f)))

(define* (make-openSUSE-release-tools #:key url commit version hash)
  (package
   (name "openSUSE-release-tools")
   (version version)
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url url)
                  (commit commit)))
            (file-name (git-file-name "openSUSE-release-tools" version))
            (sha256
             (base32
              hash))))
   (build-system gnu-build-system)
   (arguments
    (list #:tests? #f
          #:make-flags #~(list (string-append "DESTDIR=" #$output))
          #:imported-modules `((guix build python-build-system)
                               ,@%gnu-build-system-modules)
          #:phases #~(modify-phases %standard-phases
                                    (delete 'configure)
                                    (delete 'build)
                                    ;; (replace 'check
                                    ;;   (lambda _
                                    ;;     (invoke "make" "test")))
                                    (add-after 'install 'add-install-to-pythonpath
                                               (@@ (guix build python-build-system)
                                                   add-install-to-pythonpath))
                                    (add-after 'add-install-to-pythonpath 'wrap-for-python
                                               (@@ (guix build python-build-system) wrap)))))
   (inputs (list perl
                 php
                 python
                 rpm))
   (home-page "https://github.com/openSUSE/openSUSE-release-tools")
   (synopsis "Tools to aid in staging and release work for openSUSE/SUSE")
   (description
    "This repository contains a set of tools to aid in the process of building,
testing and releasing (open)SUSE based distributions and their corresponding
maintenance updates.")
   (license license:gpl2)))

(define-public openSUSE-release-tools/g7
  (let* ((commit "1c38b48ea5f84c18cfa21de3f0c6eafb8b249a4b")
         (version (git-version "0.0.0" "0" commit)))
    (make-openSUSE-release-tools #:url "https://github.com/g7/openSUSE-release-tools"
                                 #:commit commit
                                 #:version version
                                 #:hash "1p0jinzp4lzc0mqjndy8mrjldi8h8s19hy3hxyjc0bm9jlhx0b6b")))
(define-public factory-news/g7
  (package
   (inherit openSUSE-release-tools/g7)
   (name "openSUSE-release-tools-factory-news")
   (arguments
    (substitute-keyword-arguments (package-arguments openSUSE-release-tools/g7)
     ((#:phases phases)
      #~(modify-phases #$phases
         (replace 'install
          (lambda _
            (let ((bin (string-append #$output "/bin")))
              (mkdir-p bin)
              (symlink (string-append #$(this-package-input "python") "/bin/python3")
                       (string-append bin "/python.py"))
              (install-file "factory-package-news/factory-package-news.py" bin))))))))
   (inputs (list python
                 python-cmdln
                 python-pycdio
                 rpm))))
