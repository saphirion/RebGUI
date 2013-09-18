drop-list: make rebface [
	size:	25x5
	text:	""
	color:	colors/widget
	data:	[]
	edge:	default-edge
	font:	default-font
	para:	make default-para [margin: as-pair sizes/slider + 2 2]
	;BEG fixed by Cyphre, sponsored by Robert
	popup-mode: 'inside ;can be 'outside
	lines: 'auto ;can be forced to number of lines
	droplist-mode: 'auto ;can be also forced to 'downward 'upward or 'middle
	resize-list?: false
	editable?: false  ;if true the field part is editable; if set to 'filter-list enables the filtered list content
	auto-fill?: false ;enables automatic completion from the selection list
	drop-down-picked: 0
	picked-line: picked: hidden-caret: hidden-text: none
	unfocus-act: :on-unfocus
	state-words: [
		data
		picked
		show?
	]

	picked-init: picked-line-init: none
	
	translate-action: func [face /l caret?][
		if none? face/picked [exit]
		caret?: false
		if all [view*/caret same? face/picked head view*/caret] [caret?: true]
		set-picked/no-action/no-show translate face/picked
		if caret? [
			view*/caret: tail face/picked
		]
	]

	set-picked: func [
		txt [string! integer!]
		/no-action
		/no-show
	][
		if none? txt [exit]
		
		picked: text: either string? txt [
			picked-line: find data txt
			picked-line: all [picked-line index? picked-line]
			txt
		][
			either txt = 0 [
				picked-line: picked-line-init
				picked-init
			][
				picked-line: txt
				pick data txt
			]
		]
		if found? self/loc [self/loc/text: self/text]
		unless no-action [self/action self]
		unless no-show [show self]
	]
	set-data: func [
		blk [block!]
		/initial
			idx [integer!]
	][
		data: blk
		if initial [text: picked: pick data picked-line: idx]
		show self
	]
	alter-data: func [
		index [integer!]
		value [string!]
		/local tmp
	][
		tmp: data/:index
		poke data index value
		if tmp = text [text: value]
		show self
	]

	redraw: does [
		check-editable
		show self
	]

	;END fixed by Cyphre, sponsored by Robert
	check-editable: does [
		either editable? [
			if :unfocus-act = :on-unfocus [
				unfocus-act: :unfocus-action
			]
			unfocus-action: make function! [face] [
				face/picked: face/text
				hide-popup
				face/action face
				unfocus-act face
			]
			color: colors/edit
			either auto-fill? [
				feel: make edit/feel bind [
					engage: func [face action event /local start end total visible fd ft pf prev-caret f] [
						switch action [
							key [
								if event/key = #"^M" [
									face/picked: face/text
;									edit-text face event
									hide-popup
									unfocus
									exit
								]
								if find [down up] event/key [
									unless system/view/pop-face [
										face/drop-down-picked: 0
										fd: copy []
										foreach ln sort face/data [
											insert tail fd ln
										]
										face/pane/action/filter-data face/pane fd
									]
									if f: system/view/pop-face [
										face/drop-down-picked: face/drop-down-picked + either event/key = 'down [1][-1]
										f/picked: reduce [face/drop-down-picked: min length? f/data max 1 face/drop-down-picked]
										f/scroll: either f/picked/1 > f/lines [
											- f/lines + f/picked/1
										][
											0
										]
										if (length? f/data) > f/lines [
											f/pane/2/data: f/scroll / ((length? f/data) - f/lines)
										]
										view*/caret: face/picked: face/text: copy pick f/data f/picked/1
										view*/caret: tail view*/caret
										show [f face]
									]
									exit
								]

								either all [auto-fill? auto-fill? <> 'filter-list][
									prev-caret: index? view*/caret
									face/picked: face/text: any [face/hidden-text head view*/caret]
									view*/caret: any [face/hidden-caret view*/caret]
									if view*/highlight-start [view*/highlight-start: at face/text index? view*/highlight-start]
									if view*/highlight-end [view*/highlight-end: at face/text index? view*/highlight-end]
									edit-text face event
									face/hidden-text: copy face/text
									face/hidden-caret: at face/hidden-text index? view*/caret
									fd: copy []
									ft: copy face/text
									foreach ln sort face/data [
										if find/match ln: translate ln face/text [
											face/picked: face/text: ln
											view*/caret: at face/text index? view*/caret
											if not char? event/key [
												view*/caret: at face/text prev-caret
												edit-text face event
												face/hidden-text: copy face/text
												face/hidden-caret: at face/hidden-text index? view*/caret
											]
										]
										if find/match ln ft [
											insert tail fd ln
										]
									]
								][
									fd: copy []
									edit-text face event
									foreach ln sort face/data [
										if find/match ln: translate ln face/text [
											insert tail fd ln
										]
									]

									either not empty? fd [
										either none? system/view/pop-face [
											face/drop-down-picked: 0
											face/pane/action/filter-data face/pane fd
										][
											pf: system/view/pop-face
											pf/data: copy fd
											pf/pane/1/size/y: pf/size/y: sizes/line * (length? fd)
											pf/lines: to integer! pf/size/y / sizes/line
											pf/rows: length? fd
											if droplist-mode = 'upward [
												pf/offset/y: face/offset/y - pf/size/y
											]
											remove find pf/opts 'over
											pf/redraw
										]
									][
										hide-popup
									]
								]

								show face

							]
							down [
								either event/double-click [
									all [view*/caret not empty? view*/caret current-word view*/caret]
								][
									either face <> view*/focal-face [focus face] [unlight-text]
									view*/caret: offset-to-caret face event/offset
									show face
								]
							]
							over [
								unless equal? view*/caret offset-to-caret face event/offset [
									unless view*/highlight-start [view*/highlight-start: view*/caret]
									view*/highlight-end: view*/caret: offset-to-caret face event/offset
									show face
								]
							]
						]
					]
				] in edit 'self
			][
				feel: make edit/feel []
			]
		][
			feel: make default-feel [
				engage: func [face action event][
					face/pane/feel/engage face/pane action event
				]
			]
		]
		feel/redraw: func [f a e][
			if a = 'show [
				f/pane/offset/x: f/size/x - f/pane/size/x - 3
			]
		]
	]
	;END fixed by Cyphre, sponsored by Robert

	reset-action: func [face] [
		face/text: copy ""
		if found? face/loc [face/loc/text: copy ""]
		face/picked-line: face/picked: none
		face/redraw
	]

	;START fixed by Henrik, sponsored by Robert
	state-action: make function! [word [word!] value /local p] [
		p: self
		switch word [
			data [p/data: :value]
			picked [p/set-picked/no-action index? any [find p/data :value []]]
		]
	]
	;END fixed by Henrik, sponsored by Robert

	;END fixed by Cyphre, sponsored by Robert
	init:	make function! [/local p] [
		unless block? data [gui-error "drop-list expected data block"]
		repeat i length? data [poke data i form pick data i]

		text: copy text ; preserve original string
		para: make para [] ; avoid shared para object for scrollable input widget

		check-editable

		p: self

		pane: make arrow [
			offset:	as-pair p/size/x - p/size/y + 1 1
			size:	as-pair p/size/y - 4 p/size/y - 4
			edge:	none
			action:	make function! [face /filter-data fd [block!] /local data p v lines-arg oft tmp lwidth tface poft wfac] [
;				unless system/view/pop-face [
					p: face/parent-face
					poft: win-offset? p
					wfac: find-window p
					data: either fd [
						fd
					][
						p/data
					]
					unless empty? data [
						;BEG fixed by Cyphre, sponsored by Robert
						either p/lines = 'auto [
							lines-arg: length? data
;							if (lines-arg * sizes/line + p/offset/y) > p/parent-face/size/y [
							if (lines-arg * sizes/line + poft/y) > wfac/size/y [
								lines-arg: none
;								if p/droplist-mode = 'auto [
;									p/droplist-mode: 'upward
;								]
							]
						][
							lines-arg: p/lines
							if all [
								p/droplist-mode = 'auto
;								(lines-arg * sizes/line + p/offset/y) > p/parent-face/size/y
								(lines-arg * sizes/line + poft/y) > wfac/size/y
							][
								p/droplist-mode: 'upward
							]

						]
						if p/droplist-mode = 'auto [
							p/droplist-mode: 'downward
						]
						switch p/droplist-mode [
							downward [
;								oft: p/offset + as-pair 0 p/size/y - 1
								oft: as-pair 0 p/size/y - 1
							]
							upward [
								lines-arg: any [lines-arg length? data]
								if all [
									p/lines = 'auto
;									(p/offset/y - (lines-arg * sizes/line)) < 0
									(poft/y - (lines-arg * sizes/line)) < 0
								][
									lines-arg: min lines-arg to-integer (either popup-mode = 'inside [
;										second ((win-offset? p) - (win-offset? p/parent-face))
										second poft - (win-offset? wfac)
									][
										second screen-offset? p
									]) / sizes/line
								]
;								oft: p/offset - as-pair 0 p/size/y * lines-arg - 1
								oft: 0x0 - as-pair 0 p/size/y * lines-arg - 1
							]
							middle [
								lines-arg: any [lines-arg length? data]
								if p/lines = 'auto [
;									lines-arg: min to-integer p/parent-face/size/y - 10 / sizes/line to-integer length? data
									lines-arg: min to-integer wfac/size/y - 10 / sizes/line to-integer length? data
								]
								tmp: sizes/line * lines-arg
;								oft: p/offset - as-pair 0 tmp / 2
								oft: negate as-pair 0 tmp / 2 - (p/size/y / 2)
;								oft/y: max 5 min p/parent-face/size/y - tmp - 5 oft/y
								oft/y: max negate poft/y min negate tmp - (wfac/size/y - poft/y) oft/y
							]
						]
						lwidth: p/size/x
						if p/resize-list? [
							tface: make face [size: 10000x10000 font: p/font]
							foreach i data [
								tface/text: translate i
								lwidth: max lwidth first size-text tface
							]
							if lines-arg < length? data [
								lwidth: lwidth + 18
							]
						]
						if v: do to-path compose [choose lines scroll-to (either p/popup-mode = 'inside [none][p/popup-mode])] p lwidth oft data lines-arg p/picked-line [
							p/picked: p/text: translate v
							p/picked-line: index? find p/data v
							p/action p
							show p
						]
						;END fixed by Cyphre, sponsored by Robert
					]
;				]
			]
		]
		pane/init	; draw arrow
		picked-init: picked: text
		picked-line: find data text
		picked-line-init: picked-line: all [picked-line index? picked-line]
	]
]
