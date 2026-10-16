(in-package :lem-microcontroller)
(defparameter *board-profiles* (make-hash-table))

(defstruct board-profile
  :board-name
  :upload-command
  :program-extension)

(defmacro defboard (name upload-command program-extension)
  `(progn
     (let ((profile 
             (make-board-profile :board-name ,name :upload-command ,upload-command
                                 :program-extension ,program-extension)))
       (if (not (gethash ,name *board-profiles*))
         (setf (gethash ,name *board-profiles*) profile)
         (message "Board profile with name: ~A already exists.~%Current profile: ~A~%Delete currently loaded profile then try again." ,name (gethash ,name *board-profiles*))))))

;; example board profile
(defboard :pico "picotool load" "uf2")