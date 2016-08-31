(load "main.lisp")

[defun sum (list)
	{if (rest list)
		[+ [first list] [sum [rest list]]]
		[first list]}
]

[defmacro test-sum (total list)
	`[assert [= ,total (sum ,list)]]
]

[defmacro test-sums (&rest totel)
	`{dolist [i ',totel]
		[test-sum (first i) (rest (rest i))]}
]

[test-sums
	[0 : 0]
	[6 : 1 2 3]
	[7 : 1 2 4]
	[9 : 1 2 6]
	[11 : 1 2 7 1]
]

[defmacro for (x a b code)
	`[do [[,x ,a [1+ ,x]]] [[>= ,x ,b]] ,code]
]

[load 'quicklisp]
[load "~/quicklisp/setup.lisp"]
; [quicklisp-quickstart:install]
[ql:quickload :cl-glfw3]
[princ '["Somethng" 32]]

(defun render ()
  (gl:clear :color-buffer)
  (gl:with-pushed-matrix
    (gl:color 1 1 1)
    (gl:rect -25 -25 25 25)))

(defun set-viewport (width height)
  (gl:viewport 0 0 width height)
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (gl:ortho -50 50 -50 50 -1 1)
  (gl:matrix-mode :modelview)
  (gl:load-identity))

(def-window-size-callback update-viewport (window w h)
  (declare (ignore window))
  (set-viewport w h))

(defun basic-window-example ()
  ;; Graphics calls on OS X must occur in the main thread
  (with-body-in-main-thread ()
    (with-init-window (:title "Window test" :width 600 :height 400)
      (setf %gl:*gl-get-proc-address* #'get-proc-address)
      (set-key-callback 'quit-on-escape)
      (set-window-size-callback 'update-viewport)
      (gl:clear-color 0 0 0 0)
      (set-viewport 600 400)
      (loop until (window-should-close-p)
         do (render)
         do (swap-buffers)
do (poll-events)))))
