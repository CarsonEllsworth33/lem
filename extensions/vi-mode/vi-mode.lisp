(defpackage :lem-vi-mode
  (:use :cl
        :lem
        :lem-vi-mode/core
        :lem-vi-mode/ex)
  (:import-from :lem-vi-mode/options
                :option-value)
  (:import-from :lem-vi-mode/leader
                :leader-key)
  (:import-from :lem-vi-mode/commands
                :vi-open-below
                :vi-open-above)
  (:import-from :lem-vi-mode/commands/utils
                :fall-within-line
                :define-motion
                :define-operator
                :define-text-object-command)
  (:import-from :lem-vi-mode/states
                :normal
                :insert
                :replace-state
                :*motion-keymap*
                :*normal-keymap*
                :*command-keymap*
                :*insert-keymap*
                :*inner-text-objects-keymap*
                :*outer-text-objects-keymap*
                :*operator-keymap*)
  (:import-from :lem-vi-mode/visual
                :visual
                :*visual-keymap*)
  (:import-from :lem-vi-mode/window
                :adjust-window-scroll)
  (:import-from :lem/kbdmacro
                :*macro-running-p*)
  (:import-from :alexandria
                :when-let
                :appendf)
  (:export :vi-mode
           :define-state
           :define-motion
           :define-operator
           :define-text-object-command
           :*motion-keymap*
           :*normal-keymap*
           :*command-keymap*
           :*insert-keymap*
           :*visual-keymap*
           :*operator-keymap*
           :*ex-keymap*
           :*inner-text-objects-keymap*
           :*outer-text-objects-keymap*
           :normal
           :insert
           :visual
           :option-value
           :leader-key))
(in-package :lem-vi-mode)

(defmethod post-command-hook ((state normal))
  (when *enable-repeat-recording*
    (let ((command (this-command)))
      (when (and (typep command 'vi-command)
                 (eq (vi-command-repeat command) t))
        (setf *last-repeat-keys* (vi-this-command-keys)))))
  (adjust-window-scroll)
  (fall-within-line (current-point)))

(defmethod post-command-hook ((state insert))
  (let* ((command (this-command))
         (this-command-keys (vi-this-command-keys))
         (pending-keys (cdr this-command-keys)))

    ;; NOTE: In `vim`, if you define `jk` as `Escape` in insert-mode. The effect is:
    ;; 1. In vi-insert-mode, press `j` and `k` will escape from insert-mode to normal-mode.
    ;; 2. In vi-insert-mode, press `j` and `<second-key>` will:
    ;;   a. If `<second-key>` is print-able-key, taken `e` key for example, then will self-insert `j` and self-insert `e`.
    ;;   b. If `<second-key>` is un-print-able-key, taken `Backspace` key for example, then will cancel the self-insert `j` and remain in vi-insert-mode.

    ;; FIXME: In `lem` impl, the `2.b` case will not cancel the self-insert of `j` key, because the code is written in post-command-hook, we have no chance to cancel the executing of `self-insert` command for the first-key.
    ;;
    ;;
    ;;
    ;; For self-insert command, we should also flush the pending-keys.
    ;; 1. Typically, the length of`this-command-keys` is only 1 key. (pending-keys = nil)
    ;; 2. If the length of `this-command-keys` > 1 key (pending-keys is not nil, they are used to disguish `self-insert` command and other commands), we need to flush `pending-keys`.
    (when (and
           (typep command 'self-insert)
           pending-keys)
      (loop :for key :in pending-keys
            ;; FIXME: the `named-key` is not identical to `print-able-key`. (Taken `Tab` key for example)
            :until (named-key-sym-p (key-sym key))
            :do
               (self-insert 1 (key-to-char key))))

    (when *enable-repeat-recording*
      (unless (or (and (typep command 'vi-command)
                       (eq (vi-command-repeat command) nil))
                  (eq (command-name (this-command)) 'vi-end-insert))
        (appendf *last-repeat-keys*
                 this-command-keys))))
  (adjust-window-scroll))

(defmethod post-command-hook :after ((state visual))
  (adjust-window-scroll))

(defmethod buffer-state-enabled-hook ((state insert) buffer)
  (when *enable-repeat-recording*
    (setf *last-repeat-keys* nil))
  (unless *macro-running-p*
    (buffer-undo-boundary buffer)
    (buffer-disable-undo-boundary buffer)))

(defmethod buffer-state-disabled-hook ((state insert) buffer)
  (unless *macro-running-p*
    (buffer-enable-undo-boundary buffer)))

(let ((replaced-chars '()))
  (defmethod pre-command-hook ((state replace-state))
    (let ((command (this-command)))
      (cond
        ((typep command 'self-insert)
         (if (end-line-p (current-point))
             (push nil replaced-chars)
             (progn
               (push (character-at (current-point)) replaced-chars)
               (delete-next-char))))
        ((eq (command-name command) 'delete-previous-char)
         (when-let ((char (pop replaced-chars)))
           (insert-character (current-point) char)
           (character-offset (current-point) -1)))
        (t
         (setf replaced-chars '()))))))

(defmethod buffer-state-enabled-hook ((state replace-state) buffer)
  (buffer-state-enabled-hook (ensure-state 'insert) buffer))

(defmethod buffer-state-disabled-hook ((state replace-state) buffer)
  (buffer-state-disabled-hook (ensure-state 'insert) buffer))
