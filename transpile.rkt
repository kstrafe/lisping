#! /usr/bin/env racket
#lang racket

; [define an 0.0]
; [define [resize w h]
;   [glViewport 0 0 w h] #t]
; [define [draw-opengl]
;   [glClearColor 0.2 0.3 0.3 1.0]
;   [glPolygonMode GL_FRONT_AND_BACK GL_LINE]
;   [glClear [bitwise-ior GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT]]
;   [let [(mvp [glGetUniformLocation program "mvp"])]
;     [dbug mvp]
;     [set! an [+ an 0.01]]
;     [trce "x-translate" an]
;     [let [(translate
;       [matrix [[1.0 0.0 0.0 [/ [sin an] 2]]
;                [0.0 1.0 0.0 [/ [cos an] 2]]
;                [0.0 0.0 1.0 [/ [sin an] 2]]
;                [0.0 0.0 0.0 1.0]]])]
;       [let [(fac [max [abs [sin an]] [abs [cos an]]])]
;         [trce "scale" fac]
;         [set! fac [/ fac 2]]
;         [collect-garbage 'incremental]
;         [let [(scale
;           [matrix [[fac 0.0 0.0 0.0]
;                    [0.0 fac 0.0 0.0]
;                    [0.0 0.0 fac 0.0]
;                    [0.0 0.0 0.0 1.0]]])]
;           [let [(result [matrix* [matrix-transpose translate] [matrix-transpose scale]])]
;             [let [(converted [list->f32vector [matrix->list result]])]
;               [glUniformMatrix4fv mvp 1 #f converted]
;               [glEnableVertexAttribArray 0]
;               [glBindBuffer GL_ARRAY_BUFFER [VertexBuffer-id shape]]
;               [let ([index 0]
;                     [size 3]
;                     [type GL_FLOAT]
;                     [normalized #f]
;                     [stride 0 #;[had it at 12]]
;                     [offset 0])
;                 [glVertexAttribPointer index size #;[size = number of components per vertex] type normalized stride offset]
;                 [glDrawArrays GL_TRIANGLES 0 [VertexBuffer-vertex-count shape]]
;                 [glBindBuffer GL_ARRAY_BUFFER [VertexBuffer-id footing-vbo]]
;                 [glVertexAttribPointer index size #;[size = number of components per vertex] type normalized stride offset]
;                 [glDrawArrays GL_LINE_STRIP 0 [VertexBuffer-vertex-count footing-vbo]]
;                 [glDisableVertexAttribArray 0]]]]]]]]]
; [define my-canvas% [class* canvas% []
;   [inherit
;     refresh
;     with-gl-context
;     swap-gl-buffers]
;   [define stop-drawing #f]
;   [define/override [on-paint]
;     [with-gl-context
;       [lambda []
;         [parameterize ([trce-enabled #t])
;           [draw-opengl]]
;         [swap-gl-buffers]]]
;     [sleep/yield 0.01]
;     [when [not stop-drawing]
;       [on-paint]]]
;   [define/override [on-size width height]
;     [with-gl-context
;       [lambda []
;         [resize width height]]]]
;   [define/override [on-event event]
;     [on-paint]
;     [info event]]
;   [define/override [on-superwindow-show state]
;     [trce 'on-close state]
;     [set! stop-drawing [not state]]]
;   [define/override [on-char event]
;     [when [eq? 'escape [send event get-key-code]]
;       [set! stop-drawing #t]]
;     [warn event]]
;   [super-instantiate [] [style '[gl]]]]]
; [define win [new frame% [label "Collision Testing"] [min-width 800] [min-height 800]]]
; [define gl [new my-canvas% [parent win]]]
; [define [setup-gl]
;   [glEnable GL_DEPTH_TEST]
;   [glClearDepth 1.0]
;   [glDepthFunc GL_LEQUAL]
;   [info "we're here"]
;   [define vertex-buffer [create-vertex-buffer '[
;      -1.0 -1.0 1.0
;       1.0 -1.0 1.0
;       0.0  1.0 1.0
;
;       0.0  0.0 1.0
;       2.0  0.0 1.0
;       1.0  2.0 1.0
;
;      -1.0 -2.0 1.0
;       1.0 -2.0 1.0
;       0.0  0.0 1.0]]]
;   [info "here now"]
;   [define v-shader [make-shader "vertex.glsl" GL_VERTEX_SHADER]]
;   [define f-shader [make-shader "fragment.glsl" GL_FRAGMENT_SHADER]]
;   [define program [glCreateProgram]]
;   [glAttachShader program v-shader]
;   [glAttachShader program f-shader]
;   [glLinkProgram program]
;   [define link-status [glGetProgramiv program GL_LINK_STATUS]]
;   [define p-log-length [glGetProgramiv program GL_INFO_LOG_LENGTH]]
;   [when [> p-log-length 0]
;     [define-values [count bytes] [glGetShaderInfoLog program p-log-length]]
;     [crit "Shader failed to compile" bytes]]
;   [glDetachShader program v-shader]
;   [glDetachShader program f-shader]
;   [glDeleteShader v-shader]
;   [glDeleteShader f-shader]
;   [glUseProgram program]
;   [values program vertex-buffer]]
; [define-values [program shape] [send gl with-gl-context setup-gl]]
; [define foothold-values '[[-1.5 0.5] [-0.7 0] [0 1] [3 -3]]]
; [define [footing] [create-vertex-buffer
;   [map real->single-flonum [flatten [add-zeros foothold-values]]]]]
; [define footing-vbo [send gl with-gl-context footing]]
;
; [define [find-between comparator elements]
;   [match elements
;     [(list left right _ ...)
;       [if [comparator left right]
;         [values left right]
;         [find-between comparator [cdr elements]]]]
;     [(list left right)
;       [if [comparator left right]
;         [values left right]
;         [values empty empty]]]
;     [else [values empty empty]]]]
; [define (get-slope left right)
;   [/ [- [Point-y right] [Point-y left]] [- [Point-x right] [Point-x left]]]]
; [define (map-x-to-y left right x)
;   [+ [Point-y left] [* [- x [Point-x left]] [get-slope left right]]]]
; [define [find-between-points x-pos elements]
;   [find-between [lambda (left right) [<= [Point-x left] x-pos [Point-x right]]]
;     elements]]
; [define (walk-character new-x footholds)
;   [let-values ([(left right) [find-between-points new-x footholds]])
;     [if [empty? left]
;       [values empty empty]
;       [values new-x [map-x-to-y left right new-x]]]]]
;
; [send win center]
; [send win show #t]
; [send win focus]

[require racket/generic racket/serialize racket/gui ffi/vector math/matrix opengl opengl/util finalizer]
[require [for-syntax racket/list]]
[require "classes.rkt" "util.rkt" "logger.rkt" "window.rkt"]
[directory-list]

[let ([window [new-game-window]])
  [let init ([character #f]
             [monsters #f]
             [footholds empty])
    [let loop ([last-time [current-inexact-milliseconds]])
      [logic]
      [draw]
      [loop [current-inexact-milliseconds]]]]]
