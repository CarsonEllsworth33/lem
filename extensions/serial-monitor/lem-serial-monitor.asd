(defsystem "lem-serial-monitor"
  :serial t
  :depends-on ("lem")
  :components ((:module "./"
                :components ((:file "serial-monitor")))))
