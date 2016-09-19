[module main racket

[define-syntax [alias from-to]
	[define from-to-s [syntax->datum from-to]]
	[writeln from-to-s]
	[writeln [cadr from-to-s]]
	[writeln [caddr from-to-s]]

	[define new-name [cadr from-to-s]]
	[define old-name [caddr from-to-s]]

	[syntax [+ 1]]]

[alias macro define-syntax-rule]

[exit]

]
