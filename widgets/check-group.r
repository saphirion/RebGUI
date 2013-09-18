check-group: make rebface [
	size:	50x-1
	pane:	[]

	feel: make default-feel [
		redraw: make function! [f a p] [
			unless function? f/data [
				if all [not empty? f/data word? f/data/1] [f/data: reduce f/data]
				repeat n length? f/data [
					set in pick f/pane n 'data pick f/data n
				]
				f/data: get in f 'data-func
			]
		]
	]

	data-func: make function! [/local states] [
		states: copy []
		foreach check pane [
			insert tail states check/data
		]
		states
	]

	init:	make function! [/local pos width last-pane] [
		pos: 0x0
		if negative? size/y [size/y: .5 * sizes/line * length? data: reduce data] ; AGT 25-May-2006
		width: either size/y > sizes/line [size/x] [2 * to integer! size/x / length? data]
		foreach [label state] data [
			insert tail pane make check [
				offset:	pos
				size:	as-pair width sizes/line
				text:	label
				data:	state
				action: func [face] [face/parent-face/action face/parent-face]
			]
			pos: pos + any [if size/y > sizes/line [as-pair 0 sizes/line] as-pair width 0]
			last-pane: last pane
			last-pane/options: options
			last-pane/init
			last-pane/init: none
		]
		data: :data-func
	]
]
