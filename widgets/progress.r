progress: make rebface [
	size:	50x5
	effect: [draw [pen colors/menu fill-pen colors/menu box 0x0 1x1]]
	data:	0
	color:	colors/widget
	edge:	default-edge
	feel:	make default-feel [
		redraw: make function! [face act pos] [
			if act = 'show [
				face/effect/draw/box: max 1x1 -1x-4 + as-pair face/size/x - 3 * face/data: min 1 max 0 face/data face/size/y
			]
		]
	]
]