led: make rebface [
	size:	-1x5
	effect:	[draw [pen colors/edge fill-pen colors/window box 0x0 0x0]]
	font:	default-font
	para:	make default-para [origin: as-pair sizes/line 2]
	feel:	make default-feel [
		redraw: make function! [face act pos] [
			if act = 'show [
				face/effect/draw/4: case [
					find reduce [1 true] face/data [colors/true]
					find reduce [0 false] face/data [colors/false]
					true [colors/widget]
				]
			]
		]
	]
	init:	make function! [] [
		if word? data [data: switch data [false [false] true [true]]]
		if negative? size/x [size/x: 1000000 size/x: 4 + para/origin/x + first size-text self]
		effect/draw/6/y: sizes/cell 
		effect/draw/7: as-pair sizes/cell * 3 sizes/cell * 2.5
	]
]