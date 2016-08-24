[module main racket
	[require 2htdp/image]
	[define tri
		[let sierpinski ([n 5])
			[if (zero? n)
				[triangle 2 'solid 'red]
				[let ([t (sierpinski [- n 1])])
					[freeze [above t (beside t t)]]]]]]
	[save-image tri "file.png"]
	[display "A racket source file"]

	[define-syntax foo
		[syntax-rules ()
			; We write patterns here
			[(_ [x]) (display "we wuz kangz")]
			[(_ : x) (display x)]]]

	[define-syntax swap
		[syntax-rules ()
			[(_ a b) (let ([tmp a])
								[set! a b]
								[set! b tmp])]]]

	[display "\n"]

	[define-syntax displays
		[syntax-rules ()
			[(_ a ...) (display (list a ...))]]]

	[define-syntax macrod
		[syntax-rules ()
			[(_ name (a) body)
				[display [quote (name a body)]]
	]]]

	[macrod cool (kewl) [display]]

	[let ([tmp 100] [a 3] [c 45])
		[swap a c]
		[displays a c]
		[display a]
		[display "\n"]
		[display c]
		[display "\n"]]

	[foo : 'we-really-need-some-help-over-here!]

	[define max-hp 100]
	[define hit #t]
	[when hit
		[set! max-hp [- max-hp 1]]]
	[display max-hp]

]
