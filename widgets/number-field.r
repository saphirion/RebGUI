;this is a special widget which works with numbers in following string format "1.000.123,2213" etc.
;it is supposed to be used in specific project and therefore IMO it is not suitable for generic use in the RebGUI distro
;--Cyphre
   
number-field: make rebface [
	size:	50x5
	text:	""
	edge:	default-edge
	font:	default-font
	para:	default-para
	feel:	edit/feel
	selectable?: true
	editable?: true
	init:	make function! [] [
		color: either find options 'info [selectable?: editable?: false colors/widget] [colors/edit]
		para: make para [] ; avoid shared para object for scrollable input widget
		if negative? size/x [size/x: 1000000 size/x: 4 + first size-text self]
		data: has [result][
			if error? try [
				result: load text
			][
				result: copy text
			]
			if string? result [
				error? try [
					replace/all result "." ""
					replace result "," "."
					result: load result
				]
			]
			either number? result [
				result
			][
				none
			]
		]
	]
	esc:	none
	undo:	make block! 20
]
