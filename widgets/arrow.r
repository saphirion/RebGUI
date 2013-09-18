arrow: make rebface [
	size:	5x5
	data:	'down
	btn-colors: [colors/btn-down colors/btn-up]
	feel:	make default-feel [
		redraw: make function! [face act pos] [
			all [act = 'show face/color: pick reduce face/btn-colors face/data]
		]
		engage: make function! [face act event] [
			switch act [
				time	[if face/data [face/action face]]
				down	[face/data: on]
				up		[face/action face face/data: off]
				over	[face/data: on]
				away	[face/data: off]
			]
			show face
		]
	]
	effect:	[arrow (colors/btn-text) rotate 0]
	edge:	default-edge
	init:	make function! [] [
		size/y: size/x
		effect/rotate: select [up 0 right 90 down 180 left 270] data
		effect: compose effect
		data: off ; redefine data
	]
]