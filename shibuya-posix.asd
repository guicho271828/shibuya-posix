#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

#|
  Provides a complete CFFI interface to posix standards

  Author: Masataro Asai (guicho2.71828@gmail.com)
|#

(defsystem shibuya-posix
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :depends-on (:cffi :trivia :alexandria :plump)
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "parse-xml")
                 (:file "asdf"))
                :serial t))
  :description "Provides a complete CFFI interface to ALL posix standard
  header files"
  :in-order-to ((test-op (load-op :shibuya-posix.test))))

;; (:module "c"
;;  :perform
;;  (compile-op (op c)
;;              (uiop:run-program
;;               (format nil "cd ~a; make xml"
;;                       (asdf:component-pathname c))
;;               :output *standard-output*
;;               :error-output *error-output*)))
