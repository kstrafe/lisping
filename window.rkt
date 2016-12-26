#lang racket

[provide with-mvp-translate new-game-window logic draw render]

[require racket/serialize racket/gui ffi/vector math/matrix opengl opengl/util finalizer "classes.rkt" "logger.rkt" "util.rkt"]


[define (new-game-window)
  [trce "Creating OpenGL context"]
  [let* ([window [new frame% [label "The Game"] [min-width 800] [min-height 800]]]
         [canvas [new game-canvas% [parent window]]])
    [let ([programs [send canvas with-gl-context setup-gl]])
      [send canvas focus]
      [send window center]
      [send window show #t]
      [values programs canvas]]]]

[define [setup-gl]
  [glEnable GL_DEPTH_TEST]
  [glClearDepth 1.0]
  [glDepthFunc GL_LEQUAL]
  [glViewport 0 0 800 800]
  [define v-shader [make-shader "programs/vertex.glsl" GL_VERTEX_SHADER]]
  [define f-shader [make-shader "programs/fragment.glsl" GL_FRAGMENT_SHADER]]
  [define program [glCreateProgram]]
  [glAttachShader program v-shader]
  [glAttachShader program f-shader]
  [glLinkProgram program]
  [define link-status [glGetProgramiv program GL_LINK_STATUS]]
  [define p-log-length [glGetProgramiv program GL_INFO_LOG_LENGTH]]
  [when [> p-log-length 0]
    [define-values [count bytes] [glGetShaderInfoLog program p-log-length]]
    [crit "Shader failed to compile" bytes]]
  [glDetachShader program v-shader]
  [glDetachShader program f-shader]
  [glDeleteShader v-shader]
  [glDeleteShader f-shader]
  [glUseProgram program]
  program]

[define game-canvas% [class* canvas% []
  [define the-keyboard [make-hasheq]]
  [define [key-down! k] [hash-set! the-keyboard k #t]]
  [define [key-up! k]   [hash-set! the-keyboard k #f]]
  [define/public [key-down? k] [hash-ref the-keyboard k #f]]
  [define/override [on-char event]
    [let ([key     [send event get-key-code]]
          [release [send event get-key-release-code]])
      [when [eq? release 'press]
        [trce 'trigger-press key release]
        [key-down! key]]
      [when [eq? key 'release]
        [trce 'trigger-release key release]
        [key-up! release]]]]
  [inherit
   with-gl-context
   swap-gl-buffers]
  [define/override [on-event event] [void]]
  [super-instantiate [] [style '[gl no-autoclear]]]]]

[define-syntax (draw scope)
  [datum->syntax scope '[send window with-gl-context [lambda () [
    render]
    [collect-garbage 'incremental]
    [limit-iterations-per-second]
    [send window swap-gl-buffers]]]]]

[define (with-mvp-translate x y name program)
  [let* [(mvp [glGetUniformLocation program "mvp"])
         (x [real->single-flonum x])
         (y [real->single-flonum y])
         (translate
           [matrix
             [[1.0 0.0 0.0 0.0]
              [0.0 1.0 0.0 0.0]
              [0.0 0.0 1.0 0.0]
              [x y 0.0 1.0]]])
         (converted [list->f32vector [matrix->list translate]])]
    [glUniformMatrix4fv mvp 1 #f converted]
    [glBindVertexArray [VertexBuffer-vertex-array name]]
    [glDrawElements [VertexBuffer-draw-type name] [VertexBuffer-index-count name] GL_UNSIGNED_INT 0]]]

[define-syntax (render scope) [datum->syntax scope '[begin
  [glClearColor 0.2 0.3 0.3 1.0]
  [glPolygonMode GL_FRONT GL_FILL #;[GL_LINE]]
  [glClear [bitwise-ior GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT]]
  [with-mvp-translate 0 0 footing program]
  [with-mvp-translate x-pos y-pos character program]]]]

[define-syntax (logic scope)
  [datum->syntax scope
    '[when [send window key-down? 'escape]
      [info 'its-down]
      [set! continue? #f]]]]

; [require racket/serialize "logger.rkt"]
; [struct rng (seed) #:prefab]
; [struct entire-state (random-generator) #:prefab]
; [define (rng-rand current)
;   [let* ([value [rng-seed current]]
;          [new-value [bitwise-and [+ [* value 1103515245] 12345] #x7fffffff]])
;     [values new-value [rng new-value]]]]
; [let loop ([r [rng 12938]])
;   [let-values ([(value r) [rng-rand r]])
;     [trce [serializable? r]]
;     [trce value]
;     [sleep 0.3]
;     [loop r]]]

; "git rev-parse HEAD"
[require [for-syntax "logger.rkt"]]
[define-syntax (fetch-git-hash scope)
  [let ([hash
    [let-values ([(process out in err) [subprocess #f #f #f "/usr/bin/env" "git" "rev-parse" "HEAD"]])
      [subprocess-wait process]
      [if [= [subprocess-status process] 0]
        [let ([hash [symbol->string [read out]]])
          [if [regexp-match #px"^[0-9a-f]{40}$" hash]
            hash
            [raise "Does not match regex"]]]
        [raise "Unable to get the git hash: got non-zero status code"]]]])
    [datum->syntax scope hash]]]
