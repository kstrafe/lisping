[module main racket

(require opengl opengl/util ffi/vector racket/gui)

[define [square x y scale]
	[glBegin GL_TRIANGLES]
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
  ;(glClearColor 0.0 0.0 0.0 0.0)
  (glClear [bitwise-ior GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT])

  ;(glShadeModel GL_SMOOTH)

  ;(glMatrixMode GL_PROJECTION)
  ;(glLoadIdentity)
  ;(glOrtho 0.0 1.0 0.0 1.0 -1.0 1.0)
  ;(glMatrixMode GL_MODELVIEW)
  ;(glLoadIdentity)

	[glEnableVertexAttribArray 0]
	[glBindBuffer GL_ARRAY_BUFFER v-buffer]
	[glVertexAttribPointer 0 3 GL_FLOAT #f 0 0]
	[glDrawArrays GL_TRIANGLES 0 3]
	[glDisableVertexAttribArray 0]

	[square -0.05 -0.05 0.1]

	[square 1.0 0.0 0.1] ;; Outside
	[square 1.0 1.0 0.1] ;; Outside

	[square -1.0 -1.0 0.1]
	[square 0.9 -1.0 0.1]
	)


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



(define win (new frame% (label "My Game") (min-width 200) (min-height 200)))
(define gl (new my-canvas% (parent win)))

(send win show #t)

[define [create-shader]

	[define v-array [glGenVertexArrays 1]]
	[glBindVertexArray [u32vector-ref v-array 0]]

	[define vertex-buffers [glGenBuffers 1]]
	[define vertex-buffer [u32vector-ref vertex-buffers 0]]
	#|
	[define vertex-buffer-data '[-1.0 -1.0 0.0
	                              1.0 -1.0 0.0
	                              0.0  1.0 0.0]]
	|#
	[define vertex-buffer-data '[ 0.4  0.4 0.0
	                              0.5  0.5 0.0
	                              0.4  0.5 0.0]]
	[define vertex-buffer-f32 [list->f32vector vertex-buffer-data]]
	[define-values [type pointer] [gl-vector->type/cpointer vertex-buffer-f32]]
	[glBindBuffer GL_ARRAY_BUFFER vertex-buffer]
	[glBufferData GL_ARRAY_BUFFER [* 4 [length vertex-buffer-data]] pointer GL_STATIC_DRAW]

	[define v-shader [glCreateShader GL_VERTEX_SHADER]]
	[define v-code [file->string "vertex.glsl"]]
	[glShaderSource v-shader 1 [vector v-code] [s32vector [string-length v-code]]]
	[glCompileShader v-shader]
	[define v-compile-status [glGetShaderiv v-shader GL_COMPILE_STATUS]]
	[define v-log-length [glGetShaderiv v-shader GL_INFO_LOG_LENGTH]]
	[when [> v-log-length 0]
		[define-values [count bytes] [glGetShaderInfoLog v-shader v-log-length]]
		[printf "Returned: ~a\n" bytes]]

	[define f-shader [glCreateShader GL_FRAGMENT_SHADER]]
	[define f-code [file->string "fragment.glsl"]]
	[glShaderSource f-shader 1 [vector f-code] [s32vector [string-length f-code]]]
	[glCompileShader f-shader]
	[define f-compile-status [glGetShaderiv f-shader GL_COMPILE_STATUS]]
	[define f-log-length [glGetShaderiv f-shader GL_INFO_LOG_LENGTH]]
	[when [> f-log-length 0]
		[define-values [count bytes] [glGetShaderInfoLog f-shader f-log-length]]
		[printf "Returned: ~a\n" bytes]]

	[define program [glCreateProgram]]
	[glAttachShader program v-shader]
	[glAttachShader program f-shader]
	[glLinkProgram program]
	[define link-status [glGetProgramiv program GL_LINK_STATUS]]
	[define p-log-length [glGetProgramiv program GL_INFO_LOG_LENGTH]]
	[when [> p-log-length 0]
		[define-values [count bytes] [glGetShaderInfoLog program p-log-length]]
		[printf "Returned: ~a\n" bytes]]

	[glDetachShader program v-shader]
	[glDetachShader program f-shader]

	[glDeleteShader v-shader]
	[glDeleteShader f-shader]

	[glUseProgram program]
	vertex-buffer]

[define v-buffer [send gl with-gl-context create-shader]]


]
