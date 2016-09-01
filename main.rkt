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
[display "A racket source file"]


[define-syntax foo
	[syntax-rules (:)
		; We write patterns here
		[(_ [x]) (display "we wuz kangz")]
		[(_ : x) (display x)]]]

[define-syntax swap
	[syntax-rules ()
		[(_ a b) (let ([tmp a])
							[set! a b]
							[set! b tmp])]]]

[define-syntax fn
	[syntax-rules ()
		[(_ name (arg ...) body ...) (
			define (name arg ...) [begin body ...])]]]

[fn whatever () [display "function whatever"]]
[display "\n"]
[fn bar (value other) [display [+ value other]]]
[whatever]
[display "\n"]
[bar 1 2]

[when #f [display 'cool] [display 'nice]]

[display "\n"]

[define-syntax displays
	[syntax-rules ()
		[(_ a ...) (display (list a ...))]]]

[define-syntax loop
	[syntax-rules ()
		[(loop body ...) (let looper () [begin body ... (looper)])]]]

[define x 1]
;[loop [displays x "\n"] [sleep 0.05] [set! x (+ x 1)]]

[let ([tmp 100] [a 3] [c 45])
	[swap a c]
	[displays a c]
	[display a]
	[display "\n"]
	[display c]
	[display "\n"]]
[begin [display 1] [display 23]]

[foo : 'we-really-need-some-help-over-here!]

[define max-hp 100]
[define hit #t]
[when hit
	[set! max-hp [- max-hp 1]]]
[display max-hp]

[fn kek () [display "We kek around a lot"]]
[kek]

[display "\n~a"]

]
