(defun open-bracket-macro-character (stream char) `,(read-delimited-list #\] stream t))
(set-macro-character #\[ #'open-bracket-macro-character)
(set-macro-character #\] (get-macro-character #\)))
