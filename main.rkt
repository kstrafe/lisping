#! /usr/bin/env racket
#lang racket

[require racket/serialize racket/gui ffi/vector math/matrix opengl opengl/util finalizer]
[require [for-syntax racket/list]]
[require "util.rkt"]

[serializable-struct Point (x y) #:transparent #:guard
  [lambda (x y name)
    [values
      [real->single-flonum x]
      [real->single-flonum y]]]]

[define foothold%
  [class object% [init start stop]
    [define point-1 start]
    [define point-2 stop]
    [define-values (left right) [values empty empty]]
    [unless [< [Point-x point-1] [Point-x point-2]]
      [set! point-1 stop]
      [set! point-2 start]]
    [super-new]
    [define/public (map-x-to-y x)
      [let ([x [real->single-flonum x]])
        [if [and [>= x [Point-x point-1]] [<= x [Point-x point-2]]]
          [+ [Point-y point-1]
             [* [- x [Point-x point-1]] [get-slope]]]
          [if [> x [Point-x point-2]]
            'right
            'left]]]]
    [define/public (left-most-x)
      [Point-x point-1]]
    [define/public (right-most-x)
      [Point-x point-2]]
    [define/public (get-slope)
      [let ([dx [- [Point-x point-2] [Point-x point-1]]]
            [dy [- [Point-y point-2] [Point-y point-1]]])
        [/ dy dx]]]]]

[define footholds%
  [class object%
    [define footholds #[]]
    [define lefts [make-hash]]
    [define rights [make-hash]]
    [super-new]
    [define/public (add-foothold fh)
      [set! footholds [vector-append footholds [vector fh]]]
      [sub1 [vector-length footholds]]]
    [define/public (connect-footholds left-index right-index)
      [hash-set! lefts right-index left-index]
      [hash-set! rights left-index right-index]]
    [define/public (get-footholds)
      [info 'lefts: lefts 'rights: rights]
      footholds]
    [define/public (get-foothold index)
      [if [and [>= index 0] [< index [vector-length footholds]]]
        [vector-ref footholds index]
        empty]]
    [define/public (find-foothold-below point)
      [let ([my-x [Point-x point]]
            [my-y [Point-y point]]
            [highest -inf.f]
            [current empty]
            [index -1]
            [current-index empty])
        [for ([fh footholds])
          [set! index [add1 index]]
          [when [and [>= my-x [send fh left-most-x]]
                     [<= my-x [send fh right-most-x]]]
            [let ([fh-y [send fh map-x-to-y my-x]])
              [when [and [>= my-y fh-y]
                         [> fh-y highest]]
                [set! current fh]
                [set! current-index index]
                [set! highest fh-y]]]]]
        [values current current-index]]]]]

;;; Allows you to add floors to the 'footholds%' object
;;; Use `[create-floor footholder-name [1 2] [3 4] ...]`
;;; Where the numbers represent points
[define-syntax (create-floor points)
  [define vertices [cdr [syntax->datum points]]]
  [define footholder-name [car vertices]]
  [set! vertices [cdr vertices]]
  [define count [sub1 [length vertices]]]
  [define working-list empty]
  [define current-x -inf.f]
  [let loop ([working-vertices vertices])
    [when [>= [length working-vertices] 2]
      [let* ([start [cons 'Point [car working-vertices]]]
            [stop [cons 'Point [cadr working-vertices]]]
            [newed `[new foothold% [start ,start] [stop ,stop]]])
        [if [> current-x [caar working-vertices]]
          [raise-syntax-error 'Sorted-test-x "List of points must be sorted from left-to-right with respect to x"]
          [set! current-x [caar working-vertices]]]
        [if [empty? working-list]
          [set! working-list [list newed]]
          [set! working-list [cons newed working-list]]]
        [loop [cdr working-vertices]]]]]
  [define final [cons 'begin0 [for/list ([foothold [reverse working-list]])
    [append `[send ,footholder-name add-foothold] [list foothold]]]]]
  [set! final
    `[let ([start-index ,final])
      [for ([i [in-range start-index [sub1 [+ start-index ,count]]]])
        [warn 'current-index i]
        [send ,footholder-name connect-footholds i [add1 i]]]]]
  [datum->syntax #'safe final #'srcloc]]

[define player% [class object%
  [init]
  [define position [Point 0 1]]
  [define current-foothold-index 0]
  [define current-foothold empty]
  [super-new]
  [define/public (correct-y footholds)
    [if [empty? current-foothold]
      [set!-values (current-foothold current-foothold-index) [send footholds find-foothold-below position]]
      [let ([potential-y [send current-foothold map-x-to-y [Point-x position]]])
        [cond
          [(number? potential-y) [set! position [Point [Point-x position] [Point-y position]]]]
          [(eq? 'left potential-y)
            [set!-values (current-foothold current-foothold-index) [values [send footholds get-foothold [sub1 current-foothold-index]] [sub1 current-foothold-index]]]]
          [(eq? 'right potential-y)
            [warn 'going-right 'new-index [add1 current-foothold-index]]
            [set!-values (current-foothold current-foothold-index) [values [send footholds get-foothold [add1 current-foothold-index]] [add1 current-foothold-index]]]]
          [else '[]]]]]]
  [define/public (status)
    [info 'position position 'fhi current-foothold-index]]
  [define/public (move-in-x step)
    [set! position [Point [+ [Point-x position] step] [Point-y position]]]]]]

[define character [new player%]]

[define fhs [new footholds%]]
[create-floor fhs [-1 0] [1 0] [2 0] [4 1]]
[create-floor fhs [-5 -1] [6 -1]]
[send fhs get-footholds]

;; Ideally we want to write stuff like
[with-input-from-file "shape.rkt"
  [lambda ()
    [read]]]

; [require racket/gui]
; [require [lib "gl.ss" "sgl"] [lib "gl-vectors.ss" "sgl"]]

[require racket/serialize racket/gui ffi/vector math/matrix opengl opengl/util]
[require [for-syntax racket/list]]
[require "logger.rkt"]
[define an 0.0]
[define [resize w h]
  [glViewport 0 0 w h] #t]
[define [draw-opengl]
  [glClearColor 0.2 0.3 0.3 1.0]
  [glPolygonMode GL_FRONT_AND_BACK GL_LINE]
  [glClear [bitwise-ior GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT]]
  [let [(mvp [glGetUniformLocation program "mvp"])]
    [set! an [+ an 0.01]]
    [trce "x-translate" an]
    [let [(translate
      [matrix [[1.0 0.0 0.0 [/ [sin an] 2]]
               [0.0 1.0 0.0 [/ [cos an] 2]]
               [0.0 0.0 1.0 [/ [sin an] 2]]
               [0.0 0.0 0.0 1.0]]])]
      [let [(fac [max [abs [sin an]] [abs [cos an]]])]
        [trce "scale" fac]
        [set! fac [/ fac 2]]
        [collect-garbage 'incremental]
        [let [(scale
          [matrix [[fac 0.0 0.0 0.0]
                   [0.0 fac 0.0 0.0]
                   [0.0 0.0 fac 0.0]
                   [0.0 0.0 0.0 1.0]]])]
          [let [(result [matrix* [matrix-transpose translate] [matrix-transpose scale]])]
            [let [(converted [list->f32vector [matrix->list result]])]
              [glUniformMatrix4fv mvp 1 #f converted]
              [glEnableVertexAttribArray 0]
              [glBindBuffer GL_ARRAY_BUFFER [VertexBuffer-id shape]]
              [let ([index 0]
                    [size 3]
                    [type GL_FLOAT]
                    [normalized #f]
                    [stride 0 #;[had it at 12]]
                    [offset 0])
                [glVertexAttribPointer index size #;[size = number of components per vertex] type normalized stride offset]
                [glDrawArrays GL_TRIANGLES 0 [VertexBuffer-vertex-count shape]]
                [glDisableVertexAttribArray 0]]]]]]]]]
[define my-canvas% [class* canvas% []
  [inherit
    refresh
    with-gl-context
    swap-gl-buffers]
  [define stop-drawing #f]
  [define/override [on-paint]
    [with-gl-context
      [lambda []
        [parameterize ([trce-enabled #f])
          [draw-opengl]]
        [swap-gl-buffers]]]
    [sleep/yield 0.01]
    [when [not stop-drawing]
      [on-paint]]]
  [define/override [on-size width height]
    [with-gl-context
      [lambda []
        [resize width height]]]]
  [define/override [on-event event]
    [begin-busy-cursor]
    [on-paint]
    [info event]]
  [define/override [on-superwindow-show state]
    [trce 'on-close state]
    [set! stop-drawing [not state]]]
  [define/override [on-char event]
    [warn event]]
  [super-instantiate [] [style '[gl]]]]]
[define win [new frame% [label "Collision Testing"] [min-width 400] [min-height 400]]]
[define gl [new my-canvas% [parent win]]]
[define [setup-gl]
  [glEnable GL_DEPTH_TEST]
  [glClearDepth 1.0]
  [glDepthFunc GL_LEQUAL]
  [info "we're here"]
  [define vertex-buffer [create-vertex-buffer '[
     -1.0 -1.0 1.0
      1.0 -1.0 1.0
      0.0  1.0 1.0

      0.0  0.0 1.0
      2.0  0.0 1.0
      1.0  2.0 1.0

     -1.0 -2.0 1.0
      1.0 -2.0 1.0
      0.0  0.0 1.0]]]
  [info "here now"]
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
    [crit "Shader failed to compile" bytes]]
  [glDetachShader program v-shader]
  [glDetachShader program f-shader]
  [glDeleteShader v-shader]
  [glDeleteShader f-shader]
  [glUseProgram program]
  [values program vertex-buffer]]
[define-values [program shape] [send gl with-gl-context setup-gl]]

[send win show #t]
