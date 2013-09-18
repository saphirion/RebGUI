table: make rebface [
	size:	50x25
	pane:	[]
	; color mapping
	color:	colors/window
	pane-color: colors/widget
	header-color: colors/window
	header-over-color: colors/btn-up
	header-text-color: default-font/color
	header-height: none

	data:	[]
	edge:	default-edge
	;	widget facets
	redraw:	none
	selected: none
	picked:	[]
	picked-column: none
	columns: none
	init-widths: none
	widths:	[]
	aligns:	[]
	cols:	none
	;BEG fixed by Cyphre, sponsored by Robert
	tile: none
	total-width: none
	cols-to-display: none
	cols-offset: 0
	all-cols: 0
	pixel-width?: false
	col-filters: none
	hscr: vscr: none
	i-box: none
	t-box: none
	t-viewport: none
	arrow: none
	on-render-cell: none
	header-alt-action: none
	column-resize: true
	last-column-resize: false
	return-key: true
	key-navigation: true
	ttip: none
	cell-face: none
	cell-tooltip-act: none
	focus-action: func [face][
		if empty? face/picked [face/select-row 1]
		view*/focal-face: face/i-box/pane/1
		view*/caret: tail face/i-box/pane/1/text
		false
	]
	state-words: [
		data
		columns
		sort-id
		picked
		scroll [i-box/scroll]
		show?
	]
	non-num-sort-config: compose/deep [above-max [(false) (true)] under-min [(true) (false)]]
	tool-tip-main: none
	tool-tip-handler: [
		"" [
			use [ttm result][
				ttm: none
				result: true
				face/tool-tip/1: any [
					either function? :ttip [
						ttip cell-face cell-face/cell-coord
					][
						ttip
					]
					all [
						ttm: tool-tip-main
						tool-tip-main/1
					]
				]

				if all [
					ttm
					block? ttm/2
				][
					result:	do func [face tool-tip event] ttm/2 face tool-tip event
				]

				result
			]
		]
	]
	add-row: func [
		row [block!]
		/position
			pos [integer!]
	][
		pos: min 1 + length? data max 1 either pos [
			pos * all-cols + 1 - all-cols
		][
			1 + length? data
		]
		insert at data pos row
		redraw

		; return new row number
		(pos - 1) / all-cols + 1
	]

	remove-row: func [
		row [integer! block!]
		/local rows removed
	][
		if integer? row [row: to-block row]
		rows: sort/reverse copy row
		repeat n length? rows [
			row: max 1 min rows/:n (length? data) / all-cols
			remove/part skip data (row - 1) * all-cols all-cols
		]
		redraw
	]

	alter-row: func [
		row [integer! block!]
		values [block!]
		/local rows last-picked
	][
		last-picked: copy picked
		if integer? row [row: to-block row]
		rows: row
		if (length? rows) <> (length? values) [
			values: reduce [values]
		]
		if (length? rows) = (length? values) [
			repeat n length? rows [
				row: max 1 min rows/:n (length? data) / all-cols
				change skip data (row - 1) * all-cols copy/part values/:n all-cols
			]
		]
		redraw
		if not empty? last-picked [
			select-row last-picked
		]
	]

	select-row: func [
		row [integer! block! none!]
		/multi
		/no-action
		/no-show
		/local
			act? rows lines
	][
		act?: all [
			not no-action
			function? :action
		]
		if any [none? row all [block? row empty? row]] [
			clear picked
			show self
			all [act? action self]
			exit
		]
		if integer? row [row: to-block row]
		row: sort copy row
		rows: i-box/rows
		lines: i-box/lines
		unless multi [clear picked]
		foreach r row [
			r: max 1 min rows r
			insert tail picked r
		]
		if rows <> lines [
			if any [
				row/1 < (i-box/scroll + 1)
				row/1 > (i-box/scroll + i-box/lines)
			][
				i-box/vscr/data: 1 / (rows - lines) * ((min (rows - lines + 1) row/1) - 1)
			]
		]
		all [act? action self]
		unless no-show [
			show self
		]
	]

	go-to: func [
		row [integer!]
		/local
			rows lines
	][
		rows: i-box/rows
		lines: i-box/lines
		if rows > lines [
			if any [row <= i-box/scroll row > (i-box/scroll + lines)][
				i-box/scroll: min rows - lines max 0 row - 1
				i-box/vscr/data: i-box/scroll / (rows - lines)
				show self
			]
		]
	]

	scroll-to: func [
		val [decimal!]
		/horizontally
	][
		val: max 0 min 1 val
		either horizontally [
			if hscr/show? [
				hscr/data: val
				show self
			]
		][
			if i-box/rows > i-box/lines [
				i-box/scroll: round i-box/rows - i-box/lines * val
				i-box/vscr/data: val
				show self
			]
		]
	]
	
	sort-column: func [
		col [integer! none!]
		/update
		/dir
			way [word!]
	][
		unless arrow/col: col [arrow/offset/y: -100 redraw exit]
		if arrow/fac: pick t-box/pane col * 2 [
			arrow/num-sort?: arrow/fac/num-sort
			if dir [arrow/asc: way = 'down]
			if update [arrow/asc: not arrow/asc]
			arrow/action arrow
		]
	]

	get-label-faces: has [
		result
	][
		result: copy []
		foreach f t-box/pane [
			if get in f 'col [insert tail result f]
		]
		result
	]

	set-action: func [
		action-func [function!]
	][
		i-box/action: action: :action-func
	]

	set-columns: func [
		options [block!]
		/no-show
		/from-widget
		/local col-offset p last-col w idx psize dl mark col-filter? dl-color num-sort? non-num ttip val r tot-width column-title ps
	] [
		if empty? options [exit]

		p: self
		p/columns: copy options
		psize: idx: w: 0
		;parse options []
		unless from-widget [
;			cols-to-display: none
			col-filters: none
		]
		pixel-width: 'unset

		p/header-height: sizes/line

		parse options [
			some [
				[string! | block!]
				opt ['tool-tip opt [string! | block!]]
				set halign word!
				set width number! (if pixel-width = 'unset [pixel-width?: integer? width])
				opt ['filter (col-filter?: true)]
				opt ['num-sort opt ['under-min | 'above-max | 'always-top | 'always-bottom]] (
					if any [
						all [pixel-width? decimal? width]
						all [not pixel-width? integer? width]
					][
						gui-error "Cannot mix pixel and weighted column widths. Use integer! or decimal! values only."
					]
					idx: idx + 1
					w: w + width
					either pixel-width? [
						psize: psize + width
					][
						all [cols-to-display idx <= cols-to-display psize: psize + width]
					]
				)
			]
		]

		if all [not col-filters col-filter?] [
			col-filters: array idx
		]

		either pixel-width? [
			tile: psize / 100
 		][
			if psize = 0 [psize: 1]
			tile: p/size/x / psize * w / (w * 100)
		]
		all-cols: idx;(length? options) / 3

		if (length? t-box/pane) > 2 [
			remove/part next t-box/pane 2 * cols - 1
		]

		clear widths
		clear aligns

		idx: w: 0

		parse options [
			some [
				set column [string! | block!] opt ['tool-tip opt [string! | block!]] set halign word! set width number! opt 'filter opt ['num-sort opt ['under-min | 'above-max | 'always-top | 'always-bottom]] mark: (
					idx: idx + 1
					either pixel-width? [
						w: w + width
					][
						w: w + (width * 100 * tile)
					]
					if w >= p/size/x [
						mark: tail mark
					]
				) :mark
			]
		]

		cols: all-cols

		p/i-box/cols: all-cols
		p/i-box/visible-cols: cols
		p/i-box/cols-offset: cols-offset
		unless from-widget [p/i-box/data: p/data]

		col-offset: tot-width: 0

		col-filter?: false
		parse options [
			some [
				 (non-num: 'above-max column: column-title: none)
				[set column-title string! | set column block!] opt ['tool-tip (ttip: true) opt [set val [string! | block!] (ttip: val)]] set halign word! set width number! opt ['filter (col-filter?: true)] 
				opt ['num-sort (num-sort?: true) opt ['under-min (non-num: 'under-min) | 'above-max (non-num: 'above-max) | 'always-top (non-num: 'always-top) | 'always-bottom (non-num: 'always-bottom)]]
;				opt ['num-sort (num-sort?: true)] 
				mark: (
					either cols <= length? widths [
						mark: tail mark
					][

;					unless any [string? column word? column] [
;						gui-error "Table expected column name to be a string or word"
;					]
					unless find [left center right] halign [
						gui-error "Table expected column align to be one of left, center or right"
					]

					insert tail aligns halign
					unless pixel-width? [width: to integer! tile * width * 100]

					if (cols - 1) = (length? widths) [width: width - 1]
					insert tail widths width
					tot-width: tot-width + width
					insert back tail t-box/pane make rebface [
						text: translate column-title
						tool-tip: all [ttip either logic? ttip [text][ttip]]
						offset:	as-pair col-offset 0
						size:	as-pair width - either column-resize [sizes/cell][1] sizes/line
						col:	length? widths
						num-sort: num-sort?
						non-num-sort: non-num
						color: header-color
						;BEG fixed by Cyphre, sponsored by Robert
						font: make default-font [align: aligns/:col color: header-text-color]
						;END fixed by Cyphre, sponsored by Robert
						pane: either col-filter? [
							reduce [
								dl: make ctx-rebgui/widgets/drop-list [
									size: 12x12
									offset: as-pair width - 16 sizes/line - 12
									_action: none
								]
							]
						][
							either column [
								layout/only/origin column 0x0
							][
								none
							]
						]
						all [
							pane
							column
							ps: second span? reduce [pane]
							p/header-height: max p/header-height ps/y
							pane/offset/x: switch halign [
								left [0]
								center [size/x / 2 - (ps/x / 2)]
								right [size/x - ps/x]
							]

							append pane/pane make face [
								color: edge: effect: none
								size: ps
								offset: 0x0;(pane/offset)
								feel: make default-feel [
									last-face: none
									engage: make function! [f a e /local pf fac][
										pf: f/parent-face
										all [
											fac: find-face ctx-rebgui/mouse-offset pf ctx-rebgui/widget-names
											any [
												all [
													fac/feel
													in fac/feel 'engage
												]
												fac: pf/parent-face
											]
											fac/feel/engage fac e/type e
										]
									]
									redraw: none
									over: make function! [f a o /local pf] [
										pf: f/parent-face/parent-face
										pf/feel/over pf a o
									]
									detect: make function! [f e /local pf fac][
										pf: f/parent-face/pane
										all [
											fac: find-face e/offset pf ctx-rebgui/widget-names
											fac/feel
											in fac/feel 'detect
											fac/feel/detect fac e
										]
										if last-face <> fac [
											all [
												f: any [fac  last-face]
												f/feel
												f/feel/over f f = fac e/offset
											]
										]
										last-face: fac
										e
									]
								]
							]
							pane/effect: 'merge
							pane/color: none
						]
						feel:	make default-feel [
							over: make function! [face act pos] [
								if any [empty? p/data find p/i-box/opts 'disable-sort] [exit]
								face/color: either act [header-over-color] [header-color]
								p/ttip: either act [get in face 'tool-tip][none]
								show face
							]
							engage: make function! [face act event] [
								switch act [
									down [
										if empty? p/data [exit]
										unless arrow/col = col [
											arrow/col: col
											arrow/asc: none
											arrow/fac: face
										]
										arrow/num-sort?: num-sort
										arrow/non-num-sort-mode: non-num-sort
										arrow/action arrow
									]
								]
							]
							move-pos: none
							detect: func [f e][
								if any [
									e/type = 'alt-down
									all [ e/type = 'move ctx-rebgui/menu-open? e/offset <> move-pos] ;workaround for the Windows event glitch when right-clicking on inacive window
								][
									move-pos: e/offset
									all [
										function? get in p 'header-alt-action
										p/header-alt-action p col
									]
								]
								e
							]
						]
						if col-filter? [
							col-filter?: false
							dl/resize-list?: true
							dl/lines: 8
							dl/font: make dl/font [color: dl/color]
							dl/init
							if pick col-filters col + cols-offset [
								dl/pane/btn-colors/2: 255.128.128
							]
							dl/_action: get in dl/pane 'action
							dl/pane/action: make function! [
								face
								/filter-data
									fd [block!]
								/local
							][
								face/parent-face/set-data join ["All rows"] p/get-unique-col-data face/parent-face/parent-face/col + p/cols-offset
								either fd [
									face/parent-face/_action/filter-data face fd
								][
									face/parent-face/_action face
								]
							]
							dl/action: make function! [
								face
							][
								poke p/col-filters face/parent-face/col + p/cols-offset either face/picked-line = 1 [
									face/pane/btn-colors/2: colors/btn-up
									none
								][
									face/pane/btn-colors/2: 255.128.128
									 face/picked
								]
								p/redraw
							]
						]

					]
					ttip: none
					num-sort?: false
					col-offset: col-offset + width
					;	resize dragger
					if cols > length? widths [
						either column-resize [
							insert back tail t-box/pane make rebface [
								span: #H
								offset:	as-pair col-offset - sizes/cell 0
								;BEG fixed by Cyphre, sponsored by Robert
								size:	as-pair sizes/cell p/size/y
								;END fixed by Cyphre, sponsored by Robert
								color:	gray
								col-1:	length? widths
								col-2:	1 + length? widths
								feel:	make default-feel [
									over: make function! [face act pos] [
										color: either act [gold] [gray]
										show face
									]
									engage: make function! [face act event /local delta r] [
										switch/default act [
											down	[data: event/offset/x]
											up		[data: none feel/over face false 0x0]
											alt-up	[data: none feel/over face false 0x0]
										][
											if all [
												data
												event/type = 'move
												event/offset/x <> data
											] [
												delta: event/offset/x - data
												delta: either positive? delta [
													min delta t-box/pane/(col-2 * 2)/size/x - (sizes/line * 2)
												][
													max delta negate t-box/pane/(col-1 * 2)/size/x - (sizes/line * 2)
												]
												unless zero? delta [
													if any [
														all [
															arrow/col = col-1
															aligns/:col-1 = 'right
														]
														all [
															arrow/col = col-2
															aligns/:col-1 = 'left
														]
													][
														arrow/offset/x: arrow/offset/x + delta
													]
													;	move dragger bar
													offset/x: offset/x + delta
													if arrow/col = col-1 [
														arrow/offset/x: offset/x - either aligns/:col-1 = 'right [
															arrow/fac/size/x + delta
														][
															12
														]
													]
													if arrow/col = col-2 [
;														arrow/offset/x: max arrow/offset/x offset/x + sizes/cell
														arrow/offset/x: offset/x + either aligns/:col-2 = 'right [
															sizes/cell
														][
															arrow/fac/size/x - 8 - delta
														]
													]

													;	adjust column widths
													widths/:col-1: widths/:col-1 + delta
													widths/:col-2: widths/:col-2 - delta

													;	adjust heading widths and offset
													t-box/pane/(col-1 * 2)/size/x: widths/:col-1 - sizes/cell
													t-box/pane/(col-2 * 2)/offset/x: offset/x + sizes/cell

													either cols = col-2 [
														t-box/pane/(col-2 * 2)/size/x: t-box/size/x - t-box/pane/(col-2 * 2)/offset/x - either all [vscr vscr/show?] [sizes/slider][0]
													][
														t-box/pane/(col-2 * 2)/size/x: widths/:col-2 - sizes/cell
													]
													unless last-column-resize [
														r: t-box/size/x / any [all [t-box/init-size t-box/init-size/x] t-box/size/x]
														forall init-widths [
															init-widths/1: to-integer (pick widths index? init-widths) / r
														]
													]
													;	show changes
													show parent-face
												]
											]
										]
									]
								]
							]
						][
							insert back tail t-box/pane make rebface [
								span: #H
								offset:	as-pair col-offset - 1 0
								size:	as-pair 1 p/size/y
								color:	colors/edge
							]
						]
					]
			]
				) :mark
			]
		]

		;update total-width only once
		unless total-width [
			total-width: tot-width
		]

		;	reassign options
		p/options: i-box/opts

		;	update widths to cover case when the table was resized
		if all [not pixel-width? total-width <= size/x 1 <> r: t-box/size/x / any [all [t-box/init-size t-box/init-size/x] t-box/size/x]][
			forall widths [
				widths/1: to-integer (widths/1 / r)
			]
		]

		unless last-column-resize [init-widths: copy widths]

		; update arrow
		arrow/cols: all-cols

		;update table sizes
		update-sizes

		;	init iterator *after* we know align
		i-box/init

		; update hscroller
		hscr/opts: p/columns
		unless no-show [
			show self
		]
	]
	num-cs: complement charset [
		#"0" - #"9"	; numbers
		#"," 		; MUST be the decimal point separator only
		#"-"		; negative sign
		#"E"		; exponent
	]
	sort-id: none
	sort-fn: func [
		a [string!] b [string!]
		/local oa ob fa fb ea eb
	][
		a: form oa: pick a sort-id
		b: form ob: pick b sort-id

		if error? try [
			fa: to decimal! a
		][
			replace/all a num-cs ""
		]

		if error? try [
			fb: to decimal! b
		][
			replace/all b num-cs ""
		]

		ea: error? try [
			fa: to decimal! a
		]
		eb: error? try [
			fb: to decimal! b
		]

		either any [
			ea eb
		][
			either ea [
				either eb [
					either error? try [
						oa > ob
					][
						0
					][
						either oa = ob [
							0
						][
							oa > ob
						]
					]
				][
					first non-num-sort
				]
			][
				second non-num-sort
			]
		][
			either fa = fb [
				0
			][
				fa < fb
			]
		]
	]

	update-sizes: has [last-col w id r s] [
		w: 0
		id: 2
		s: either column-resize [
			4
		][
			1
		]

		;"last coulmn" resize mode
		if last-column-resize [
			forall widths [
				t-box/pane/:id/size/y: header-height
				t-box/pane/:id/offset/x: w
				either empty? next widths [
					if all [
						(size/x - w) > 20
						size/x > w
					][
						widths/1: size/x - w - either all [i-box/rows i-box/lines i-box/rows > i-box/lines][sizes/slider][0]
						total-width: w + widths/1
					]
					t-box/pane/:id/size/x: widths/1 - 2
					w: w + widths/1
				][
					t-box/pane/:id/size/x: widths/1 - s
					w: w + widths/1
					t-box/pane/(id + 1)/offset/x: w - s
				]
				id: id + 2
			]
			if w > size/x [total-width: w]
		]

		;table
		i-box/offset/y: header-height
		either total-width <= size/x [
			t-box/size: as-pair size/x size/y
			i-box/size: as-pair size/x size/y - header-height
			t-box/offset/x: 0
		][
			t-box/size: as-pair total-width size/y - sizes/slider - 1
			i-box/size: as-pair total-width size/y - sizes/slider - header-height
		]

		t-viewport/size/y: t-box/size/y

		all [
			i-box/pane/1
			i-box/pane/1/size: i-box/size
		]

		;hscroller
		all [
			i-box/rows
			i-box/lines
			i-box/lines: to integer! i-box/size/y / sizes/line
			hscr/size/x: size/x - either i-box/rows > i-box/lines [sizes/slider - 1][0]
		]
		hscr/show?:	either size/x < t-box/size/x [true][false]
		hscr/ratio: size/x / t-box/size/x
		hscr/init

		;vscroller
		if all [i-box/vscr any [not vscr i-box/vscr <> vscr ]][
			all [vscr remove find pane vscr]
			insert tail pane vscr: i-box/vscr
			remove next i-box/pane
			all [vscr/parent-face show vscr/parent-face]
		]
		all [
			vscr
			vscr/offset: as-pair size/x - sizes/slider - 1 header-height
			vscr/size/y: i-box/size/y - either hscr/show? [0][1]
			vscr/ratio: either zero? i-box/rows [1] [i-box/lines / i-box/rows]
			vscr/show?: i-box/rows > i-box/lines
		]

		t-viewport/size/x: size/x - either all [vscr vscr/show?][sizes/slider + 1][0]

		;"proportional columns" resize mode
		unless last-column-resize [
			r: t-box/size/x / any [all [t-box/init-size t-box/init-size/x] t-box/size/x]
			forall widths [
				t-box/pane/:id/size/y: header-height
				t-box/pane/:id/offset/x: w
				either empty? next widths [
					widths/1: t-box/size/x - w - either all [vscr vscr/show?][16][0]
					t-box/pane/:id/size/x: widths/1 - 2
				][
					w: w + widths/1: to-integer (r * pick init-widths index? widths)
					t-box/pane/:id/size/x: widths/1 - s
					t-box/pane/(id + 1)/offset/x: w - s
				]
				id: id + 2
			]
		]

		either empty? data [
			arrow/offset/y: -100
			arrow/col: none
		][
			if arrow/col [
				arrow/offset/x: either (pick aligns arrow/col) = 'right [
					arrow/fac/offset/x
				][
					arrow/fac/offset/x + arrow/fac/size/x - (sizes/cell * 3)
				]
				arrow/offset/y: -2
			]
		]
	]

	get-unique-col-data: make function! [
		col-id [integer!]
		/local a result
	][
		result: copy []
		a: array all-cols
		repeat n all-cols [
			poke a n to-word join "col-" n
		]
		foreach :a data compose [
			insert tail result form (pick a col-id)
		]
		return unique result
	]

	filter-cols: make function! [
		data [block!]
		col-filters [block! none!]
		/local result fw fc
	][
		result: copy []
		unless col-filters [return data]
		while [not tail? col-filters][
			if fw: col-filters/1 [
				fc: index? col-filters
				clear result
				while [not tail? data][
					if fw = form pick data fc [
						insert tail result copy/part data all-cols
					]
					data: skip data all-cols
				]
				data: copy result ;head data
			]
			col-filters: next col-filters
		]
		col-filters: head col-filters
		return any [all [empty? result data] result]
	]

	;START fixed by Henrik, sponsored by Robert
	state-action: make function! [word [word!] value /local p] [
		p: self
		switch/default word [
			columns [p/set-columns :value] ; causes a redraw
			picked [p/select-row/no-action :value]
			sort-id [p/sort-column/update p/sort-id: :value]
			scroll [p/go-to :value + 1]
		][
			either series? :value [insert clear get word :value][set word :value]
		]
	]
	;END fixed by Henrik, sponsored by Robert

	;END fixed by Cyphre, sponsored by Robert
	init:	make function! [/local p opts tmp] [
		tool-tip-main: tool-tip
		tool-tip: tool-tip-handler
		;	default options
		opts: [table]
		if all [not empty? options 'multi = first options] [remove options insert tail opts 'multi]
		if tmp: find options 'disable-sort [remove tmp insert tail opts 'disable-sort]
		if tmp: find options 'columns-to-display [cols-to-display: tmp/2 remove/part tmp 2]
		if tmp: find options 'on-render-cell [on-render-cell: func [face pos] any [all [word? tmp/2 get tmp/2] tmp/2] remove/part tmp 2]
		if tmp: find options 'header-alt-action [header-alt-action: func [face column] any [all [word? tmp/2 get tmp/2] tmp/2] remove/part tmp 2]
		if tmp: find options 'cell-tooltip-action [cell-tooltip-act: func [face pos] any [all [word? tmp/2 get tmp/2] tmp/2] remove/part tmp 2]
		if tmp: find options 'no-column-resize [column-resize: false remove tmp]
		if tmp: find options 'no-key-navigation [key-navigation: false remove tmp]
		if tmp: find options 'no-return-key [return-key: false remove tmp]
		if tmp: find options 'resize-last-column-only [last-column-resize: true remove tmp]
;		if tmp: find options 'width [twidth: tmp/2 remove/part tmp 2]
		tmp: copy options
		;	basic options and data validation
		cols: 0
		if all [not empty? options not parse options [
			some [
				[string! | block!] opt ['tool-tip opt string!] word! number! opt 'filter (cols: cols + 1) opt ['num-sort opt ['under-min | 'above-max | 'always-top | 'always-bottom]]
			]
		]][
			gui-error rejoin ["Table '" to-lit-word get in bound? first second get in ctx-rebgui 'layout 'word " has an invalid options block: " newline mold options]
		]

		if all [cols > 0 not empty? data decimal? divide length? data cols] [
			gui-error "Table has an invalid data block"
		]

		p: self
		vscr: none
		insert tail pane t-viewport: make rebface [
		]

		t-viewport/pane: t-box: make rebface [
			size: p/size
			pane: copy []
;			edge: make edge [color: red]
			span: either p/span [copy p/span] [none]
		]

		;	face iterator

		insert tail t-box/pane i-box: make face-iterator compose/only [
			root: p
			size:		p/size - as-pair 0 sizes/line + sizes/slider ;either cols-to-display [sizes/slider][0]
			color:		pane-color
			span:		either p/span [copy p/span] [none]
			data:		p/data
			cols:		p/cols
			widths:		p/widths				; share widths
			aligns:		p/aligns				; share aligns
			opts:	(opts)
			picked:		p/picked				; share picked block
			action:		get in p 'action		; share action func
			alt-action:	get in p 'alt-action	; share alt-action func
			dbl-action:	get in p 'dbl-action	; share dbl-action func
		]

		;BEG fixed by Cyphre, sponsored by Robert
		;	arrow
		insert tail t-box/pane arrow: make rebface [
			offset:	as-pair negate sizes/line sizes/cell
			size:	as-pair sizes/cell * 3 sizes/cell * 3
			fx:	[arrow black rotate 0]
			cols:	p/cols
			col:	none
			asc:	true
			num-sort?: false
			non-num-sort-mode: none
			non-num-sort: none
			fac: none
			feel:	make default-feel [
				engage: make function! [face act event] [
					if act = 'down [face/action face]
				]
			]
			action:	make function! [face /local last-selected oft row c] [
				if empty? p/data [exit]
				oft: 0
				if aligns/:col = 'center [
					oft: fac/size/x / 2  - ((first size-text fac) / 2)
				]
				either find p/i-box/opts 'disable-sort [face/effect: none exit][face/effect: either fac/size/x < ((first size-text fac) + size/x + oft) [rejoin [fx 'alphamul 200]][fx]]
				asc: either none? asc [true] [complement asc]
				effect/rotate: either asc [0] [180]
				;BEG fixed by Cyphre, sponsored by Robert
				last-selected: selected
				;END fixed by Cyphre, sponsored by Robert

				sort-id: col + p/cols-offset

				either asc [
					either num-sort? [
						bind second :sort-fn face
						non-num-sort: either find [always-top always-bottom] non-num-sort-mode [
							select non-num-sort-config select [always-top under-min always-bottom above-max] non-num-sort-mode
						][
							select non-num-sort-config non-num-sort-mode
						]
						sort/skip/compare/all i-box/data p/all-cols :sort-fn
					][
						sort/skip/compare i-box/data p/all-cols sort-id
					]
				][
					either num-sort? [
						bind second :sort-fn face
						non-num-sort: either find [always-top always-bottom] non-num-sort-mode [
							select non-num-sort-config select [always-top above-max always-bottom under-min] non-num-sort-mode
						][
							select non-num-sort-config non-num-sort-mode
						]
						sort/skip/compare/all/reverse i-box/data p/all-cols :sort-fn
					][
						sort/skip/compare/reverse i-box/data p/all-cols sort-id
					]
				]

				; track index changes to create new list of picked
				;BEG fixed by Cyphre, sponsored by Robert
				if last-selected [
					clear p/picked
					last-selected: tail last-selected
					c: negate p/cols
					until [
						last-selected: skip last-selected c
						if row: find i-box/data copy/part last-selected p/cols [
							select-row/no-action/no-show/multi to-integer (((index? row) - 1) / p/cols) + 1
						]
						head? last-selected
					]
					;turn the order correctly back
					reverse p/picked
				]
				view*/focal-face: i-box/pane/1

				;END fixed by Cyphre, sponsored by Robert
				show p	;t-box	;parent-face
			]
		]

		;horizontal scroller
		insert tail pane hscr: make slider [
			offset:	as-pair -1 p/size/y - sizes/slider - 1
			size: as-pair p/size/x sizes/slider
			options: [arrows]
			span: #WY
			opts: tmp
;			show?:	either p/cols-to-display [true] [false]
			action:	make function! [face /local oft] [
				oft: face/data * negate (t-box/size/x - t-viewport/size/x)
				if oft <> t-box/offset/x [
;					print "scroll H"
					t-box/offset/x: oft
					t-box/changes: 'offset
					show t-box
				]
			]
			ratio: 1 ;either cols-to-display [p/cols-to-display / ((length? tmp) / 3)] [1]
		]

		;	column headings
		set-columns/no-show/from-widget options

		;END fixed by Cyphre, sponsored by Robert
		;	accessors
		;BEG fixed by Cyphre, sponsored by Robert
		redraw: does [
			if arrow/col [
				sort-id: arrow/col
				either arrow/asc [
					either arrow/num-sort? [
						sort/skip/compare/all i-box/data arrow/cols :sort-fn
					][
						sort/skip/compare i-box/data arrow/cols sort-id
					]
				][
					either arrow/num-sort? [
						sort/skip/compare/all/reverse i-box/data arrow/cols :sort-fn
					][
						sort/skip/compare/reverse i-box/data arrow/cols sort-id
					]
				]
			]
			if any [col-filters not same? data i-box/data][
				i-box/data: filter-cols data col-filters
			]

;			i-box/resize
			i-box/redraw/no-show
			update-sizes
			show t-viewport
			if all [vscr vscr/show?] [show vscr]
		]
		;END fixed by Cyphre, sponsored by Robert
		selected: get in i-box 'selected
		;	feel
		feel: make default-feel [
			redraw: make function! [face act pos /local total] [
				if act = 'show [
					if cols = 0 [exit]
comment {
					;	is arrow on last col
					if arrow/col = cols [
						arrow/offset/x: either (pick aligns arrow/col) = 'right [
							total-width - (last widths)
						][
							size/x + sizes/cell - sizes/line
						]
					]
}
					i-box/redraw/no-show
					update-sizes
				]
			]
		]
	]
]
