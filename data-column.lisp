;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(cl:defpackage #:data-omnivore.data-column
  (:use #:cl
        #:anaphora
        #:decimal-omnivore.data-omnivore
        #:string-table.data-omnivore
        #:let-plus)
  (:export
   #:data-column
   #:data-column-add
   #:data-column-elements
   #:data-column-counts))

(in-package #:data-omnivore.data-column)



(defconstant +data-column-min-extension+ 32
  "")

(defclass data-column ()
  ((elements
    :initform (make-array +data-column-min-extension+
                          :adjustable t
                          :fill-pointer 0)
    :type vector
    :reader data-column-elements)
   (default-float-format
    :initarg :default-float-format
    :type symbol)
   (float-count
    :initform 0
    :type non-negative-integer)
   (integer-count
    :initform 0
    :type non-negative-integer)
   (map-count
    :initform 0
    :type non-negative-integer)
   (map-table
    :initarg :map-table
    :type string-table)
   (string-count
    :initform 0
    :type non-negative-integer)
   (string-table
    :initform (string-table)
    :type string-table)))

(defun data-column (&key map-alist (default-float-format 'double-float))
  (make-instance 'data-column
                 :default-float-format default-float-format
                 :map-table (aprog1 (string-table)
                              (loop for (string . value) in map-alist
                                    do (check-type value
                                                   (not (or integer float string)))
                                       (string-table-add it string value)))))

(defun data-column-add (data-column string)
  (let+ (((&slots-r/o elements default-float-format float-count integer-count
                      map-count map-table string-count string-table) data-column)
         (element (handler-case (prog1 (string-table-lookup map-table string)
                                  (incf map-count))
                    (string-table-not-found ()
                      (handler-case (aprog1 (parse-real string
                                                        :e-float default-float-format)
                                      (if (integerp it)
                                          (incf integer-count)
                                          (incf float-count)))
                        (parse-rational-error ()
                          (prog1 (string-table-intern string-table string string)
                            (incf string-count))))))))
    (vector-push-extend element elements +data-column-min-extension+)
    element))

(defun data-column-counts (data-column)
  (let+ (((&slots-r/o float-count integer-count map-count string-count)
          data-column))
    (list :float-count float-count
          :integer-count integer-count
          :map-count map-count
          :string-count string-count)))