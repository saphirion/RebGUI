chevron: make rebface [
	size:	5x5
	data:	'down
	feel:	make default-feel [
		redraw: make function! [face act pos] [
			all [act = 'show face/color: either face/data [colors/btn-down] [colors/btn-up]]
		]
		engage: make function! [face act event] [
			switch act [
				time	[if face/data [face/action face]]
				down	[face/data: on face/action face]
				up		[face/data: off]
				over	[face/data: on]
				away	[face/data: off]
			]
			show face
		]
	]
	effect:	[draw [pen none fill-pen colors/btn-text polygon]]
	edge:	default-edge
	init:	make function! [/local flip-pair rel-coord size2 gsize gcenter os goffset weight] [
		size/y: size/x
		size2: either edge [size - edge/size - edge/size] [size]
			flip-pair: make function! [pair offset] [
			pair: pair - offset
			offset + as-pair pair/y pair/x
		]
			rel-coord: make function! [x y] [
			goffset + as-pair x y
		]
		gsize: min size2/x size2/y
		gsize: gsize - either gsize > 17 [7] [5]
		gcenter: reduce [to integer! gsize / 2 none]
		gcenter/2: gsize - gcenter/1
		weight: max 2 to integer! gsize / 6
		os: goffset: size2 - gsize / 2
		goffset/y: size2/y - gcenter/1 - weight - 1 / 2
		foreach pair reduce [
			rel-coord gcenter/1 0
			rel-coord 0 gcenter/1
			rel-coord weight gcenter/1 + weight
			rel-coord gcenter/1 2 * weight
			rel-coord gcenter/2 2 * weight
			rel-coord gsize - weight gcenter/1 + weight
			rel-coord gsize gcenter/1
			rel-coord gcenter/2 0
		][
			insert tail effect/draw switch data [
				up		[pair]
				right	[pair: flip-pair pair os pair/x: size2/x - 1 - pair/x pair]
				down	[pair/y: size2/y - 1 - pair/y pair]
				left	[flip-pair pair os]
			]
		]
		data: off ; redefine data
	]
]