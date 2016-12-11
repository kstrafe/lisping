#! /usr/bin/env racket
#lang racket

[require kekkus]
[print *something*]
[exit]
[require racket/date]
[include "extra.rkt"]

[let loop ([i 0])
  [if (> i 10)
    [trce 'comp-done [void]]
    [begin
      [parameterize ([*warn* #f] [*trce* [= [modulo i 2] 0]])
        [warn 'level i]
        [trce "dof level" i]]
      [warn "Using sleep here" 123]
      [sleep 0.1]
      [trce 'woke]
      [loop [add1 i]]]]]

[define cont #f]
[begin
  [let ([iter [call/cc [lambda (x) [set! cont x] 0]]])
    [when (= (modulo iter 1000000) 0) [info iter]]
    [when (< iter 10000000) [cont [add1 iter]]]]]

; [require [planet neil/charterm:3:0]]
; [define w
; '[
; "            **  "
; "        ****    "
; "     *****      "
; "   **   **      "
; " **      **     "
; "*          *****"]]

; [let loop ([n 1])
;   [with-charterm
;    [void [charterm-clear-screen]]]
;   [for ([i w])
;     [let ([x [string-join [make-list 5 i] ""]])
;       [displayln [string-append [substring x [- 16 n]]
;                                 [substring x 0 [- 16 n]]]]]]
;   [sleep .1]
;   [loop [modulo [+ n 1] 16]]]


; [define my-continuation #f]
; [define (some-function)
;   [let ([v [+ [call/cc [lambda (k) [set! my-continuation k] 0]] 10]])
;     [display "And here we run the rest of our code: The returned number: "]
;     [displayln v]
;     [let loop ([n 0])
;       [if [> n v]
;         [displayln "And it was counted until v"]
;         [begin [displayln "not there yet"]
;                [loop [add1 n]]]]]]]
; [some-function]
; [my-continuation 5]
; [exit]

; [require racket/gui]
; [require [planet dyoo/while-loop:1:1]]
; [require "racket-inotify/inotify.rkt"]
; [require math/matrix]
; [define (eye size [ones 1] [zeros 0])
;   [identity-matrix size ones zeros]]
; [define (ones m n x) [make-matrix m n x]]
; [define A [eye 10]]
; [define x [ones 10 1 3]]
; [matrix* A x]
; [print [matrix-hermitian A]]
; ; [let looper ([x 10/9])
; ;   [when [>= x -6/9]
; ;     [displayln x]
; ;     [looper [- x 1/100]]]]

; [define-syntax ($ syn)
;   [define something [datum->syntax #'lex [cons 'lambda [cdr [syntax->datum syn]]] #'srcloc]]
;   [print something]
;   something]
; [[$ (x) x] 30402]
; [exit]

; [define (stx-cdr stx) [datum->syntax [cdr [syntax->datum stx]]]]

; ; Simplest form
; [define-syntax-rule [name1 pattern]
;   [displayln pattern]]
; [displayln ""]
; [name1 "example define-syntax-rule"]

; ; More complex patterns
; [define-syntax name2
;   [syntax-rules (literal)
;     [(name2 literal pattern) [displayln pattern]]]]
; [displayln ""]
; [name2 literal "example of define-syntax with syntax-rules"]

; ; Identifier macros (not important yet)
; [define-syntax name3
;   [lambda (stx)
;     [syntax-case stx ()
;       [name3 (identifier? (syntax name3)) (syntax [get-val])]]]]
; [define-values [get-val put-val!]
;   [let ([private-val 0])
;     [values [lambda () private-val]
;       [lambda (v) [set! private-val v]]]]]
; [displayln ""]
; [+ name3 3]

; [define-syntax (trans stx)
;   [syntax-case stx (=>)
;     [(_ a => b) #'[print "it works\n"]]]]

; [define-syntax (name4 stx)
;   [syntax-case stx (=> stx-cdr)
;     [(name4 a => b)
;       [begin
;         [displayln ""]
;         [print [datum->syntax #'lex [cdr [syntax->datum stx]] #'srcloc]]
;         [displayln ""]
;         #'[begin
;           [in-range a b]
;           ;[display [datum->syntax #f [cdr [syntax->datum ranger]]]]
;            ]]]]]
; [displayln ""]
; [for/list [(i [name4 10 => 30])] i]

; ; with-syntax
; [define-syntax (name5 stx)
;   [syntax-case stx (=>)
;     [(name5 a => b)
;       [with-syntax ([ranger #'[in-range 'a 'b]])
;         [begin [print stx] #'ranger]]]]]
; [displayln ""]
; [for/list [(i [name5 10 => 30])] i]

; ; arbitrary transformers (now that's cool!)
; [define-syntax (name6 stx)
;     [define something [datum->syntax #'lex [cdr [syntax->datum stx]] #'srcloc]]
;     [print something]
;     something]
; [name6 + 1 2 8]

; [define-syntax (name7 stx)
;   [print [cdr [syntax->datum stx]]]
;   #'[void]]
; [name7 there is some really 'cool "shite" goin on eh => x y z [keeek]]

; [exit]

; ; [define-syntax (something stx)
; ;   [syntax-case [stx-cdr stx] ()
; ;     [(a b) [displayln 1] #'[void]]
; ;     [(a) [displayln 2]]  #'[void]]]

; [define (watch-file name)
;   [define notifier [inotify-init]]
;   [define watcher [inotify-add-watch! notifier name 'IN_MODIFY]]
;   [inotify-read notifier]]
; ;[watch-file "extra.rkt"]
; ;[define notifier [inotify-init]]
; ;[inotify-read notifier]

; [include "extra.rkt"]
; ; This is a draft of creating a racket-to-any-language transpiler.
; ; The idea is to use racket macros and functions to transpile racket to any language.
; ; The target language can be changed by swapping out the macros.

; (define-namespace-anchor a)
; (define ns (namespace-anchor->namespace a))

; [define (Option type)
;   [string-append "Option<" type ">"]]

; [define (Result type error)
;   [string-append "Result<" type ", " error ">"]]

; [define (array elements)
;   [string-append "[" [commaify elements] "]"]]

; [define (commaify elements)
;   [string-join (map ~a elements) ", "]]

; [define-syntax-rule (Some element) [string-append "Some(" [symbol->string [quote element]] ")"]]

; ;; Primitive types
; [define MAX_BITS_INTEGERS 128]
; [define MAX_BITS_FLOAT 64]

; [define (i bits)
;   [when (> bits MAX_BITS_INTEGERS) [raise "Too many bits for signed integer type"]]
;   [when (not (= (modulo bits 2) 0)) [raise "Number of bits not a power of 2"]]
;   [string-append "i" [number->string bits]]]

; [define (u bits)
;   [when (> bits MAX_BITS_INTEGERS) [raise "Too many bits for unsigned integer type"]]
;   [when (not (= (modulo bits 2) 0)) [raise "Number of bits not a power of 2"]]
;   [string-append "u" [number->string bits]]]

; [define (ref type) [string-append "&" type]]
; [define (refmut type) [string-append "&mut " type]]
; [define (usize) "usize"]
; [define (isize) "isize"]
; [define (bool) "bool"]
; [define (char) "char"]
; [define (f bits)
;   [when (> bits MAX_BITS_FLOAT) [raise "Too many bits for float type"]]
;   [when (not (= (modulo bits 2) 0)) [raise "Number of bits not a power of 2"]]
;   [string-append "f" [number->string bits]]]

; [define-syntax-rule (argument-list arguments)
;   [commaify [for/list ([i [quote arguments]])
;     [match i
;       [(list name type) [string-append [symbol->string name] ": " [eval type ns]]]]]]]

; [define-syntax-rule (fn name in out body)
;   [let ([arrow [if (= [string-length out] 0) "" " -> "]])
;     [string-append "fn " [symbol->string [quote name]] "(" [argument-list in] ")" arrow out " {\n" [string-join [for/list ([i [quote body]]) [eval i ns]] ";\n"] "\n}"]]]

; ; Your code
; [displayln [Option [i 128]]]
; [displayln [Option [f 64]]]
; [displayln [Result [f 64] [i 32]]]
; [define-syntax-rule (var name expr) [string-append "let mut " [symbol->string [quote name]] " = " expr]]
; [define-syntax-rule (val name expr) [string-append "let " [symbol->string [quote name]] " = " expr]]

; ; [fn main '[] [Option [i 16]] [Result [i 32] [i 32]]]
; ; fn - Name, arguments, output, body
; [displayln [array '[1 2 3]]]
; [displayln [var a [array '[1 2 3]]]]
; [displayln [val b [array '[1 2 3]]]]

; [define-syntax-rule (dep name version)
;   [let [(name [symbol->string [quote name]])
;       (version [symbol->string [quote version]])]
;     [displayln [string-append name " = \"" version "\""]]
;     [string-append "extern crate " name ";"]]]

; [define-syntax-rule (+= left right)
;   [string-append [symbol->string [quote left]] " += " right]]

; [dep slog-json 1.3.2]
; [dep bgjk 0.1.0]
; [fn main ([in [i 32]] [control [refmut [char]]]) [Option [i 32]] ""]
; [display [fn main [] "" [
;   [val a "kek"]
;   [+= kek "rek"]
;   [var b "one hundred"]]]]

; [define-syntax-rule (macro (stuff ...) body ...)
;   [define-syntax-rule (stuff ...) [begin body ...]]]

; [match '(1 2 1)
;   [(list a b a) [display b]]
;   [(list a b c) [display a]]]

; [define (fact n)
;   [if (> n 1) [* n [fact [- n 1]]] n]]
; [displayln [fact 10]]

; [displayln [foldr - 0 '[1 3]]]
; [filter symbol? '[1 2 a control "chicka" 5]]

; [define listty [for/list ([i (in-range 1000)]) [random 100]]]
; [void [time [sort listty <]]]

; [define frame [new frame% [label "Example"] [width 300] [height 300]]]
; [define panel [new horizontal-panel% [parent frame] [style '[border]] [horiz-margin 30]]]
; [define msg [new message% [parent panel] [label "Nothing so far"]]]
; [define msg2 [new message% [parent panel] [label "Another msg"]]]
; [define msg3 [new message% [parent panel] [label "Replace"]]]
; [define butt [new button% [parent panel] [label "Button"]]]
; [define checker [new check-box% [parent panel] [label "Check Box"] [value #f] [callback
;   [lambda (a b) [print a] [print b]]]]]
; ;[new button% [parent frame] [label "Click here"] [callback [lambda [button event] [send msg set-label "Clicked!"]]]]
; ;[thread [lambda () [begin [sleep 1.5] [displayln "Hey listen!"]]]]
; [send frame show #t]

; [send checker get-value]

; ;
; ;[define my-canvas% [class canvas% canvas% [define/override [on-event event] [send msg set-label "Canvas Mouse"]]
; ;  [define/override [on-char event]
; ;    [send msg set-label "Canvas Keyboard"]]
; ;  [super-new]]]
; ;
; ;[new my-canvas% [parent frame]]
; ;[new button% [parent frame] [label "pause"] [callback [lambda (button event) [sleep 5]]]]
; ;
; ;[define panel (new horizontal-panel% [parent frame])]
; ;[new button% [parent panel]
; ;  [label "left"]
; ;  [callback [lambda (button event) [send msg set-label "left click"]]]]
; ;[new button% [parent panel]
; ;  [label "Right"]
; ;  [callback [lambda (button event) [send msg set-label "Right click"]]]]
; ;
; ;[define frame2 [new frame% [label "Example"] [width 300] [height 300]]]
; ;[new canvas% [parent frame2] [paint-callback
; ;  [lambda (canvas dc)
; ;    [send dc set-scale 3 3]
; ;    [send dc set-text-foreground "blue"]
; ;    [send dc draw-text "Don't Panic!" 0 0]]]]
; ;[send frame2 show #t]
; ;
; ;[define dialog [instantiate dialog% ["Example"]]]
; ;[new text-field% [parent dialog] [label "Your name"]]
; ;[define panel2 [new horizontal-pane% [parent dialog] [alignment '[center center]]]]
; ;[new button% [parent panel2] [label "Cancel"]]
; ;[new button% [parent panel2] [label "Ok"]]
; ;[when [system-position-ok-before-cancel?] [send panel change-children reverse]]
; ;[send dialog show #t]
; ;

; ; [define-namespace-anchor anchor]
; ; [define namespace [namespace-anchor->namespace anchor]]
; ; [define (repl)
; ;   [display "\n>"]
; ;   [write [eval [read] namespace]]
; ;   [repl]]
; ; [repl]
