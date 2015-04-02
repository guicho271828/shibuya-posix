#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :shibuya-posix
  (:use :cl :cffi :trivia :alexandria)
  (:import-from :plump :children :element))
(in-package :shibuya-posix)

;; blah blah blah.

(defun parse (header) ;; aio, pthread, etc
  (with-open-file (s (asdf:system-relative-pathname
                      :shibuya-posix
                      (format nil "c/~a.xml" header)))
    (plump:parse s)))

(defun xml-body (header)
  (plump:child-elements (find-if #'gcc-xml-p (children (parse header)))))

(defun gcc-xml-p (dom)
  (match dom
    ((element (tag-name "GCC_XML")) t)))

(defmacro define-gccxml-tag-predicate (tag-name-string)
  (let ((pred (intern (format nil "%~:@(~a~)-P" tag-name-string)))
        (list (intern (format nil "%~:@(~a~)S" tag-name-string))))
    `(progn
       (defun ,pred (dom)
         (match dom
           ((element (tag-name ,tag-name-string)) t)))
       (defun ,list (header)
         (remove-if-not #',pred (xml-body header))))))

;; all tag names in gcc-xml
#+nil
("Namespace" "Enumeration" "Function" "Typedef" "Union" "FundamentalType"
 "ArrayType" "Struct" "PointerType" "Field" "Destructor" "OperatorMethod"
 "Constructor" "ReferenceType" "FunctionType" "CvQualifiedType" "File")

#+nil
(remove-duplicates (map 'list #'plump:tag-name (xml-body "aio")) :test #'equal)

(define-gccxml-tag-predicate "Namespace")
(define-gccxml-tag-predicate "Enumeration")
(define-gccxml-tag-predicate "Function")
(define-gccxml-tag-predicate "Typedef")
(define-gccxml-tag-predicate "Union")
(define-gccxml-tag-predicate "FundamentalType")
(define-gccxml-tag-predicate "ArrayType")
(define-gccxml-tag-predicate "Struct")
(define-gccxml-tag-predicate "PointerType")
(define-gccxml-tag-predicate "Field")
(define-gccxml-tag-predicate "Destructor")
(define-gccxml-tag-predicate "OperatorMethod")
(define-gccxml-tag-predicate "Constructor")
(define-gccxml-tag-predicate "ReferenceType")
(define-gccxml-tag-predicate "FunctionType")
(define-gccxml-tag-predicate "CvQualifiedType")
(define-gccxml-tag-predicate "File")

;; (%enumerations "aio")
;; #(#<ELEMENT Enumeration {CABF0B9}> #<ELEMENT Enumeration {CB10901}>
;;   #<ELEMENT Enumeration {CB14C59}> #<ELEMENT Enumeration {CB1DD51}>)

