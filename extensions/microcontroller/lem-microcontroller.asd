(defsystem "lem-microcontroller"
  :serial t
  :depends-on ("lem/core")
  :components ((:module "./"
                :components ((:file "package")
                             (:file "boards")
                             (:file "projects")
                             (:file "microcontroller")))))
