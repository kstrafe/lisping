[module main racket

(require opengl opengl/util ffi/vector racket/gui)

[define [square x y scale]
	[glBegin GL_TRIANGLES]
	[glColor3f 1.0 1.0 1.0]
	[glVertex3d x y 0.0]
	[glVertex3d [+ x scale] y 0.0]
	[glVertex3d x [+ y scale] 0.0]
	[glVertex3d x [+ y scale] 0.0]
	[glVertex3d [+ x scale] [+ y scale] 0.0]
	[glVertex3d [+ x scale] y 0.0]
	[glEnd]]

(define (resize w h)
  (glViewport 0 0 w h))

(define (draw-opengl)
  (glClearColor 0.0 0.0 0.0 0.0)
  (glClear GL_COLOR_BUFFER_BIT)

  (glShadeModel GL_SMOOTH)

  (glMatrixMode GL_PROJECTION)
  (glLoadIdentity)
  (glOrtho 0.0 1.0 0.0 1.0 -1.0 1.0)
  (glMatrixMode GL_MODELVIEW)
  (glLoadIdentity)

  (glBegin GL_TRIANGLES)
  (glColor3f 1.0 0.0 0.0)
  (glVertex3d 0.25 0.25 0.0)
  (glColor3f 0.0 1.0 0.0)
  (glVertex3d 0.75 0.25 0.0)
  (glColor3f 0.0 0.0 1.0)
  (glVertex3d 0.75 0.75 0.0)
	[displayln "We were retarded"]
  (glEnd)

  [square 0.45 0.45 0.1])


(define my-canvas%
  (class* canvas% ()
    (inherit with-gl-context swap-gl-buffers)

   (define/override (on-paint)
      (with-gl-context
        (lambda ()
					[define shader [glCreateShader GL_VERTEX_SHADER]]
					[define shader2 [glCreateShader GL_FRAGMENT_SHADER]]
					[displayln shader]
					[displayln shader2]
          (draw-opengl)
          (swap-gl-buffers))))

    (define/override (on-size width height)
      (with-gl-context
        (lambda ()
          (resize width height))))

    (super-instantiate () (style '(gl)))))



(define win (new frame% (label "Racket Rosetta Code OpenGL example") (min-width 200) (min-height 200)))

(define gl (new my-canvas% (parent win)))


(send win show #t)


]
