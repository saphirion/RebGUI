field: make rebface [
	size:	50x5
	text:	""
	cursor: 'i-shape
	edge:	default-edge
	font:	default-font
	para:	default-para
	feel:	edit/feel
	dirty-action: none
	editable?: true
	selectable?: true
	reset-action: func [face] [
		; either reset to number or empty text
		either none? data
			[
				face/text: copy ""
				if found? face/loc [face/loc/text: copy ""]
				face/data: none
			]
			[
				face/text: copy "0"
				if found? face/loc [face/loc/text: copy "0"]
				face/data: 0
			]
		show face
	]
	init:	make function! [/local tmp] [
		if tmp: find options 'on-dirty [
			dirty-action: get tmp/2
		]
		if find options 'no-feel [feel: none]
		color: either find options 'info [selectable?: editable?: false colors/widget] [colors/edit]
		para: make para [] ; avoid shared para object for scrollable input widget
		font: make font [] ; avoid shared font object for allowing individual font styles per field
		edge: make edge [] ; avoid shared edge object for allowing individual edge styles per field
		if negative? size/x [size/x: 1000000 size/x: 4 + first size-text self]
	]
	esc:	none
	undo:	make block! 20
]
