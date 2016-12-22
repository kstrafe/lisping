[module rle racket
  [provide [contract-out [rle-encode (-> only-dna string?)]]]
  [define (only-dna input-string)
    [regexp-match? #px"^(A|C|G|T)*$" input-string]]
  [define (only-dna-and-numbers input-string)
    [regexp-match? #px"^((A|C|G|T)[0-9]+)*$" input-string]]
  [define (rle-encode input-string)
    [let-values ([(working-string character count)
      [for/fold ([working-string ""]
                 [previous null]
                 [count null])
                ([item [string->list input-string]])
        [cond
          [(null? previous) [values working-string item 1]]
          [(char=? previous item) [values working-string item [add1 count]]]
          [else [values [string-append working-string [string previous] [number->string count]] item 1]]]]])
      [string-append working-string [string character] [number->string count]]]]]

[require 'rle]
[rle-encode "TGTCTCTGAAAAAAAAATTGCCCCCCCCCCCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"]

[regexp-match? #px"^((A|C|G|T)[0-9]+)*$" "A54G3"]

[define (collatz number)
  [cond
    [(= number 1) number]
    [(= [modulo number 2] 0) [collatz [/ number 2]]]
    [(= [modulo number 2] 1) [collatz [+ [* number 3] 1]]]]]
[define (collatz-memo number confirmed)
  [cond
    [(<= number confirmed) number]
    [(= [modulo number 2] 0) [collatz [/ number 2]]]
    [(= [modulo number 2] 1) [collatz [+ [* number 3] 1]]]]]
[for [(i (in-naturals [expt 2 160]))]
  [collatz-memo i [sub1 i]]
  [when [= [modulo i 10000] 0] [displayln `("Confirm" ,i)]]]
