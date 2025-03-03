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
and generate the parse tree. Should the parse tree make a tm-patterns like make-tmlanguage-c in
grammers.lisp?

Pass this back to lemon-<lang>-mode
The specific lemon-<lang>-mode should do the syntax highlighting. (maybe not)

Helpful info:
macros.lisp defines the syntax highlighting by assigning for example
(lem:syntax-string-attribute :foreground (color :base02))
These colors are defined in color.lisp iirc

Note taken Mar-01 - When a complex enough source program is created
    I notice that a lot of nils in the node tree are present which
    seem to correlate to where there should be strings of what the 
    symbol is. ex. "int" for a type, "memory_size" for an identifier 
    or "24" in the case of number literals. This could mean that if 
    I find a way to add these strings to the node tree then all I 
    would need to do is to search the list for strings and then I 
    have my keywords for the language. I would just need to skip 
    the identifier strings and add all others to the tokens for
    highlighting. which seems possible to do.

Note taken Mar-02 - Just a break down of the node structure used in
    cl-tree-sitter.
(defstruct (node (:type list))  ;; Instances of this struct are always of type list
  type                          ;; The tree-sitter type derived from the parser eg. :Function-definition
  range                         ;; list of the form ((start row col ) (end row col )) where end is exclusive [start, end)
  children)                     ;; another node struct or nil

    I also figured out about the produce-cst keyword used in parse-string
    to create the full cst rather than just the abstract syntax tree.
    Which I think will be useful later on down the line but for now is
    just clutter on the screen.

    Also in regard to Mar-01 note about the nils. Those nils are just
    showing that node as being a leaf node rather (having no children).
    In parser terms that symbol is a terminating production.

    It seems like I need to create a tree walking algorithm that grabs
    the range from the leaf nodes and extract the substring from the
    source code.
|#
(defpackage :lem/lemon-tree
  (:use :cl
        :lem)
  (:import-from :cl-tree-sitter #:parse-string) 
  (:import-from :cl-tree-sitter #:register-language)
  (:import-from :cl-tree-sitter #:node-children)
  (:import-from :cl-tree-sitter #:node-range)
  (:import-from :cl-tree-sitter #:node-type)
  (:documentation "")
  (:export :*lemon-current-parser*
           :*produce-cst*
           #:lemon-tree-register-language
           #:lemon-tree-parse-buffer
           #:lemon-tree-parse-string
           #:lemon-tree-parse-file))

(in-package :lem/lemon-tree)

(defvar *lemon-current-parser*
  nil 
  "This is the current parser currently being used by lemon-tree
       this is set by the lemon tree language mode")

(defvar *produce-cst* 
  nil
  "This variable is used to produce the contrete syntax tree if true.
       set this to nil to only get the abstract syntax tree") 

(defun lemon-tree-register-language (name lib &key (fn-name nil))
  "This needs to be called by lemon-<lang>-mode-hook"
  (eval `(register-language ,name ,lib :fn-name ,fn-name)))

(defun lemon-tree-parse-string (string)
  (parse-string *lemon-current-parser* string :produce-cst *produce-cst*)) 

(defun lemon-tree-parse-buffer ()
  (let ((parsable-text (buffer-text (current-buffer)))) 
    (lemon-tree-parse-string parsable-text)))

(defun lemon-tree-parse-file (file)
  (let ((string (uiop:read-file-string file)))
    (lemon-tree-parse-string string))) 

(defun lemon-tree-walk (tree)
  "This attempts to walk a CST or AST and return a list of strings
   Possibly allow for a list of :Symbols to search for allowing other
   language parsers to accomodate for their unique productions.")




