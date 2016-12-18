#! /usr/bin/env racket
#lang racket

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

[require ffi/vector finalizer math/matrix opengl opengl/util racket/generic racket/gui racket/serialize]
[require [for-syntax "logger.rkt" racket/list]]
[require "classes.rkt" "util.rkt" "logger.rkt" "window.rkt"]

[define mychar '[[0 0] [0.2 0] [0.2 0.2] [0 0.2]]]
[define footholds '[[-1 0] [-0.5 -0.3] [0 0.2] [0.5 0.3] [1 0.1]]]

[define-for-syntax [replace-first]
  [let ([found #f])
    [define [replacer exp old new]
      [cond
        [[null? exp] '[]]
        [[not [pair? exp]]
          [cond
            [[and [eq? exp old] [not found]]
              [set! found #t] new]
            [else exp]]]
        [else
          [cons [replacer [car exp] old new]
          [replacer [cdr exp] old new]]]]]
    replacer]]

[define-syntax (loop syn)
  [let* ([elements [cdr [syntax->datum syn]]]
         [names [for/list ([i [car elements]]) [car i]]]
         [expression [cdr elements]]
         [to-ret [[replace-first] expression 'game-loop [cons 'game-loop names]]]
         [to-ret `[let game-loop ,[car elements] ,[cons 'begin to-ret]]])
           [trce to-ret]
           [datum->syntax syn to-ret]]]

[define (clamp number range)
  [if [> number range]
    0
    number]]

[require racket/serialize]
[struct state (continue? character footing monsters footholds) #:prefab]
[serialize (state 1 2 3 4 5)]

[require "logger.rkt"]
[struct result (value error) #:prefab]
[match [result 1000 #f]
  [(result a #f) (trce "YAY" a)]
  [(result _ #t) (trce "No :(")]]

[let loop (game-state)
  [do
    [<- game-state [check-collision game-state]]
    [loop game-state]]]

[let-values ([(program window) [new-game-window]])
  [trce "Initializing main state"]
  [let init ([continue? #t]
             [character [send window with-gl-context [lambda () [create-vertex-buffer mychar GL_TRIANGLE_FAN]]]]
             [footing [send window with-gl-context [lambda () [create-vertex-buffer footholds GL_LINE_STRIP]]]]
             [monsters #f]
             [footholds empty])
    [trce "Initialized main state finished OK"]
    [let loop ([last-time [current-inexact-milliseconds]]
               [an 0.0])
      [logic]
      [draw]
      [when continue?
        [loop [current-inexact-milliseconds]
              [clamp [+ an 0.01] 2]]]]]]
[exit]
