#! /usr/bin/env racket
#lang racket

[require rackunit]
[require sugar]

[define (nth list n)
  [if [= n 0]
    [car list]
    [nth [cdr list] [sub1 n]]]]

[struct Point (x y) #:prefab]
[define [find-between comparator elements]
  [match elements
    [(list left right _ ...)
      [if [comparator left right]
        [list left right]
        [find-between comparator [cdr elements]]]]
    [(list left right)
      [if [comparator left right]
        [list left right]
        empty]]
    [else empty]]]
[check-equal? '[6 8]
   [find-between [lambda (left right) [< left 7 right]] '[1 2 3 6 8 9 10]]
   "Find the numbers surrounding a test number in a sequence"]
[define (get-slope left right)
  [/ [- [Point-y right] [Point-y left]] [- [Point-x right] [Point-x left]]]]
[define (map-x-to-y left right x)
  [+ [Point-y left] [* [- x [Point-x left]] [get-slope left right]]]]
[define [find-between-points x-pos elements]
  [find-between [lambda (left right) [<= [Point-x left] x-pos [Point-x right]]]
    elements]]
[define (adjust-height x foothold-group)
  [let ([points [find-between-points x foothold-group]])
    [if [empty? points]
      empty
      [map-x-to-y [car points] [cadr points] x]]]]
[define (list-to-points list)
  [map [lambda (x) [Point [car x] [cadr x]]] list]]
[define (semi-circle-foothold start-x start-y)
  [for/list ([x-value [range start-x [+ start-x pi] 1/100]])
    [Point x-value [+ [sin [- x-value start-x]] start-y]]]]
[define (semi-circle-map positions)
  [for/list ([pos positions])
    [semi-circle-foothold [car pos] [cadr pos]]]]
[define (map-empty function iterable)
  [map [lambda (x) [if [empty? x] empty [function x]]] iterable]]
[define (find-y-foothold-collision x old-y new-y footholds)
  [let* ([heights [map [lambda (foothold-group) [adjust-height x foothold-group]] footholds]]
         [heights [map-empty [lambda (height) [if [< height old-y] height empty]] heights]]
         [heights [map-empty [lambda (height) [if [< new-y height] height empty]] heights]]
         [maxima  [values->list
           [for/fold ([max-height -inf.f]
                      [max-index empty])
                     ([element heights]
                      [index (in-naturals)])
             [if [empty? element]
               [values max-height max-index]
               [if [> element max-height]
                 [values element index]
                 [values max-height max-index]]]]]])
    [if [empty? [cadr maxima]]
      [list new-y empty]
      maxima]]]
[define (resolve-y x old-y new-y foothold-index footholds)
  [if [empty? foothold-index]
    [find-y-foothold-collision x old-y new-y footholds]
    [let* ([foothold-group [nth footholds foothold-index]]
           [new-state [list [adjust-height x foothold-group] foothold-index]])
      [if [empty? [car new-state]]
        [resolve-y x old-y new-y '[] footholds]
        new-state]]]]
[define (semi-circle start-x start-y)
  [for/list ([x-value [range start-x [+ start-x 2] 1/100]])
    [list x-value [/ [+ x-value [sin [* 12 x-value]] start-y] 4]]]]

[define m [semi-circle-map '[[0 0] [1 0] [2 0] [0 -2]]]]

; [define footholds '[[-1 0] [-0.5 -0.3] [0 0.2] [0.5 0.3] [1 0.1]]]
[define footholds [semi-circle -1 0]]
[define point-footholds [list [list-to-points footholds]]]
;; The machinery needed to compute a new y value
;; It takes the new x position, the old y value, and the new y value
;; If it falls off a foothold, the new-y will be assumed. Else, the y value
;; is interpolated from the foothold.
;[resolve-y 0.2 1 -10.3 '[] m]
;point-footholds
;point-footholds

[require ffi/vector finalizer math/matrix opengl opengl/util racket/generic racket/gui racket/serialize]
[require [for-syntax "logger.rkt" racket/list]]
[require "classes.rkt" "util.rkt" "logger.rkt" "window.rkt"]

[define mychar '[[0 0] [0.2 0] [0.2 0.2] [0 0.2]]]

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


[let-values ([(program window) [new-game-window]])
  [trce "Initializing main state"]
  [let init ([continue? #t]
             [character [send window with-gl-context [lambda () [create-vertex-buffer mychar GL_TRIANGLE_FAN]]]]
             [footing [send window with-gl-context [lambda () [create-vertex-buffer footholds GL_LINE_STRIP]]]]
             [monsters #f]
             [footholds empty])
    [trce "Initialized main state finished OK"]
    [let loop ([last-time [current-inexact-milliseconds]]
               [an 0.0]
               [x-pos 0]
               [y-pos 0.5]
               [y-speed 0.0]
               [current-fh empty])
      [logic]
      [let* ([x-pos [+ x-pos [if [send window key-down? #\a] -0.01 [if [send window key-down? #\d] 0.01 0.0]]]]
             [y-speed [if [send window key-down? #\w] 0.05 0.0]]
             [current-fh [if [send window key-down? #\w] empty current-fh]]
             [y-pos [+ y-pos y-speed]]
             [collision [resolve-y x-pos y-pos [- y-pos 0.01] current-fh point-footholds]]
             [y-pos [car collision]]
             [current-fh [cadr collision]])
        [draw]
        [when continue?
          [loop [current-inexact-milliseconds]
                an
                x-pos
                y-pos
                y-speed
                current-fh]]]]]]
