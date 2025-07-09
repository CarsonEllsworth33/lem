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
(defvar *serial-monitor-width* 50)


(defun read-serial-lines ()
  (loop
    (when (not *serial-stream*)
      (return))
    (handler-case
        (let ((line (read-line *serial-stream* nil nil)))
          (when line
            (setf *work-queue* 
                  (append *work-queue* (list
                                        (lambda ()
                                          (let ((point (buffer-point *serial-buffer*))
                                                (cb (current-buffer)))
                                            (setf lem/buffer/internal::*current-buffer* *serial-buffer*)
                                            (move-to-end-of-buffer)
                                            (lem:insert-string point (format nil "~A~%" line))
                                            (lem:redraw-display)
                                            (setf lem/buffer/internal::*current-buffer* cb))))))))
      (error (e) ;; Could also catch stream closed
        (format *error-output* "Serial error: ~a~%" e)
        (return)))
    (sleep 0.1)))

(defmacro print-with-newline ()
  )

(defun write-serial-line ()
  (loop
    (when *work-queue*
      (funcall (first *work-queue*))
      (setf *work-queue* (cdr *work-queue*)))
    (sleep 0.1)))

(defun redraw-buffer-if-focused ()
  (let ((window (lem:get-buffer-windows)))))

(defun start-serial-monitor (&key (port "/dev/ttyACM0"))
  (when *serial-read-thread*
    (format t "Serial monitor already running.~%")
    (return-from start-serial-monitor))
  (setf *serial-stream* (open port :direction :input :element-type 'character))
  (setf *serial-buffer* (lem:make-buffer "*serial-monitor*" :temporary t))
  (setf *serial-window*
        (lem:make-rightside-window *serial-buffer* :width *serial-monitor-width*))
  (setf *serial-read-thread*
        (bt2:make-thread #'read-serial-lines :name "serial-monitor-read-thread"))
  (setf *serial-write-thread*
        (bt2:make-thread #'write-serial-line :name "serial-monitor-write-thread")))

(defun stop-serial-monitor ()
  (when *serial-window*
    (lem:delete-window *serial-window*)
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
