gauge: make rebface [
	size:	50x12
	options: copy [colors [red 0 green 1]]
	cols: none
	default-tool-tip: none
	point-action: tool-tip-action: none
	data: none
	grad-block: copy [pen none]
	tick-block: copy [pen black fill-pen white]
	tick: none
	border: 20
	grad-height: 10
	fill-type: 'gradient
	points-spec: copy []
	points: none
	dec-places: 3
	size-text-face: make face [
		size: 1000000x1000000
	]
	effect: [draw none draw none]
	color:	colors/widget
	edge:	default-edge
	feel:	make default-feel [
		engage: func [f a e /local r][
			switch a [
				up [
					all [
						get in f 'point-action
						r: f/match-point e/offset - f/edge/size
						f/point-action e/offset r
					]
				]
			]
		]

		redraw: make function! [face act pos] [
			if act = 'show [
				face/effect/2: compose face/grad-block
				face/effect/4: compose face/tick-block
				face/points: compose face/points-spec
			]
		]
	]

	match-point: func [pos [pair!] /local i][
		i: 0
		foreach [o s] points [
			i: i + 1
			if within? pos o s - o + 2 [return reduce [i pick data i]]
		]
		return none
	]
	
	tool-tip-handler: [
		"" [
			use [result p][
				result: false
				if function? :tool-tip-action [
					if p: match-point event/offset - win-offset? face [
						result: tool-tip-action p
					]
				]
				switch type?/word result [
					string! block! [
						face/tool-tip/1: result
					]
					logic! [all [face/default-tool-tip face/tool-tip/1: face/default-tool-tip/1]]
				]
			]
		]
	]
	
	set-options: func [
		options [block!]
		/local
			w b e borders
	][
		fill-type: 'gradient
		all [
			find options 'plain-color-fill
			fill-type: 'plain
		]
		all [
			find options 'background-transparent
			color: none
		]
		all [
			find options 'no-edge
			edge: none
		]
		dec-places: any [select options 'decimal-places 3]
		cols: copy any [select options 'colors []]
		if tool-tip = tool-tip-handler [tool-tip: none]
		if tool-tip-action: select options 'tool-tip-action [
			default-tool-tip: tool-tip
			tool-tip: tool-tip-handler
			tool-tip-action: func [matched-point [block!]] tool-tip-action
		]
		if point-action: select options 'point-action [
			point-action: func [mouse-pos [pair!] matched-point [block!]] point-action
		]
		
		clear skip grad-block 2
		tick: none
		unless empty? cols [
			tick: 1 / (last cols)
			borders: border * 2
			
			switch fill-type [
				gradient [
					forskip cols 2 [
						unless cols/3 [break]
						b: cols/2 * tick
						e: cols/4 * tick
						w: e - b
						append grad-block compose [
							fill-pen linear (to-paren compose [as-pair size/x - (borders) * (b) + (border) 0]) 0 (to-paren compose [size/x - (borders) * (w)]) 0 2 1 (cols/1) (cols/3) (cols/3)
							box (to-paren compose [as-pair size/x - (borders) * (b) + (border) size/y / 2 - (to-paren [size/y / grad-height]) ])
							(to-paren compose [as-pair size/x - (borders) * (e) + (border) size/y / 2 + (to-paren [size/y / grad-height])])
						]
					]
					cols: head cols
				]
				plain [
					forskip cols 2 [
						unless cols/2 [break]
						b: cols/1 * tick
						e: cols/3 * tick
						w: e - b
						append grad-block compose [
							fill-pen (cols/2)
							box (to-paren compose [as-pair size/x - (borders) * (b) + (border) size/y / 2 - (to-paren [size/y / grad-height]) ])
							(to-paren compose [as-pair size/x - (borders) * (e) + (border) size/y / 2 + (to-paren [size/y / grad-height])])
						]
					]
				]
			]
		]
	]
	
	set-data: func [
		data [block! none!]
		/local borders st ty tmp i b ti
	][
		unless data [exit]
		tmp: true
		clear skip tick-block 4
		borders: border * 2
		i: 0
		clear points
		unless empty? data [
			ti: any [tick 1 / (1 + last data)]
			foreach p data [
				i: i + 1
				size-text-face/text: either value? 'form-decimal [form-decimal p dec-places][form p]
				st: size-text size-text-face
				either tmp: not tmp [ts: '+ ty: -2][ts: '- ty: st/y + 2]
				p: p * ti
				append tick-block b: compose [
					box (to-paren compose [as-pair size/x - (borders) * (p) + (border) - 1 size/y / 2 - (to-paren [size/y / grad-height]) - 3 ])
					(to-paren compose [as-pair size/x - (borders) * (p) + (border) + 1 size/y / 2 + (to-paren [size/y / grad-height]) + 3]) 2
					text (to-paren compose [as-pair size/x - (borders) * (p) + (border) - (st/x / 2) size/y / 2 (ts) (to-paren [size/y / grad-height]) - (ty)]) (size-text-face/text)
					
				]
				append points-spec reduce [b/2 b/3]
			]
		]
	]

	redraw: does [
		show self
	]
	
	init: make function! [] [
		set-options options
		set-data data
	]
]