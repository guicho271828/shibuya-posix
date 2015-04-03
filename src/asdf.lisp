
(in-package :shibuya-posix.impl)


(defun header-xml (header-name) ;; aio etc.
  (uiop:with-temporary-file (:stream s :direction :output :pathname p)
    (format s "#include <~a.h>~%" header-name)
    (clear-output s)
    (close s)
    (let ((xml (make-pathname :defaults p :type "xml")))
      (format t "~&; Extracting the XML metadata of ~a in ~a..." p xml)
      (uiop:run-program
       (format nil "gccxml ~a -fxml=~a" p xml)
       :ignore-error-status t
       :output *standard-output*
       :error-output *error-output*)
      xml)))

(defun generate-grovel-file (header-name
                             &optional (*default-pathname-defaults*
                                        *default-pathname-defaults*))
  (let ((p (merge-pathnames (format nil "~a-grovel.lisp" header-name)))
        (pkg (package-name *package*)))
    (with-open-file (s p
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede)
      (let ((*package* (find-package "SHIBUYA-POSIX.SYMBOLS")))
        (write (make-groveller-form (header-xml header-name) pkg) :stream s)))
    p))

(defun generate-cffi-file (header-name
                             &optional (*default-pathname-defaults*
                                        *default-pathname-defaults*))
  (let ((p (merge-pathnames (format nil "~a-cffi.lisp" header-name)))
        (pkg (package-name *package*)))
    (with-open-file (s p
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede)
      (print `(in-package ,pkg) s)
      (print (make-cffi-load-form (header-xml header-name)) s))
    p))

