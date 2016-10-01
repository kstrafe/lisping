[module main racket

[require racket/include
         opengl
         opengl/util
         ffi/vector
         math/matrix
         racket/gui]

[include "shader.rkt"]

[define [resize w h]
  [glViewport 0 0 w h]]

[define an 0.0]

(define (draw-opengl)
  (glClearColor 0.2 0.3 0.3 1.0)
  ;[glPolygonMode GL_FRONT_AND_BACK GL_LINE]
  (glClear [bitwise-ior GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT])

  [let [(mvp [glGetUniformLocation program "mvp"])]
  [set! an [+ an 0.01]]
  [printf "x-translate: ~a\n" an]
  [let [(translate
    [matrix [[1.0 0.0 0.0 [/ [sin an] 2]]
             [0.0 1.0 0.0 [/ [cos an] 2]]
             [0.0 0.0 1.0 [/ [sin an] 2]]
             [0.0 0.0 0.0 1.0]]])]
  [let [(fac [max [abs [sin an]] [abs [cos an]]])]
  [printf "scale: ~a\n" fac]
  [set! fac [/ fac 2]]
  [collect-garbage 'minor]
  [let [(scale
    [matrix [[fac 0.0 0.0 0.0]
             [0.0 fac 0.0 0.0]
             [0.0 0.0 fac 0.0]
             [0.0 0.0 0.0 1.0]]])]
  [let [(result [matrix* [matrix-transpose translate] [matrix-transpose scale]])]
  [let [(converted [list->f32vector [matrix->list result]])]
  [glUniformMatrix4fv mvp 1 #f converted]

  [glEnableVertexAttribArray 0]
  [glBindBuffer GL_ARRAY_BUFFER v-buffer]
  [glVertexAttribPointer 0 3 GL_FLOAT #f 12 0]
  [glDrawArrays GL_TRIANGLES 0 3]
  [glDisableVertexAttribArray 0]]]]]]])


(define my-canvas%
  (class* canvas% ()
    (inherit with-gl-context swap-gl-buffers)

   (define/override (on-paint)
      (with-gl-context
        (lambda ()
          (draw-opengl)
          (swap-gl-buffers)
          [on-paint])))

    (define/override (on-size width height)
      (with-gl-context
        (lambda ()
          (resize width height))))

    (super-instantiate () (style '(gl)))))


(define win (new frame% (label "OpenGL in Racket") (min-width 200) (min-height 200)))
(define gl (new my-canvas% (parent win)))

(send win show #t)

[define [setup-gl]
  [glEnable GL_DEPTH_TEST]
  [glClearDepth 1.0]
  [glDepthFunc GL_LEQUAL]
  [define v-array [glGenVertexArrays 1]]
  [glBindVertexArray [u32vector-ref v-array 0]]

  [define vertex-buffers [glGenBuffers 1]]
  [define vertex-buffer [u32vector-ref vertex-buffers 0]]
  [define vertex-buffer-data '[-1.0 -1.0 1.0
                                1.0 -1.0 1.0
                                0.0  1.0 1.0]]
  [define vertex-buffer-f32 [list->f32vector vertex-buffer-data]]
  [define-values [type pointer] [gl-vector->type/cpointer vertex-buffer-f32]]
  [glBindBuffer GL_ARRAY_BUFFER vertex-buffer]
  [glBufferData GL_ARRAY_BUFFER [* 4 [length vertex-buffer-data]] pointer GL_STATIC_DRAW]

  [define v-shader [make-shader "vertex.glsl" GL_VERTEX_SHADER]]
  [define f-shader [make-shader "fragment.glsl" GL_FRAGMENT_SHADER]]

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
  [values program vertex-buffer]]

[define-values [program v-buffer] [send gl with-gl-context setup-gl]]


]
