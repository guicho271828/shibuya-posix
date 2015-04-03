#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :shibuya-posix.symbols
  (:use :cl)
  (:export #+nil :progn
           :include
           #+nil :in-package
           :ctype
           :constant
           :define
           :cc-flags
           :cstruct
           :cunion
           :cstruct-and-class
           :cvar
           :cenum
           :constantenum
           :bitfield))

(defpackage :shibuya-posix.impl
  (:use :cl :cffi :trivia :alexandria :plump)
  (:import-from :shibuya-posix.symbols
                #+nil :progn
                :include
                #+nil :in-package
                :ctype
                :constant
                :define
                :cc-flags
                :cstruct
                :cunion
                :cstruct-and-class
                :cvar
                :cenum
                :constantenum
                :bitfield)
  (:nicknames :susv4)
  (:export
   #:generate-grovel-file
   #:generate-cffi-file))



