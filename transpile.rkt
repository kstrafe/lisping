#lang racket

; This is a draft of creating a racket-to-any-language transpiler.
; The idea is to use racket macros and functions to transpile racket to any language.
; The target language can be changed by swapping out the macros.

[define (Option type)
  [string-append "Option<" type ">"]]

[define (Result type error)
  [string-append "Result<" type ", " error ">"]]

[define (array elements)
  [string-append "[" [string-join (map ~a elements) ", "] "]"]]

[define-syntax-rule (Some element) [string-append "Some(" [symbol->string [quote element]] ")"]]

;; Primitive types
[define MAX_BITS_INTEGERS 128]
[define MAX_BITS_FLOAT 64]

[define (i bits)
  [when (> bits MAX_BITS_INTEGERS) [raise "Too many bits for signed integer type"]]
  [when (not (= (modulo bits 2) 0)) [raise "Number of bits not a power of 2"]]
  [string-append "i" [number->string bits]]]

[define (u bits)
  [when (> bits MAX_BITS_INTEGERS) [raise "Too many bits for unsigned integer type"]]
  [when (not (= (modulo bits 2) 0)) [raise "Number of bits not a power of 2"]]
  [string-append "u" [number->string bits]]]

[define usize "usize"]
[define isize "isize"]
[define bool "bool"]
[define char "char"]
[define (f bits)
  [when (> bits MAX_BITS_FLOAT) [raise "Too many bits for float type"]]
  [when (not (= (modulo bits 2) 0)) [raise "Number of bits not a power of 2"]]
  [string-append "f" [number->string bits]]]

; Your code
[displayln [Option [i 128]]]
[displayln [Option [f 64]]]
[displayln [Result [f 64] [i 32]]]
[define-syntax-rule (var name expr) [string-append "let mut " [symbol->string [quote name]] " = " expr ";"]]
[define-syntax-rule (val name expr) [string-append "let " [symbol->string [quote name]] " = " expr ";"]]

; [fn main '[] [Option [i 16]] [Result [i 32] [i 32]]]
; fn - Name, arguments, output, body
[displayln [array '[1 2 3]]]
[displayln [var a [array '[1 2 3]]]]
[displayln [val b [array '[1 2 3]]]]
[displayln [val c [Some 3]]]
