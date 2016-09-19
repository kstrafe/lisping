[module main racket

[define-syntax skip
	[syntax-rules ()
		[(_ body ...) #f]]]

[skip [require 2htdp/image]
[define tri
	[let sierpinski ([n 14])
		[if (zero? n)
			[triangle 2 'solid 'red]
			[let ([t (sierpinski [- n 1])])
				[freeze [above t (beside t t)]]]]]]
[save-image tri "file.png"]
]
[displayln "A racket source file"]


[define-syntax foo
	[syntax-rules (:)
		; We write patterns here
		[(_ [x]) (displayln "we wuz kangz")]
		[(_ : x) (displayln x)]]]

[define-syntax swap
	[syntax-rules ()
		[(_ a b) (let ([tmp a])
							[set! a b]
							[set! b tmp])]]]

[define-syntax fn
	[syntax-rules ()
		[(_ name (arg ...) body ...) (
			define (name arg ...) [begin body ...])]]]

[fn whatever () [displayln "function whatever"]]
[fn bar (value other) [displayln [+ value other]]]
[whatever]
[bar 1 2]

[when #f [displayln 'cool] [displayln 'nice]]

[define-syntax displaylns
	[syntax-rules ()
		[(_ a ...) (displayln (list a ...))]]]

[define-syntax loop
	[syntax-rules ()
		[(loop body ...) (let looper () [begin body ... (looper)])]]]

[define x 1]
;[loop [displaylns x "\n"] [sleep 0.05] [set! x (+ x 1)]]

[let ([tmp 100] [a 3] [c 45])
	[swap a c]
	[displaylns a c]
	[displayln a]
	[displayln c]]
[begin [displayln 1] [displayln 23]]

[foo : 'we-really-need-some-help-over-here!]

[define max-hp 100]
[define hit #t]
[when hit
	[set! max-hp [- max-hp 1]]]
[displayln max-hp]

[fn kek () [displayln "We kek around a lot"]]
[kek]

[define-syntax warn
	[syntax-rules ()
		[(warn body ...) [displayln (quote (body ...))]]]]


[fn info (x) [displayln x]]
[info '(ok 100)]

[define curdate [seconds->date [current-seconds]]]
[displayln curdate]
[warn key 10 nice stuff]

[define-syntax name
	[syntax-rules () ; Put literals here
		[(_ arg) (quote arg)]]]

[fn variadic (a b c)
	[displayln [quote [a b c]]]]

[define-syntax variadic-macro
	[syntax-rules ()
		[(_ a b c) (quote [a b c])]]]

[variadic 1 2 kek]
[variadic-macro 1 2 kek]

(fn rek [x] [* x x x x])
[fn fact [n]
	[if [<= n 0]
		1
		[* n [fact [- n 1]]]]]

[displayln "WWWWWWWWWWW"]
[displayln [quasiquote [unquote [* 1 100]]]]
[displayln [quote [* 1 100]]]

[displayln [case [random 4]
	[(0) 'zero]
	[(1) 'one]
	[else 'other]]]

[displayln [cond
	[(= [random 10] 0) 'zero]
	[else 'other]]]

[define example [make-parameter "an example"]]
[fn whatever2 () [displayln [example]]]
[whatever2]
[parameterize ([example "something different"])
	[whatever2]]
[whatever2]

[struct pos (x y z) #:prefab #:mutable]
[let* ([p [pos 8 2 3]]
       [x p])
  [set-pos-x! p 10]
  [displayln [pos-x p]]
  [displayln p]]

[displayln 10]

[define saved-k #f]
[define [save-it!]
	[call-with-composable-continuation
		[lambda (k)
			(set! saved-k k)
			0]]]
[* 3 [+ 7 [save-it!]]]
[saved-k 0]
[saved-k 10]

[define-syntax-rule (swaps x y)
	[let ([tmp x])
		[set! x y]
		[set! y tmp]]]

[define xs 1]
[define y 100]
[swaps xs y]
[displayln xs]


[exit]

[define a 1]
[loop
	[set! a [+ a 1]]
	[displayln a]]

[name kek]




]
