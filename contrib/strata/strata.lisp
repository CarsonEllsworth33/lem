(defpackage :lem.strata
  (:use :cl :lem)) 

(in-package :lem.strata) 

(define-major-mode strata-mode nil
    (:name "strata"
     :keymap *strata-mode-keymap*)) 

;; Define constants here

(defparameter *faction-attributes* 
  (map 'vector (lambda (color-name) (make-attribute :foreground color-name)) 
       '("red" "cyan" "yellow" "green"))) 

(defparameter *wood-attribute* (make-attribute :foreground "brown"))
(defparameter *food-attribute* (make-attribute :foreground "magenta"))
(defparameter *wall-attribute* (make-attribute :foreground "gray"))

(defvar *strata-buffer*) 

(define-command strata () ()
  (setf *strata-buffer* (make-buffer "*strata*")) 
  (switch-to-buffer *strata-buffer*)
  (strata-mode)
  (add-hook (variable-value 'kill-buffer-hook :buffer *strata-buffer*)
            #'(lambda (buffer) (declare (ignore buffer)) (strata-quit)))) 