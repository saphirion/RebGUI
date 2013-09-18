check: make rebface [
	size:	-1x5
	text:	""
	reset-action: func [face] [show-data face false]
	effect:	[draw [pen colors/edge fill-pen colors/edit box 0x0 0x0]]
	font:	default-font
	para:	make default-para [origin: as-pair sizes/line 2]
	feel:	make default-feel [
		over: make function! [face act pos] [
			face/effect/draw/pen: either act [colors/over] [colors/edge]
			show face
		]
		engage: make function! [face act event] [
			switch act [
				down		[show-data face either none? face/data [true] [none] face/action face]
				alt-down	[unless find face/options 'bistate [show-data face either none? face/data [false] [none] face/action face]]
				away		[face/feel/over face false 0x0]
			]
		]
	]
	init:	make function! [/local p1 p2 t1 t2] [
		if word? data [data: switch data [false [false] true [true]]]
		if negative? size/x [size/x: 1000000 size/x: 4 + para/origin/x + first size-text self]
		effect/draw/6/y: sizes/cell
		effect/draw/7: as-pair sizes/cell * 3 sizes/cell * 4
		;	pre-generate draw points
		p1: as-pair 2 sizes/cell + 2
		p2: -4x-4 + p1 + as-pair sizes/cell * 3 sizes/cell * 3
		t1: as-pair 2 sizes/cell * 3
		t2: as-pair sizes/cell * 1.5 p2/y
		;	info option
		if find options 'info [
			effect/draw/4: colors/widget
			feel: make default-feel []
		]
		;	compose redraw func
		feel/redraw: make function! [face act pos] compose/deep [
			if act = 'show [
				clear skip face/effect/draw 7
				unless none? face/data [
					insert tail face/effect/draw compose either face/data [
						[pen (colors/true) line-width (sizes/cell / 3) line (t1) (t2) (as-pair p2/x p1/y)]
					][
						[pen (colors/false) line-width (sizes/cell / 3) line (p1) (p2) line (as-pair p2/x p1/y) (as-pair p1/x p2/y)]
					]
				]
			]
		]
	]
]
