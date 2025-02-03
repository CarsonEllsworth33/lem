#| 
What needs to be done for this package to work
Need to get contents of buffer passed into parser
Order of operations should be roughly
* Spc Spc - lemon-c-mode
* look for libtree-sitter-c library
* Error out or load lib
* now that lang is registered, grab buffer contents
* generate parse tree of buffer
* grab positional data & highlight important syntax


This package should handle loading the library requested by the lemon mode, grab buffer contents
and generate the parse tree. Pass this back to lemon-<lang>-mode
The specific lemon-<lang>-mode should do the syntax highlighting.
|#
(defpackage :lem/lemon-tree
  (:use :cl
        :lem)
  (:import-from :cl-tree-sitter #:parse-string) 
  (:import-from :cl-tree-sitter #:register-language)
  (:documentation "")
  (:export :*lemon-current-parser*
           #:lemon-tree-register-language
           #:lemon-tree-parse-buffer))

(in-package :lem/lemon-tree)

(defvar *lemon-current-parser*
  nil 
  "This is the current parser currently being used by lemon-tree
       this is set by the lemon tree language mode")

;; Does this need to be a macro?
(defun lemon-tree-register-language (name lib &key (fn-name nil))
  "This needs to be called by lemon-<lang>-mode-hook"
  (eval `(register-language ,name ,lib :fn-name ,fn-name)))

(defun lemon-tree-parse-buffer ()
  (let ((parsable-text (buffer-text (current-buffer)))) 
    (parse-string *lemon-current-parser* text)))
