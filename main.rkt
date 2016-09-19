[module main racket

[define-syntax [example1 syntax-tree]
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


[define-syntax [alias from-to]
	[define from-to-s [syntax->datum from-to]]
	[writeln from-to-s]
	[writeln [cadr from-to-s]]
	[writeln [caddr from-to-s]]

	[define new-name [cadr from-to-s]]
	[define old-name [caddr from-to-s]]

	#'[syntax [define-syntax [new-name args]
		[+ 1]]]
	#'[syntax [define-syntax]]]

[syntax->datum [alias macro define-syntax-rule]]

[exit]

]
