led-group: make rebface [
	size:	50x-1
	pane:	[]
	init:	make function! [/local pos width last-pane] [
		pos: 0x0
		if negative? size/y [size/y: .5 * sizes/line * length? data: reduce data] ; AGT 25-May-2006
		width: either size/y > sizes/line [size/x] [2 * to integer! size/x / length? data]
		foreach [label state] data [
			insert tail pane make led [
				offset:	pos
				size:	as-pair width sizes/line
				text:	label
				data:	state
			]
			pos: pos + any [if size/y > sizes/line [as-pair 0 sizes/line] as-pair width 0]
			last-pane: last pane
			last-pane/init
			last-pane/init: none
		]
		data: make function! [/local states] [
			states: copy []
			foreach led pane [insert tail states led/data]
			states
		]
		feel: make default-feel [
			redraw: make function! [face act pos] [
				if all [act = 'show block? get in face 'data] [
					data: reduce data
					repeat i length? face/pane [
						face/pane/:i/data: pick face/data i
					]
					face/data: make function! [/local states] [
						states: copy []
						foreach led pane [insert tail states led/data]
						states
					]
				]
			]
		]
	]
]