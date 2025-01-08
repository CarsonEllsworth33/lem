(defsystem "lem-lemon-tree"
  :serial t
  :depends-on ("lem"
               "cl-tree-sitter")
  :components ((:module "./"
                :components ((:file "lemon-tree")))))