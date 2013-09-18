text: make rebface [
	size:	-1x5
	text:	""
	font:	default-font
	para:	default-para-wrap
	reset-action: func [face] [
		all [face/text clear face/text]
		face/data: 0
		show face
	]
	init:	make function! [] [
		if all [
			find text newline
			size/y = sizes/line
		][
			size/y: -1
		]
		if all [negative? size/x negative? size/y] [size: 1000000x1000000 size: 4x4 + size-text self]
		if negative? size/x [size/x: 1000000 size/x: 4 + first size-text self]
		if negative? size/y [size/y: 1000000 size/y: 4 + second size-text self]
		if all [size/y > sizes/line font/align <> 'center] [font: make font [valign: 'top]]
	]
]

label: make text [
	font:	make default-font [style: 'bold]
	reset-action: func [face] [
		face/data: 0
		show face
	]
]
