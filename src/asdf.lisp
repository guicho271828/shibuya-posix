
(in-package :shibuya-posix.impl)


(defun header-xml (header-name) ;; aio etc.
  (uiop:with-temporary-file (:stream s :direction :output :pathname p)
    (format s "#include <~a.h>~%" header-name)
    (clear-output s)
    (close s)
    (let ((xml (make-pathname :defaults p :type "xml")))
      (uiop:run-program
       (format nil "gccxml ~a -fxml=~a" p xml)
       :output *standard-output*
       :error-output *error-output*)
      xml)))

(defun generate-grovel-file (header-name
                             &optional (*default-pathname-defaults*
                                        *default-pathname-defaults*))
  (let ((p (merge-pathnames (format nil "~a.lisp" header-name)))
        (form (make-groveller-form (header-xml header-name))))
    (with-open-file (s p
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede)
      (write form :stream s))
    p))

;; (let ((*package* (find-package "CFFI-GROVEL")))

;; (asdf:system-relative-pathname
;;                       :shibuya-posix
;;                       (format nil "c/~a.xml" header))
