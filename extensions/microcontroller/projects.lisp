(in-package :lem-microcontroller)

(defparameter *project-profiles* (make-hash-table))
(defparameter *active-project* nil)

(defstruct project-profile
  :project-name ;; name of the executable without the extension ex: hello.uf2 would just be hello
  :project-type ;; either cmake or another supported project type
  :project-root ;; root to the project
  :compile-command ;; the command used to compile the project, this can be inferred via the project type but can still be defined since flags could also be desired for compiling
  :build-dir ;; name of the build directory within the project. This is used for compiling and finding the compiled program
  )


(defmacro defproject (name project-root build-dir &key (type :cmake) (compile-command "make"))
  `(progn
     (let ((profile 
             (make-project-profile :project-name ,name
                                   :project-type ,type
                                   :project-root (pathname ,project-root)
                                   :build-dir (pathname ,build-dir)
                                   :compile-command ,compile-command)))
       (if (not (gethash ,name *project-profiles*))
           (setf (gethash ,name *project-profiles*) profile)
           (message "Project profile with name: ~A already exists.~%Current profile: ~A~%Delete currently loaded profile then try again." ,name (gethash ,name *project-profiles*))))))

;; example project profile
;; (defproject "example"
  ;; "/path/to/project-root" 
  ;; "build" 
  ;; :type :cmake 
  ;; :compile-command "make")
