[module main racket

[define current 0]
[define [tic] [set! current [current-inexact-milliseconds]]]
[define [toc] [displayln [- [current-inexact-milliseconds] current]]]

[tic]
(require opengl opengl/util ffi/vector racket/gui)
[toc]

(define (resize w h)
  (glViewport 0 0 w h))

[define count 0]

[tic]
(define (draw-opengl)
	[displayln count]
	[set! count [add1 count]]
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
  (glEnd))
[toc]

[tic]
(define my-canvas%
  (class* canvas% ()
    (inherit with-gl-context swap-gl-buffers)

   (define/override (on-paint)
      (with-gl-context
        (lambda ()
          (draw-opengl)
          (swap-gl-buffers))))

    (define/override (on-size width height)
      (with-gl-context
        (lambda ()
          (resize width height))))

    (super-instantiate () (style '(gl)))))
[toc]

[tic]
(define win (new frame% (label "Racket Rosetta Code OpenGL example") (min-width 200) (min-height 200)))
[toc]
[tic]
(define gl  (new my-canvas% (parent win)))
[toc]

[define triangle '[-1.0 -1.0 0.0
                    1.0 -1.0 0.0
									  0.0  1.0 0.0]]
[define f32triangle [list->f32vector triangle]]
[define buf [glGenBuffers 1]]
[define bufn [first [u32vector->list buf]]]
[glBindBuffer GL_ARRAY_BUFFER bufn]
[define-values [ty ptr] [gl-vector->type/cpointer f32triangle]]
[glBufferData GL_ARRAY_BUFFER [length triangle] ptr GL_STATIC_DRAW]

[tic]
(send win show #t)
[toc]

]
