#lang typed/racket

(: distance (-> Real Real Number))
[define (distance left right)
  [sqrt [+ [* left left] [* right right]]]]

[define (counter)
  [for/stream ([i [in-naturals]])
    [* i i]]]

[require racket/generator]
[define g (in-generator
            (let loop ([x '(a b c)])
              [if (null? x)
                0
                [begin
                  [yield [car x]]
                  [loop [cdr x]]]]))]

[for/list ([i g])
  i]

[require typed/racket]
[struct None ()]
[struct (alpha) Some ([value : alpha])]
[define-type (Opt alpha) (U None (Some alpha))]
[: value (Opt String)]
[define value [Some "some bytes"]]

[require typed/racket]
[define (sum [numbers : Positive-Integer]) [: -> Positive-Integer]
  [+ 111 numbers]]
[sum [* 9999 9999 9999]]

[define (kek [a : String]) (: -> String) [string-append "due" a]]
[kek "disconnect"]
