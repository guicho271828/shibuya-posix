#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :shibuya-posix.impl
  (:use :cl :cffi :trivia :alexandria :plump)
  (:nicknames :susv4))
