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
|#

(defpackage :lemon-tree
  (:use :cl :lem :cl-tree-sitter)
  (:export :*lemon-tree-langs*
           :lemon-load-library))

(in-package :lemon-tree)
(ql:quickload :cl-tree-sitter) 

(defvar *lemon-tree-langs*)

(defun lemon-load-library (lang-symbol lib)
  "This needs to be called by lemon-<lang>-mode-hook"
  (cl-tree-sitter:register-language lang-symbol lib))