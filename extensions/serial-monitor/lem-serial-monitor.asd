(defsystem "lem-serial-monitor"
  :serial t
  :depends-on ("lem/core")
  :components ((:module "./"
                :components ((:file "serial-monitor")))))
