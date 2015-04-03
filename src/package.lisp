#|
  This file is a part of shibuya-posix project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :shibuya-posix.impl
  (:use :cl :cffi :trivia :alexandria :plump)
  (:nicknames :susv4))
(in-package :shibuya-posix.impl)

;; blah blah blah.

(defun posix-xml-parse (header) ;; aio, pthread, etc
  (with-open-file (s (asdf:system-relative-pathname
                      :shibuya-posix
                      (format nil "c/~a.xml" header)))
    (plump:parse s)))

(defun xml-body (header)
  (child-elements (find-if #'gcc-xml-p (children (posix-xml-parse header)))))

(defun gcc-xml-p (dom)
  (match dom
    ((element (tag-name "GCC_XML")) t)))

(defvar *body*)

(defmacro define-gccxml-tag-predicate (tag-name-string)
  (let ((type (intern (format nil "%~:@(~a~)" tag-name-string)))
        (pred (intern (format nil "%~:@(~a~)-P" tag-name-string)))
        (list (intern (format nil "%~:@(~a~)S" tag-name-string))))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       (deftype ,type () 'element)
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

;;; util

(defun %name (dom) (attribute dom "name"))
(defun %type (dom) (%find-type (attribute dom "type"))) ;; typename can be referenced by id

(defpattern referenced-type (subpattern)
  (with-gensyms (id)
    `(and (string* #\_)
          (guard ,id (get-element-by-id *body* ,id)
                 (get-element-by-id *body* ,id)
                 ,subpattern))))

(defun split (str)
  (labels ((rec (str current acc)
             (match str
               ((list* #\Space rest)
                (rec rest nil (cons (nreverse current) acc)))
               ((list* c rest)
                (rec rest (cons c current) acc)))))
    (mapcar #'string (nreverse (rec (coerce str 'list) nil nil)))))

(defun remove-underscores (string)
  (labels ((rec (x)
             (match x
               ((list* #\_ rest)
                (rec rest))
               (_ x))))
    (mapcar #'string (rec (coerce string 'list)))))
  
(defun %parse-type (string)
  (ematch (split string)
    ((list type)
     (make-keyword (string-upcase type)))
    ((and types (list* _ _ _))
     (mapcar (lambda (type) (make-keyword (string-upcase type)))
             types))))

(defun %find-type (typename)
  (ematch typename
    ((referenced-type
      (and node (element (tag-name (or "FundamentalType"
                                       "Typedef"
                                       "Struct"
                                       "Union"
                                       "Field"
                                       "Enumeration")))))
     (ignore-errors (%parse-type (%name node))))
    ((referenced-type
      (and node (element (tag-name (or "PointerType"
                                       "ArrayType"
                                       "CvQualifiedType")))))
     :pointer
     #+nil
     (values :pointer (%type node)))
    ((not (string* #\_))
     (ignore-errors (%parse-type typename)))))

(defun %extern-p (dom)
  (attribute dom "extern"))

(defun %builtin-p (dom)
  (match (%name dom)
    ((string* #\_ #\_) t)))

(defun %anonymous-p (dom)
  (match (%name dom)
    ((string* #\.) t)))


;;; enum
(define-gccxml-tag-predicate "Enumeration")
(defun %enum-elements (dom)
  (map 'list #'%name (child-elements dom)))

(defun enum-grovel-form (dom)
  (let ((name (%name dom))
        (elist (%enum-elements dom)))
    (match dom
      ((string* #\.)
       ;; anonymous : symbolic constant
       `(progn
          ,@(mapcar
             (lambda (x) `(constant ,(read-from-string x) ,x))
             elist)))
      (_
       `(cenum ,name
               ,@(mapcar
                  (lambda (x) `(,(read-from-string x) ,x))
                  elist))))))

#+nil
(map 'list #'enum-grovel-form (%enumerations "aio"))

;;; function
(define-gccxml-tag-predicate "Function")
(defun %function-arguments (dom)
  (map 'list
       (lambda (ev)
         (list (intern
                (remove-underscores (string-upcase (%name ev))))
               (%type ev)))
       (child-elements dom)))

(defun %function-name (dom) (%name dom))
(defun %function-return-type (dom) (%find-type (attribute dom "returns")))
(defun posix-function-p (dom)
  (and (%extern-p dom)
       (not (%builtin-p dom))))
(defun function-cffi-form (dom)
  (match dom
    ((%function name arguments return-type)
     `(cffi:defcfun (,(read-from-string name) ,name) ,return-type
        ,@arguments))))

#+nil
(map 'list #'function-cffi-form (remove-if-not #'posix-function-p (%functions "aio")))
;;; typedef
(define-gccxml-tag-predicate "Typedef")
(defun %typedef-name (dom) (%name dom))
(defun %typedef-type (dom) (%type dom))
(defun typedef-grovel-form (dom)
  (ematch dom
    ((%typedef name)
     `(ctype ,(make-keyword (string-upcase name)) ,name))))

#+nil
(map 'list #'typedef-grovel-form (%typedefs "aio"))
;;; union
(define-gccxml-tag-predicate "Union")
(defun %union-name (dom) (%name dom))
(defun %union-members (dom)
  (remove-if-not #'fourth ;; type is NIL
                 (mapcar (lambda (m) (let ((node (get-element-by-id *body* m)))
                                       (list (intern (string-upcase (%name node)))
                                             (%name node)
                                             :type (%type node))))
                         (split (attribute dom "members")))))
(defun union-grovel-form (dom)
  (ematch dom
    ((%union name members)
     (and name
          `(cunion ,(intern (string-upcase name)) ,name
                   ,members)))))

#+nil
(map 'list #'union-grovel-form (remove-if #'%builtin-p (%unions "aio")))


;;; struct
(define-gccxml-tag-predicate "Struct")
(defun %struct-name (dom) (%name dom))
(defun %struct-members (dom)
  (remove-if-not #'fourth ;; type is NIL
                 (mapcar (lambda (m) (let ((node (get-element-by-id *body* m)))
                                       (list (intern (string-upcase (%name node)))
                                             (%name node)
                                             :type (%type node))))
                         (split (attribute dom "members")))))
(defun struct-grovel-form (dom)
  (ematch dom
    ((%struct name members)
     (and name
          `(cstruct ,(intern (string-upcase name)) ,name
                    ,members)))))

#+nil
(map 'list #'struct-grovel-form (remove-if #'%builtin-p (%structs "aio")))


;;; misc
(define-gccxml-tag-predicate "Namespace")
(define-gccxml-tag-predicate "FundamentalType")
(define-gccxml-tag-predicate "ArrayType")
(define-gccxml-tag-predicate "PointerType")
(define-gccxml-tag-predicate "Field")
(define-gccxml-tag-predicate "Destructor")
(define-gccxml-tag-predicate "OperatorMethod")
(define-gccxml-tag-predicate "Constructor")
(define-gccxml-tag-predicate "ReferenceType")
(define-gccxml-tag-predicate "FunctionType")
(define-gccxml-tag-predicate "CvQualifiedType")


;;; make-groveller-form

(defun make-groveller-form (header)
  `(progn
     (include ,(format nil "~a.h" header))
     ,@(remove nil (map 'list #'enum-grovel-form (%enumerations header)))
     ,@(remove nil (map 'list #'typedef-grovel-form (%typedefs header)))
     ,@(remove nil (map 'list #'union-grovel-form (%unions header)))
     ,@(remove nil (map 'list #'struct-grovel-form (%structs header)))))

(defun make-cffi-load-form (header)
  `(progn
     ,@(remove nil (map 'list #'function-cffi-form
                        (remove-if #'%builtin-p (%functions header))))))
