REBOL [
	title: "TRUNCATE-FACE Playground"
]

do %../../framework/libraries/rebgui.r

lo: [space 0x0 margin 0x0]

text: "123456789012345678901234567890%"

make-text: does [
	show-text i copy text
]

make-truncation: func [face] [
	make-text
	truncate-face/postfix face ".. %"
	show face
]

display "test" [
	i: text #W yellow 25 para [wrap?: false] on-resize [make-text make-truncation i]
]

make-text

make-truncation i

do-events