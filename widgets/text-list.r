text-list: make rebface [
	size:	50x25
	color:	colors/widget
	data:	[]
	edge:	default-edge
	;	widget facets
	redraw:	none
	selected: none
	picked:	[]
	key-navigation: true
	return-key: true
	init:	make function! [/local p] [
		p: self
		pane: make face-iterator [
			size:		p/size
			span:		either p/span [copy p/span] [none]
			data:		p/data
			opts:	p/options				; share options block
			picked:		p/picked				; share picked block
			action:		get in p 'action		; share action func
			alt-action:	get in p 'alt-action	; share alt-action func
			dbl-action:	get in p 'dbl-action	; share dbl-action func
		]
		pane/init
		;	accessors
		redraw: get in pane 'redraw
		selected: get in pane 'selected
	]
]