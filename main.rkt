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
		[syntax-rules (:)
			; We write patterns here
			[(_ [x]) (display "we wuz kangz")]
			[(_ : x) (display x)]
		]
	]

	[foo : 'we-really-need-some-help-over-here!]

	[define max-hp 100]
	[define hit #t]
	[when hit
		[set! max-hp [- max-hp 1]]]
	[display max-hp]

]
