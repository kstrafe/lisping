(load "brackets.lisp")

; Let's try doing some numerical solving of PDEs...
; Use the FTCS method with reservoirs on both ends
; A metal rod, 1D
; T^{n+1}_j = T^n_j + alpha*dt/dx/dx*(T_{j+1} - 2T + T_{j-1}
[defparameter bar-length 1]
[defparameter grid-points 100]
[defparameter bar-gold [make-array grid-points]]
[defparameter bar-gold-new [make-array grid-points]]
[defparameter alpha-gold [/ 1.27 10000]]
[defparameter init-temp 0.0]
[defparameter r 0.25]
[defparameter dx [/ bar-length [- grid-points 1]]]
[defparameter dt [/ [* r dx dx] alpha-gold]]
[defparameter t-end 400.0]
[defparameter time-current 0.0]
[defparameter left-temp -100.0]
[defparameter right-temp 500.0]

[dotimes (i grid-points)
	[setf [aref bar-gold-new i] init-temp]]
[setf [aref bar-gold-new 0] left-temp]
[setf [aref bar-gold-new [- grid-points 1]] right-temp]

[loop while [< time-current t-end] do
	[setf time-current [+ time-current dt]]

	[dotimes (i grid-points)
		[setf [aref bar-gold i] [aref bar-gold-new i]]]

	[do ((i 1 [+ i 1])) ((> i [- grid-points 2]))
		[setf [aref bar-gold-new i] [+ [aref bar-gold i] [* r [+ (aref bar-gold [+ i 1]) (* -2 [aref bar-gold i]) (aref bar-gold [- i 1])]]]]]

	]


[setf [aref bar-gold 1] [+ [aref bar-gold 1] [* r [+ (aref bar-gold [+ 1 1]) (* -2 [aref bar-gold 1]) (aref bar-gold [- 1 1])]]]]
[dotimes (i grid-points)
	[print [aref bar-gold i]]]
[exit]

[load "quicklisp"]
;[quicklisp-quickstart:install]
[load "~/quicklisp/setup.lisp"]

[ql:quickload :sdl2]
[ql:quickload :cl-opengl]


[defparameter value 1.0]
(defun basic-test []
  "The kitchen sink."
  (sdl2:with-init [:everything]
    [format t "Using SDL Library Version: ~D.~D.~D~%"
            sdl2-ffi:+sdl-major-version+
            sdl2-ffi:+sdl-minor-version+
            sdl2-ffi:+sdl-patchlevel+]
    [finish-output]

    (sdl2:with-window [win :flags '[:shown :opengl]]
      (sdl2:with-gl-context [gl-context win]
        (let [(controllers ())
              (haptic ())]

          ;; basic window/gl setup
          [format t "Setting up window/gl.~%"]
          [finish-output]
          [sdl2:gl-make-current win gl-context]
          [gl:viewport 0 0 800 600]
          [gl:matrix-mode :projection]
          [gl:ortho -2 2 -2 2 -2 2]
          [gl:matrix-mode :modelview]
          [gl:load-identity]
          [gl:clear-color 0.0 0.0 1.0 1.0]
          [gl:clear :color-buffer]

          [format t "Opening game controllers.~%"]
          [finish-output]
          ;; open any game controllers
          (loop for i from 0 upto [- (sdl2:joystick-count) 1]
             do (when (sdl2:game-controller-p i)
                  (format t "Found gamecontroller: ~a~%"
                          (sdl2:game-controller-name-for-index i))
                  (let* ((gc (sdl2:game-controller-open i))
                         (joy (sdl2:game-controller-get-joystick gc)))
                    (setf controllers (acons i gc controllers))
                    (when (sdl2:joystick-is-haptic-p joy)
                      (let ((h (sdl2:haptic-open-from-joystick joy)))
                        (setf haptic (acons i h haptic))
                        (sdl2:rumble-init h))))))

          ;; main loop
          [format t "Beginning main loop.~%"]
          [finish-output]
          (sdl2:with-event-loop [:method :poll]
            (:keydown [:keysym keysym]
             (let [(scancode (sdl2:scancode-value keysym))
                   (sym (sdl2:sym-value keysym))
                   (mod-value (sdl2:mod-value keysym))]
               (cond
                 ((sdl2:scancode= scancode :scancode-w) (format t "~a~%" "WALK"))
                 ((sdl2:scancode= scancode :scancode-s) (sdl2:show-cursor))
                 ((sdl2:scancode= scancode :scancode-h) (sdl2:hide-cursor)))
               [format t "Key sym: ~a, code: ~a, mod: ~a~%"
                       sym
                       scancode
                       mod-value]))

            (:keyup (:keysym keysym)
             (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
               [sdl2:push-event :quit]))

            (:mousemotion [:x x :y y :xrel xrel :yrel yrel :state state]
             [format t "Mouse motion abs(rel): ~a (~a), ~a (~a)~%Mouse state: ~a~%" x xrel y yrel state]
             [setf value [+ 0.01 value]])

            [:controlleraxismotion (:which controller-id :axis axis-id :value value)
             (format t "Controller axis motion: Controller: ~a, Axis: ~a, Value: ~a~%"
                     controller-id axis-id value)]

            (:controllerbuttondown (:which controller-id)
             (let ((h (cdr (assoc controller-id haptic))))
               (when h
                 (sdl2:rumble-play h 1.0 100))))

            [:idle ()
             [gl:clear :color-buffer]
             [gl:begin :triangles]
             [gl:color 1.0 0.0 0.0]
             [gl:vertex 0.0 1.0]
             [gl:vertex -1.0 -1.0]
             [gl:vertex value -1.0]
						 [when [> value 2.0]
								[setf value 0.0]]
             [gl:end]
             [gl:flush]
             [sdl2:gl-swap-window win]]

            [:quit () t])

          [format t "Closing opened game controllers.~%"]
          [finish-output]
          ;; close any game controllers that were opened
          ;; as well as any haptics
          (loop for (i . controller) in controllers
             do (progn
                  (sdl2:game-controller-close controller)
                  (sdl2:haptic-close (cdr (assoc i haptic))))))))))

[when [> 11 10]
	[princ "KEK"]]
[defparameter rf 0.03]
[defparameter rm 0.1]
[defparameter beta 0.8]
[print [+ rf [* beta [- rm rf]]]]
[exit]


[basic-test]
