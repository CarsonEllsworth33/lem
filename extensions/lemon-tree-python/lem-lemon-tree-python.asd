(defsystem "lem-lemon-tree-python"
  :serial t
  :depends-on ("lem"
               "lem-lemon-tree")
  :components ((:module "./"
                :components ((:file "lemon-tree-python")))))