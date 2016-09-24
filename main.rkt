[module main racket

(require opengl opengl/util ffi/vector racket/gui)

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

  #|
  (glBegin GL_TRIANGLES)
  (glColor3f 1.0 0.0 0.0)
  (glVertex3d 0.25 0.25 0.0)
  (glColor3f 0.0 1.0 0.0)
  (glVertex3d 0.75 0.25 0.0)
  (glColor3f 0.0 0.0 1.0)
  (glVertex3d 0.75 0.75 0.0)
  (glEnd)
  |#
  [glEnableVertexAttribArray 0]
  [glBindBuffer GL_ARRAY_BUFFER bufn]
  [glVertexAttribPointer 0 3 GL_FLOAT #f 0 0]
  ;[glDrawArrays GL_TRIANGLES 0 3]
  [glDisableVertexAttribArray 0])


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



(define win (new frame% (label "Racket Rosetta Code OpenGL example") (min-width 200) (min-height 200)))

(define gl  (new my-canvas% (parent win)))

[define triangle '[-1.0 -1.0 0.0
                    1.0 -1.0 0.0
                    0.0  1.0 0.0]]

[define f32triangle [list->f32vector triangle]]
[define buf [glGenBuffers 1]]
[define bufn [first [u32vector->list buf]]]
[glBindBuffer GL_ARRAY_BUFFER bufn]
[define-values [ty ptr] [gl-vector->type/cpointer f32triangle]]
[glBufferData GL_ARRAY_BUFFER [length triangle] ptr GL_STATIC_DRAW]

[glCreateProgram]
[define vshad [glCreateShader GL_VERTEX_SHADER]]
[define vshad2 [glCreateShader GL_VERTEX_SHADER]]
[define fshad [glCreateShader GL_FRAGMENT_SHADER]]

[printf "vshad: ~a\n" vshad]
[printf "vshad2: ~a\n" vshad2]
[printf "fshad ~a\n" fshad]

[define vshad-t [file->string "vertex.glsl"]]
[define fshad-t [file->string "fragment.glsl"]]

[glShaderSource  vshad 1 [vector vshad-t] [s32vector [string-length vshad-t]]]
[glCompileShader vshad]

[define compstat [glGetShaderiv vshad GL_COMPILE_STATUS]]
[printf "compstat: ~a\n" compstat]

[when [not [= compstat 0]]
  [define logl [glGetShaderiv vshad GL_INFO_LOG_LENGTH]]
  [printf "logl: ~a\n" logl]
  [when [and [> logl 0] #t]
    [displayln "KEKOS"]
    [define-values [nums bts] [glGetShaderInfoLog vshad logl]]
    [displayln bts]
    [displayln "EKKEK"]]]

(send win show #t)


]
