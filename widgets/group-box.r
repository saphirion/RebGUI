group-box: make rebface [
	size:	-1x-1
	text:	"Untitled"
	pane:	copy []
	effect:	[draw []]
	font: make default-font []
	para:	make default-para [origin: as-pair sizes/cell * 2 0]
	fx: [ 
			pen (colors/edge)
			line (as-pair 0 sizes/cell * 2 - 2)
				(-2x-2 + as-pair sizes/cell * 2 sizes/cell * 2)
			line
				(as-pair sizes/cell * 2 + first size-text self sizes/cell * 2 - 2)
				(as-pair size/x - 1 sizes/cell * 2 - 2)
				(size - 1x1)
				(as-pair 0 size/y - 1)
				(as-pair 0 sizes/cell * 2 - 2)
		]
	feel:	make default-feel [
		;	blank out portion of box line *after* view has allocated parent-face
		redraw: make function! [face act pos] [
			if act = 'show [
				face/effect/draw: compose bind fx in face 'self
			]
		]
	]
	init:	make function! [] [
		font/color: colors/menu
		font/valign: 'top
		font/align: 'left
		data: layout/only data
		pane: data/pane
		foreach face pane [face/offset: face/offset + as-pair 0 sizes/cell * sizes/gap]
		if negative? size/x [size/x: max 16 + first size-text self data/size/x]
		if negative? size/y [size/y: sizes/cell * sizes/gap + data/size/y]
		data: none
	]
]
