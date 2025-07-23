(defpackage :lem-serial-monitor
  (:use :cl :lem :lem/buffer)
  (:export :start-serial-monitor
           :stop-serial-monitor
           :*serial-monitor-width*))

(in-package :lem-serial-monitor)

(defvar *serial-stream* nil)
(defvar *serial-read-thread* nil)
(defvar *serial-write-thread* nil)
(defvar *serial-buffer* nil)
(defvar *work-queue* nil)
(defvar *serial-window*)
(defvar *serial-monitor-width* 25)
(defvar *serial-monitor-input-height* 10)
(defparameter *baudrate* 115200)


(defclass serial-port ()
  ((port
     :initarg :port
     :initform (error "Enter a port name")
     :reader port-name)
   (baudrate
    :initarg :baudrate
    :initform (error "Enter a baudrate")
    :accessor baudrate)))

(defun read-serial-data ()
  (loop
    (when (not *serial-stream*)
      (return))
    (handler-case
        (let ((char (read-char *serial-stream* nil nil nil)))
          (when char
            (setf *work-queue* 
                  (append *work-queue* (list (write-char-to-serial-monitor char))))))
      (error (e) ;; Could also catch stream closed
        (format *error-output* "Serial error: ~a~%" e)
        (return)))
    (sleep 0.01)))

(defun write-char-to-serial-monitor (char)
  (lambda ()
    (let ((point (buffer-point *serial-buffer*)))
      (lem:insert-character point char)
      (send-event (lambda () (redraw-display))))))

(defun write-serial-data ()
  (loop
    (when *work-queue*
      (funcall (first *work-queue*))
      (setf *work-queue* (cdr *work-queue*)))
    (sleep 0.01)))

(defun clear-serial-buffer ()
  (clear-output *serial-buffer*))

(defun make-serial-read-and-input-windows (buffer)
  (let* ((serial-out (pop-to-buffer buffer)))
    (list nil serial-out)))

(defun start-serial-monitor (&key (port "/dev/ttyACM0"))
  (when *serial-read-thread*
    (format t "Serial monitor already running.~%")
    (return-from start-serial-monitor))
  (setf *serial-stream* (open port :direction :input :element-type 'character))
  (setf *serial-buffer* (make-buffer "*serial-monitor*" :temporary t)) 
  (setf *serial-window* (make-serial-read-and-input-windows *serial-buffer*)) 
  (setf *serial-read-thread*
        (bt2:make-thread #'read-serial-data :name "serial-monitor-read-thread"))
  (setf *serial-write-thread*
        (bt2:make-thread #'write-serial-data :name "serial-monitor-write-thread")))

(defun stop-serial-monitor ()
  (when *serial-window*
    (loop :for window :in *serial-window* :do 
             (if (null window)
                 nil
                 (lem:delete-window window)))
    (setf *serial-window* nil))
  (when *serial-buffer*
    (lem:delete-buffer *serial-buffer*)
    (setf *serial-buffer* nil))
  (when *serial-stream*
    (close *serial-stream*)
    (setf *serial-stream* nil))
  (when *serial-read-thread*
    (bt2:destroy-thread *serial-read-thread*)
    (setf *serial-read-thread* nil))
  (when *serial-write-thread*
    (bt2:destroy-thread *serial-write-thread*)
    (setf *serial-write-thread* nil)))
