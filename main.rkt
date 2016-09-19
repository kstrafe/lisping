[module main racket

[require [for-syntax racket/match]]

[displayln "ENTERING RUNTIME"]

[define-syntax [example1 syntax-tree]
	[displayln "ENTERING COMPILE-TIME"]
	[writeln [syntax->datum syntax-tree]]
	[syntax (void)]]
[example1 As many as you want]

[define-syntax [example2 syntax-tree]
	[writeln [syntax->datum syntax-tree]]
	#'(void)]
[example2 We can use a shorthand]

[define-syntax [example3 syntax-tree]
	[writeln [syntax->datum syntax-tree]]
	#'(displayln "example 3")]
[example3 We can use a shorthand]

[define stx
	#'[when [> x 1] [100 [displayln 'kek]]]]

stx
[syntax->datum stx]
[syntax-source stx]
[syntax-line   stx]
[syntax-column stx]
[syntax-e      stx]  ; convert only a top level

[define-syntax [reverser stx]
	[datum->syntax stx [reverse [cdr [syntax->datum stx]]]]]
[reverser "backwards" "am" "i" list]

; Using match on the syntax
[define-syntax [custom-if stx]
	; Can also use syntax->list here.
	; That preserves some information
	[match (syntax->datum stx)
		[(list _ condition true-expr false-expr)
		 (datum->syntax stx `(cond [,condition ,true-expr]
		                           [else ,false-expr]))]]]
[custom-if [> 15 10] "Bigger" "Smaller"]

; Creating compile-time callable functions/variables
[begin-for-syntax
	[define a-constant-value "This is my compile constant"]]
[define-for-syntax value1 " | Another one"]
[define-syntax [example4 stx]
	[datum->syntax stx [string-append a-constant-value value1]]]
[example4]
; a-constant-value ; This won't work during runtime


[define-syntax [using-syntax-case stx]
	[syntax-case stx ()
		[(_ condition true-expr false-expr)
		 #'(cond [condition true-expr]
		         [else false-expr])]]]
[using-syntax-case #t "Yes" "No"]
[using-syntax-case #f "Yes" "No"]
; [using-syntax-case #f "Yes" "No" "error"] ; "bad syntax"

[define-syntax-rule [another-if condition true-expr false-expr]
	[cond [condition true-expr]
	      [else false-expr]]]
[another-if #t "Completely True" "Completely False"]
[another-if #f "Completely True" "Completely False"]

[define-for-syntax [replace-first datum with]
	[displayln datum]
	[cons with [cddr datum]]]

[define-syntax [macro stx]
	[displayln [replace-first [syntax->datum stx] 'control]]
	#'(void)]
[macro we are kek]

]
