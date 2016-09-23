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
[macro do [we are kek]]

[define [replace-first in-list with]
[cons with [cdr in-list]]]

[replace-first '[we are warriors] 'i]

[define [my-length my-list]
[match my-list
	[(list) 0]
	[else [+ 1 [my-length [cdr my-list]]]]]]

[my-length '[1 2 3 3 3 2]]

[define [take my-list count]
[if [= count 0]
	'()
	[match my-list
		['() '()]
		[else [cons [car my-list] [take [cdr my-list] [- count 1]]]]]]]

[take '[1 2 3 4 5] 2]

[define [drop my-list count]
[if [= count 0]
	my-list
	[match my-list
		['() '()]
		[else [drop [cdr my-list] [- count 1]]]]]]

[drop '[1 2 3 4 5 6 7] 5]

[define [my-append list1 list2]
[match list1
	['() list2]
	[else [cons [car list1] [my-append [cdr list1] list2]]]]]

[my-append '[1 2] '[3 9]]

[define [my-member list1 element]
[match list1
	['() #f]
	[else [if [= [car list1] element]
		#t
		[my-member [cdr list1] element]]]]]

[my-member '[1 8 3] 1]

[define [my-position list1 element]
[match list1
	['() 0]
	[else
		[if [= [car list1] element]
			0
			[+ 1 [my-position [cdr list1] element]]]]]]

[my-position '[1 2 3 8 9 0] 3]

[define ns [make-base-namespace]]

[with-output-to-file "stuff.txt"
[lambda () [write '[+ 1 2 3]]]
#:exists 'replace]
[with-input-from-file "stuff.txt"
[lambda () [eval [read] ns]]]

[define x 10]

[write x]

]
