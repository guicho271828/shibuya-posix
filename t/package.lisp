#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :shibuya-posix.test
  (:use :cl
        :shibuya-posix
        :fiveam))
(in-package :shibuya-posix.test)



(def-suite :shibuya-posix)
(in-suite :shibuya-posix)

;; run test with (run! test-name) 

(test shibuya-posix

  )



