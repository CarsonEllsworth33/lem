(defpackage :lem.strata
  (:use :cl :lem)) 

(in-package :lem.strata) 


;; Define constants here
(defvar *playing-p*) 
(defvar *strata-buffer*) 
(defvar *player*)

(defconstant +world-width+ 80) 
(defconstant +world-height+ 80) 


(defparameter *faction-attributes* 
  (map 'vector (lambda (color-name) (make-attribute :foreground color-name)) 
       '("red" "cyan" "yellow" "green"))) 

(defparameter *wood-attribute* (make-attribute :foreground "brown")) 
(defparameter *food-attribute* (make-attribute :foreground "magenta")) 
(defparameter *wall-attribute* (make-attribute :foreground "gray")) 

(defclass strata ()
  ((world-position ;; (Y X) or (line, column)
    :initform (random-world-point))
   (health
    :accessor health
    :initarg :health
    :initform 0)))

(defmethod strata-get-y-pos (strata)
  (car (slot-value strata 'world-position)))

(defmethod strata-get-x-pos (strata)
  (cadr (slot-value strata 'world-position)))


(defun insert-food ()
  (insert-string ))

(defun random-world-point ()
  (let ((x (random +world-width+))
        (y (random +world-height+)))
    (list y x))) 

(defun strata-move-up (strata)
  (incf (strata-get-y-pos strata)))
(defun strata-move-down (strata)
  (decf (strata-get-y-pos strata)))
(defun strata-move-right (strata)
  (incf (strata-get-x-pos strata)))
(defun strata-move-left (strata)
  (decf (strata-get-x-pos strata)))

(defun strata-quit ()
  (setf *playing-p* nil))

;; Lem specific things
(define-major-mode strata-mode nil
    (:name "strata"
     :keymap *strata-mode-keymap*)) 

(define-command strata () ()
  (setf *player* (make-instance 'strata))
  (setf *strata-buffer* (make-buffer "*strata*")) 
  (switch-to-buffer *strata-buffer*)
  (strata-mode)
  (add-hook (variable-value 'kill-buffer-hook :buffer *strata-buffer*)
            #'(lambda (buffer) (declare (ignore buffer)) (strata-quit)))) 

(define-command move-player-up () ()
  (strata-move-up *player*))
(define-command move-player-down () ()
  (strata-move-down *player*))
(define-command move-player-left () ()
  (strata-move-left *player*))
(define-command move-player-right () ()
  (strata-move-right *player*))

;; Player Actions
(define-key *strata-mode-keymap* "w" 'move-player-up)
(define-key *strata-mode-keymap* "a" 'move-player-left)
(define-key *strata-mode-keymap* "s" 'move-player-down)
(define-key *strata-mode-keymap* "d" 'move-player-right)
