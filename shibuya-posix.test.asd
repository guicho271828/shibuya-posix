#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#


(in-package :cl-user)
(defpackage shibuya-posix.test-asd
  (:use :cl :asdf))
(in-package :shibuya-posix.test-asd)


(defsystem shibuya-posix.test
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:shibuya-posix
               :fiveam)
  :components ((:module "t"
                :components
                ((:file "package"))))
  :perform (load-op :after (op c) (eval (read-from-string "(every #'fiveam::TEST-PASSED-P (5am:run! :shibuya-posix))"))
))
