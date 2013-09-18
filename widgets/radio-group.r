radio-group: make rebface [
	size:		50x-1
	pane:		[]
	;BEG fixed by Cyphre, sponsored by Robert
	picked:		none
	default:	none
	selected:	make function! [] [if picked [first back find data picked]]
	select-item: make function! [
		item [integer! none!]
		/no-action
		/local old
	][
		; support none values
		if none? item [
			if none? default [return false]
			item: default
		]

		if item <> picked [
			foreach f pane [
				if f/data = item [
					if picked <> data [
						;	deflag old
						if old: picked [
							foreach fac pane [
								if fac/data = old [
									clear skip fac/effect/draw 7
									show fac
									break
								]
							]
						]
						;	flag new
						picked: f/data
						insert tail f/effect/draw compose [pen (colors/true) fill-pen (colors/true) circle (as-pair sizes/cell * 1.5 sizes/cell * 2.5) (sizes/cell - 1)]
						if none? no-action [action self]
						show f
						return true
					]
				]
			]
		]
		false
	]

	reset-action: func [face] [
		face/select-item/no-action face/default
	]

	;END fixed by Cyphre, sponsored by Robert
	init:	make function! [/local pos width index beg] [
		;BEG fixed by Cyphre, sponsored by Robert
		either any [
			integer? default: first data
			none? default
		] [
			picked: default
			remove data
		][
			picked: default: 1
		]
		;END fixed by Cyphre, sponsored by Robert
		index: 0
		parse data [
			some [
				(index: index + 1)
				beg: string! integer!
				| string! (insert next beg index) skip
			]
		]
		pos: 0x0
		if negative? size/y [size/y: sizes/line * ((length? data) / 2)]
		width: either size/y > sizes/line [size/x] [to integer! size/x / ((length? data) / 2)]

		foreach [label id] data [;fixed by Cyphre, sponsored by Robert
			insert tail pane make rebface compose/deep [
				offset:	pos
				size:	as-pair width sizes/line
				text:	label
				effect:	[draw [pen (colors/edge) fill-pen (colors/edit) circle (as-pair sizes/cell * 1.5 sizes/cell * 2.5) (sizes/cell * 1.5)]]
				data:	id
				font:	default-font
				para:	make default-para [origin: as-pair sizes/line 2]
				feel:	make default-feel [
					over: make function! [face act pos] [
						face/effect/draw/pen: either act [colors/over] [colors/edge]
						show face
					]
					redraw: make function! [face action /local tmp][
						if all [
							action = 'show
							tmp: find face/parent-face/data face/data
						][
							face/text: translate first back tmp;fixed by Cyphre, sponsored by Robert
						]
					]
					engage: make function! [face act event /local pf old] [
						switch act [
							up [
								if all [pf: face/parent-face pf/picked <> face/data] [ ;fixed by Cyphre, sponsored by Robert
									;	deflag old
									old: pf/picked ;fixed by Cyphre, sponsored by Robert
									if old [
										foreach f pf/pane [
											if f/data = old [
												clear skip f/effect/draw 7
												show f
												break
											]
										]
									]
									;	flag new
									pf/picked: face/data ;fixed by Cyphre, sponsored by Robert
									insert tail face/effect/draw compose [pen (colors/true) fill-pen (colors/true) circle (as-pair sizes/cell * 1.5 sizes/cell * 2.5) (sizes/cell - 1)]
									show face
									pf/action pf
								]
							]
							away	[face/feel/over face false 0x0]
						]
					]
				]
			]
			pos: pos + any [if size/y > sizes/line [as-pair 0 sizes/line] as-pair width 0]
		]
		if all [integer? default default > 0] [
			foreach f pane [
				if f/data = default [
					insert tail f/effect/draw compose [
						pen (colors/true) fill-pen (colors/true) circle (as-pair sizes/cell * 1.5 sizes/cell * 2.5) (sizes/cell - 1)
					]
					break
				]
			]
		]
	]
]
