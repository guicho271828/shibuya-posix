#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

#|
  Provides a complete CFFI interface to posix standards

  Author: Masataro Asai (guicho2.71828@gmail.com)
|#



(in-package :cl-user)
(defpackage shibuya-posix-asd
  (:use :cl :asdf))
(in-package :shibuya-posix-asd)


(defsystem shibuya-posix
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :defsystem-depends-on (:cffi-grovel)
  :depends-on (:cffi)
  :components ((:module "src"
                :components
                ((:file "package"))))
  :description "Provides a complete CFFI interface to ALL posix standard
  header files"
  :in-order-to ((test-op (load-op :shibuya-posix.test))))
