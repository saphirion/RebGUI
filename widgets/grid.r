;version: 0.0.22
;by Cyphre <cyphre@seznam.cz>
grid: make rebface [
	size: -1x25
	text: ""

	scroll: row-lay: row-size: rows: none
	columns: 0
	hilite-cell: hilite-row: hslider: vslider: none
	header-height: 20
	sorted-by: none
	header-col: header-box: grid-box: none
	row-spec: none
	row-index: none
	col-index: none
	root-face: none
	header?: false
	visible-columns: none
	visible-rows: none
	picked: none

	gb-update?: false
	
	hilite-cell?: true
	hilite-row?: true
	hilite-follow?: true

	double-click-up?: false

	content: none

	column-actions: none
	action-result: none

	sort-columns?: true
	
	on-key: [
		up [
			use [tmp rn][
				if hilite-row? [
					rn: f/picked/row-number
					while [
						tmp: back find f/row-index rn
						all [
							not find f/visible-rows first tmp
							not head? tmp
						]
					][
						rn: first tmp
					]
					if find f/visible-rows first tmp [
						f/picked/row-number: first tmp
					]

					tmp: f/get-row-index

					if (tmp - f/scroll) = 0 [
						f/scroll: f/scroll - 1
						f/update-content
					]

					if f/scroll-to tmp [
						f/update-content
					]

					f/update-sliders
					f/update-hilite
				]
			]
		]
		down [
			use [tmp rn][
				if hilite-row? [
					rn: f/picked/row-number
					while [
						all [
							tmp: find f/row-index rn
							not tail? tmp: next tmp
							not find f/visible-rows first tmp
						]
					][
						rn: first tmp
					]
					if all [tmp not tail? tmp] [
						f/picked/row-number: first tmp
					]

					tmp: f/get-row-index

					if (tmp - f/scroll) > (f/rows - 1) [
						f/scroll: f/scroll + 1
						f/update-content
					]

					if f/scroll-to tmp [
						f/update-content
					]

					f/update-sliders
					f/update-hilite
				]
			]
		]
		left [
			use [tmp cn][
				cn: f/picked/column-number
				while [
					tmp: back find f/col-index cn
					all [
						not find f/visible-columns first tmp
						not head? tmp
					]
				][
					cn: first tmp
				]
				if find f/visible-columns first tmp [
					f/picked/column-number: first tmp
				]
			]
			f/update-hilite
			if 	f/scroll-to f/get-row-index [
				f/update-content
			]

			f/update-sliders
		]
		right [
			use [tmp cn][
				cn: f/picked/column-number
				while [
					all [
						not tail? tmp: next find f/col-index cn
						not find f/visible-columns first tmp
					]
				][
					cn: first tmp
				]
				if not tail? tmp [
					f/picked/column-number: first tmp
				]
				f/update-hilite
				if f/scroll-to f/get-row-index [
					f/update-content
				]

				f/update-sliders
			]
		]
		#"^M" [
			use [fac res][
				fac: pick f/grid-box/pane f/get-row-index - 1 - f/scroll * f/columns + (index? find f/col-index f/picked/column-number)
				if all [
					function? get in f 'action
					set/any 'res f/action fac
					value? 'res
				][
					pass-event fac make object! [
						type: 'down
						key: e/key
						offset: e/offset
						time: e/time
						shift: e/shift
						control: e/control
						face: e/face
						double-click: e/double-click
					]
					pass-event fac make object! [
						type: 'up
						key: e/key
						offset: e/offset
						time: e/time
						shift: e/shift
						control: e/control
						face: e/face
						double-click: e/double-click
					]
				]
			]
		]
	]

	get-row-index: has [idx][
		idx: 0
		foreach i row-index [
			if all [
				find visible-rows i
				idx: idx + 1
				i = picked/row-number
			][
				return idx
			]
		]
		0
	]

	get-row-by-index: func [
		index [integer!]
		/local idx
	][
		idx: 0
		foreach i row-index [
			if all [
				find visible-rows i
				idx: idx + 1
				idx = index
			][
				return i
			]
		]
		0
	]

	on-resize: func [
		/local scr f ln drows
	][
		grid-box/size/x: (max grid-box/ini-size/x root-face/size/x) - (either grid-box/ini-size/x < root-face/size/x [16][0])
		update-grid
		grid-box/size/y: second second span? grid-box/pane
;		if header? [header-box/size/x: grid-box/size/x]
		if header? [
			header-box/size/x: any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]
			unless empty? grid-box/pane [
				repeat n length? header-box/pane [
					header-box/pane/:n/offset: as-pair any [all [grid-box/size/x > 0 grid-box/pane/:n/offset/x] 0] 0
					header-box/pane/:n/size: as-pair any [all [grid-box/size/x > 0 grid-box/pane/:n/size/x] 10] 20
				]
			]
		]

		scr: 0
		vslider/show?: either (ln: length? visible-rows) > rows [scr: 16 true][scroll: 0 true]
;		vslider/ratio: either ln <= rows [1][max .1 rows / ln]
		drows: to-integer root-face/size/y - (either header? [header-box/size/y][0]) / max 1 row-size/y
		vslider/ratio: either ln <= drows [1][max .1 drows / ln]
;		hslider/show?: either row-size/x > (root-face/size/x - 2 - scr) [
		hslider/show?: either row-size/x > (root-face/size/x - scr) [
			hslider/size/x: root-face/size/x - scr + 1
			true
		][
			grid-box/offset/x: 0
;			grid-box/size/x: root-face/size/x - 2 - scr
			if header? [
				header-box/offset/x: -1
;				header-box/size/x: grid-box/size/x
				header-box/size/x: any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]
			]

			repeat n rows [
				f: pick grid-box/pane n * columns
				all [f f/size/x: grid-box/size/x - f/offset/x]
			]
			false
		]

		if all [header? not empty? header-box/pane][
			f: last header-box/pane
			f/size/x: 1 + header-box/size/x - f/offset/x
		]
		all [picked/row-number picked/row-number: max scroll min picked/row-number scroll + rows]
;		print "UC resize"
		update-content
		update-visibility
	]

	parse-row-spec: func [
		row-spec-blk [block!]
		/local var
	][
		row-spec: copy []
		column-actions: make hash! []
		parse row-spec-blk [
			some [
				set var block! (insert/only tail row-spec var insert tail column-actions none)
				| 'with set var block! (change/only back tail column-actions var)
			]
		]
	]

	build-row: func [
		row-blk [block!]
		/local lay-blk idx
	][
		lay-blk: copy [margin 0x0 space 0x0]
		foreach c col-index [
			insert tail lay-blk row-blk/:c
		]
		row-lay: get in ctx-rebgui/layout lay-blk 'pane
		columns: length? row-lay
		row-size: second span? row-lay
	]

	build-header: func [
		header [block!]
		/local x tmp
	][
		x: 0
		clear header-box/pane
		repeat n columns [
				insert tail header-box/pane tmp: make header-col [
;					para: make face/para [origin: 2x2]
					text: pick header col-index/:n
					data: col-index/:n
					old-y: none
					offset: as-pair x - either x = 0 [0][n - 1] 0
					size: as-pair either n = columns [header-box/size/x - x + 3][any [all [not empty? grid-box/pane grid-box/pane/:n/size/x] all [not empty? row-lay row-lay/:n/size/x] 0]] header-height
					tr: 1x0 * (first size - 10) + 0x1
				]
				x: x + tmp/size/x
		]
	]

	update-grid: func [
		/local y p scr
	][
			p: self
			y: 0
			rows: 0
			scr: 0

			clear grid-box/pane

			if row-size/x > size/x [
				scr: 16
			]
			while [
				all [
					rows < (length? any [p/visible-rows p/content])
;					y + (row-size/y / 2) < (size/y - grid-box/offset/y - scr)
					y < (size/y - grid-box/offset/y - scr)
				]
			][
				rows: rows + 1
				repeat n columns [
					insert tail grid-box/pane make row-lay/:n [
						font: make font []
						para: make para []
						pane: any [
							all [object? pane make pane []]
							all [block? pane forall pane [pane/1: make pane/1 []] pane]
						]
						cspan: span
						span: none
						offset/y: y
						ini-offset: offset
						ini-size: size
						cell-index: none
						content-index: none
						cell-data: none
						old-y: none
						options: either block? options [
							head insert tail options 'grid-item
						][
							copy [grid-item]
						]
					]
				]

				y: y + row-size/y
			]
			gb-update?: true
	]

	update-content: func [
		/no-show
		/local scr r c dc ic visible-column? vr
	][
		if empty? content [exit]
		scr: scroll
		if scr > 0 [
			scr: index? find row-index get-row-by-index scr
		]
		r: scr + 1
		c: 1
		vr: 1
		foreach cell grid-box/pane [
			cell/text: copy ""
			while [not find visible-rows row-index/:r][
				r: r + 1
				if r > (length? content) [break]
			]

			if cell/show?: not r > (length? content) [
				dc: pick content row-index/:r
				ic: col-index/:c
				visible-column?: find visible-columns ic
				cell/cell-index: as-pair c vr
				cell/content-index: as-pair ic r
				if dc [
					either block? dc/:ic [
						do bind cell/cell-data: dc/:ic in cell 'self
					][
						if dc/:ic [
							cell/text: dc/:ic
						]
					]
				]
				if all [
					visible-column?
					column-actions/:ic
				][
					do bind column-actions/:ic in cell 'self
				]
			]
			c: c + 1
			if c > columns [
				c: 1
				r: r + 1
				vr: vr + 1
			]
		]

		unless no-show [
;			print "SHOW GRID-BOX"
			show grid-box
		]
	]

	update-visibility: has [
		tmp
	][
		either visible-columns [
			repeat n columns [
				either find visible-columns col-index/:n [
					show-column col-index/:n
				][
					hide-column col-index/:n
				]
			]
		][
			visible-columns: make hash! []
			repeat n columns [
				insert tail visible-columns col-index/:n
			]
		]
		unless visible-rows [
			visible-rows: make hash! []
			repeat n length? content [
				insert tail visible-rows row-index/:n
			]
		]
		if data [
			either tmp: find data 'visible-columns [
				change/only next tmp visible-columns
			][
				insert tail data reduce ['visible-columns visible-columns]
			]
			either tmp: find data 'visible-rows [
				change/only next tmp visible-rows
			][
				insert tail data reduce ['visible-rows visible-rows]
			]
		]
	]

	update-hilite: has [idx] [
		if all [hilite-row? picked/row-number > 0][
			picked/row: pick content picked/row-number
			show hilite-row
		]
		if all [hilite-cell? not empty? content picked/row-number > 0][
			picked/cell: pick pick content picked/row-number picked/column-number
			show hilite-cell
		]
	]

	update-sliders: has [ln scr sx hd][
		hslider/show?: vslider/show?: false
		scr: 0
		if all [visible-rows not empty? visible-rows][
;			if (ln: length? visible-rows) > rows [
ln: length? visible-rows
				vslider/offset: as-pair size/x - 17 -1 + either header? [header-height][0]
				vslider/size: as-pair 16 size/y - 1 - either header? [header-height][0]
				vslider/ratio: either ln <= rows [1][max .1 rows / ln]
				vslider/data: either ln <= rows [0][max 0 min 1 scroll / (ln - rows)]
				vslider/show?: true
				scr: 16
				show vslider
;			]
		]

		if all [any [header? not empty? content] row-size/x > (size/x - scr)] [
			sx: any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]
			hslider/size/x: root-face/size/x - scr + 1
			hslider/ratio: max .1 size/x - scr / sx
			hslider/data: either 0 < hd: negate (sx - size/x + 2 + either vslider/show? [16][0]) [
				grid-box/offset/x / hd
			][
				0
			]
			hslider/show?: true
			show hslider
		]
	]

	scroll-to: func [idx /force][
		if hilite-cell/offset/x < 0 [
			 grid-box/offset/x: min 0 grid-box/offset/x - hilite-cell/offset/x
		]
		if (hilite-cell/offset/x + hilite-cell/size/x) > (size/x  - either vslider/show? [18][0]) [
			 grid-box/offset/x: max negate (grid-box/size/x - size/x) grid-box/offset/x - hilite-cell/size/x
		]
		either any [
			force ; always move the scroll position
			idx <= scroll
			idx > (scroll + rows)
		][
			scroll: max 0 min (length? visible-rows) - rows idx; - (to-integer rows / 2) - 1
		][
			return none
		]
	]

	pass-event: func [fac [object!] e [object! event!]][
		fac/feel/engage fac e/type make object! [
			type: e/type
			key: e/key
			offset: e/offset
			time: e/time
			shift: e/shift
			control: e/control
			face: e/face
			double-click: false
		]
	]

	show-column: func [
		col [integer!]
		/local tmp nn
	][
		col: index? find col-index col
		repeat n length? grid-box/pane [
			nn: n // columns
			if nn = 0 [nn: columns]
			if nn = col [
				tmp: grid-box/pane/:n
				if tmp/old-y [
					tmp/offset/y: tmp/old-y
					tmp/show?: true
					tmp/old-y: none
				]
			]
		]
		nn: tmp: 0
		foreach f grid-box/pane [
			nn: nn + 1
			if f/offset/y <> 10000 [
				if f/cspan = #WP [
					f/size/x: f/ini-size/x * (grid-box/size/x / grid-box/ini-size/x)
				]
				if nn = columns [
					f/size/x: (max grid-box/size/x root-face/size/x) - tmp - (either grid-box/ini-size/x < root-face/size/x [18][0])
				]
				f/offset/x: tmp
				tmp: tmp + f/size/x

			]
			if nn = columns [nn: tmp: 0]
		]
		if header? [
			repeat n length? header-box/pane [
				if n = col [
					tmp: header-box/pane/:n
					if tmp/old-y [
						tmp/offset/y: tmp/old-y
						tmp/show?: true
						tmp/old-y: none
					]
				]
			]
			tmp: 0
			nn: 1
			foreach f header-box/pane [
				if f/show? [
					f/offset/x: tmp - either tmp = 0 [0][nn - 1]

					f/size/x: either nn = columns [
						header-box/size/x - tmp + nn - 1
					][
						1 + any [all [not empty? grid-box/pane grid-box/pane/:nn/size/x] all [not empty? row-lay row-lay/:nn/size/x] 0]
					]
					tmp: tmp + f/size/x
				]
				nn: nn + 1
			]
		]
		if not find visible-columns col-index/:col [
			insert tail visible-columns col-index/:col
		]
	]

	hide-column: func [
		col [integer!]
		/local tmp nn
	][
		col: index? find col-index col
		repeat n length? grid-box/pane [
			nn: n // columns
			if nn = 0 [nn: columns]
			if nn = col [
				tmp: grid-box/pane/:n
				unless tmp/old-y [
					tmp/old-y: tmp/offset/y
					tmp/offset/y: 10000
					tmp/show?: false
				]
			]
		]
		nn: tmp: 0
		foreach f grid-box/pane [
			nn: nn + 1
			if f/offset/y <> 10000 [
				f/offset/x: tmp
				tmp: tmp + f/size/x
			]
			if nn = columns [nn: tmp: 0]
		]
		if header? [
			repeat n length? header-box/pane [
				if n = col [
					tmp: header-box/pane/:n
					unless tmp/old-y [
						tmp/old-y: tmp/offset/y
						tmp/offset/y: 10000
						tmp/show?: false
					]
				]
			]
			tmp: 0
			foreach f header-box/pane [
				if f/show? [
					f/offset/x: tmp
					tmp: tmp + f/size/x
				]
			]
		]
		if tmp: find visible-columns col-index/:col [
			remove tmp
		]
	]

	swap: func [
		col1 [integer!]
		col2 [integer!]
		data [block! hash! list!]
		/only
		/local tmp tmp2
	][
		tmp1: at data col1
		tmp2: at data col2
		col1: tmp1/1
		col2: tmp2/1
		remove tmp1
		either only [
			insert/only tmp1 col2
		][
			insert tmp1 col2
		]
		remove tmp2
		either only [
			insert/only  tmp2 col1
		][
			insert tmp2 col1
		]
	]

	swap-columns: func [
		col1 [integer!]
		col2 [integer!]
		/local tmp tmp2
	][
		if col1 = col2 [exit]

		swap col1 col2 col-index

		build-row row-spec
		update-grid

		if header? [
			build-header data/header
		]

		update-content

		update-visibility
	]

	insert-column: func [
		col-spec [block!]
		col-content [block!]
		pos [integer! none!]
		/header
			htitle [string!]
		/hidden
		/local
			idx var cont
	][
		unless pos [pos: columns + 1]

		unless find data 'row-spec [
			insert tail data reduce ['row-spec copy []]
		]

		idx: 0
		parse data/row-spec [
			some [
				(cont: none)
				var: block! (
					idx: idx + 1
					if idx = pos [cont: [end skip]]
				) cont
				| 'with block!
			]
		]
		insert var col-spec

		parse-row-spec data/row-spec

		idx: 0
		foreach row content [
			idx: idx + 1
			insert/only at row pos any [pick col-content idx ""]
		]

		forall col-index [
			 if col-index/1 >= pos [
				col-index/1: col-index/1 + 1
			]
		]

		insert at col-index pos pos

		build-row row-spec
		update-grid
		grid-box/size: second span? grid-box/pane
		grid-box/size/x: max grid-box/size/x root-face/size/x ;- 16
		if header? [
;			header-box/size/x: grid-box/size/x
			header-box/size/x: 1 + any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]
			insert at data/header pos any [htitle "no name"]
			build-header data/header
		]
;		print "UC ins col"
		update-content

		update-sliders

		forall visible-columns [
			 if visible-columns/1 >= pos [
				visible-columns/1: visible-columns/1 + 1
			]
		]
		if not hidden [
			insert tail visible-columns pos
		]
		update-visibility
	]

	remove-column: func [
		col [integer!]
		/local idx with? tmp
	][

		idx: 0
		with?: false
		parse data/row-spec [
			some [
				(cont: none)
				var: block! (
					idx: idx + 1
					if idx = col [
						cont: [opt ['with block! (with?: true)] end skip]
					]
				) cont
				| 'with block!
			]
		]
		either with? [
			remove/part var 3
		][
			remove var
		]

		parse-row-spec data/row-spec

		foreach row content [
			remove at row col
		]

		forall col-index [
			 if col-index/1 >= col [
				col-index/1: col-index/1 - 1
			]
		]

		remove at col-index col

		build-row row-spec
		update-grid
		grid-box/size: second span? grid-box/pane
		grid-box/size/x: max grid-box/size/x root-face/size/x ;- 16
		if header? [
;			header-box/size/x: grid-box/size/x
			header-box/size/x: 1 + any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]
			remove at data/header col
			build-header data/header
		]
;		print "UC rem col"
		update-content

		update-sliders

		if tmp: find visible-columns col [
			remove tmp
		]
		forall visible-columns [
			 if visible-columns/1 >= col [
				visible-columns/1: visible-columns/1 - 1
			]
		]
		update-visibility
	]

	set-header: func [
		header [block!]
		/height hh [integer!]
	][
		all [hh header-height: hh]
		self/header?: true
		header-col:  make rebface header-col-spec []

		either data/header [
			data/header: header
		][
			insert tail data reduce ['header header]
		]
		if object? header-box [
			remove find pane header-box	
		]
		
		header-box: make rebface [
			offset: -1x-1
			size: as-pair grid-box/size/x + 2 1 + header-height
			pane: copy []
		]

		insert pane header-box
		
		grid-box/offset/y: header-height

		redraw
	]

	redraw: func [
	][
		if find data 'row-spec [
			parse-row-spec data/row-spec
			build-row row-spec
			update-grid
		]
		grid-box/size: second span? grid-box/pane
;		grid-box/size/x: max grid-box/size/x root-face/size/x ;- 16
		grid-box/size/x: (max grid-box/ini-size/x root-face/size/x) - (either grid-box/ini-size/x < root-face/size/x [16][0])		
		if header? [
;			header-box/size/x: grid-box/size/x
			header-box/size/x: 1 + any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]
			build-header data/header
		]
		update-visibility
		update-hilite
		update-sliders
;		print "UC redraw"
		update-content/no-show
		show self
	]

	go-to: func [
		x [integer!]
		y [integer!]
		/local tmpx tmpy
	][
		tmpx: picked/column-number
		tmpy: picked/row-number
		picked/column-number: x
		picked/row-number: y

		either all [
			find visible-columns x
			find visible-rows y
		][
			unless gb-update? [
				update-grid
				grid-box/size: second span? grid-box/pane
				grid-box/size/x: max grid-box/size/x root-face/size/x ;- 16
			]
			update-hilite
			scroll-to get-row-index
			update-content
			update-sliders
			true
		][
			picked/column-number: tmpx
			picked/row-number: tmpy
			false
		]
	]

	get-cell: func [
		col [integer!]
		row [integer!]
	][
		pick pick content row col

	]

	get-row: func [
		row [integer!]
		/visible
		/local result
	][
		result: copy []
		foreach c col-index [
			if any [not visible find visible-columns c] [
				insert/only tail result pick pick content row c
			]
		]
		result
	]

	get-column: func [
		col [integer!]
		/visible
		/local result
	][
		result: copy []
		col: pick col-index col
		foreach r row-index [
			if any [not visible find visible-rows r][
				insert/only tail result pick pick content r col
			]
		]
		result
	]

	set-cell: func [
		col [integer!]
		row [integer!]
		data [any-type!]
	][
		poke pick content row col data

	]

	set-row: func [
		row [integer!]
		data [block!]
		/visible
		/local idx
	][
		row: index? find row-index row
		idx: 0
		foreach c col-index [
			if any [not visible find visible-columns c] [
				idx: idx + 1
				change/only at pick content row c pick data idx
			]
		]
	]

	set-column: func [
		col [integer!]
		data [block!]
		/visible
	][
		col: pick col-index col
		foreach r row-index [
			if any [not visible find visible-rows r][
				change/only at pick content r col pick data r
			]
		]
	]

	insert-row: func [
		row [integer! none!]
		data [block!]
		/hidden
		/bulk "insert block of multiple rows at once"
		/local
			len rowids
	][
		unless bulk [data: reduce [data]]
		len: length? data
		unless row [row: len + length? content]
		insert at content row data
		forall row-index [
			 if row-index/1 >= row [
				row-index/1: row-index/1 + len
			]
		]
		
		rowids: copy []
		repeat r len [
			insert tail rowids r - 1 + row
		]
		
		insert at row-index row rowids


		forall visible-rows [
			 if visible-rows/1 >= row [
				visible-rows/1: visible-rows/1 + len
			]
		]
		if not hidden [
			insert tail visible-rows rowids
		]
		gb-update?: false
	]

	remove-row: func [
		row [integer!]
		/local tmp
	][
		remove at content row
		forall row-index [
			 if row-index/1 >= row [
				row-index/1: row-index/1 - 1
			]
		]
		remove at row-index row

		if tmp: find visible-rows row [
			remove tmp
		]
		forall visible-rows [
			 if visible-rows/1 >= row [
				visible-rows/1: visible-rows/1 - 1
			]
		]
		gb-update?: false
	]


	header-col-spec: [
		edge: default-edge
		font: default-font
		clrs: [grid-header grid-header-over]
		tr: 1x1
		effects: [
			[draw [pen 0.0.0 fill-pen 0.0.0 translate tr polygon 0x0 6x0 3x6]]
			[draw [pen 0.0.0 fill-pen 0.0.0 translate tr polygon 3x0 6x6 0x6]]
		]
		color: get in ctx-rebgui/colors clrs/2
		feel: make default-feel [
			over: func [f o][
				all [
					sort-columns?
					f/color: get in ctx-rebgui/colors pick f/clrs o
					show f
				]
			]
			engage: func [f a e /local tmp col res1 res2 c][
				if all [sort-columns? a = 'up] [
					either sorted-by [
						either sorted-by/1 = f/data [
							sorted-by/2: sorted-by/2 + 1
						][
							tmp: pick f/parent-face/pane sorted-by/1
							tmp/effect: none
							show tmp
							sorted-by/1: f/data
							sorted-by/2: 1
						]
						either sorted-by/2 > 2 [
							sorted-by/2: 0
							f/effect: none
						][
							f/effect: pick f/effects sorted-by/2
						]
					][
						f/effect: f/effects/1
						sorted-by: reduce [f/data 1]
					]

					tmp: root-face/get-row-index

					root-face/row-index: to-block root-face/row-index

					either all [sorted-by sorted-by/2 <> 0][
						col: sorted-by/1
						res1: pick reduce [false true] sorted-by/2
						res2: not res1
						c: root-face/content
						sort/compare root-face/row-index func [i j] compose/deep [
							either c/:i/:col < c/:j/:col [(res1)][(res2)]
						]
					][
						sort root-face/row-index
					]

					root-face/row-index: to-hash root-face/row-index

					either root-face/hilite-follow? [
						root-face/picked/row-number: root-face/get-row-by-index tmp
					][
						root-face/scroll-to root-face/get-row-index
					]

					root-face/update-content
					root-face/update-sliders
					root-face/update-hilite
				]
			]
		]
	]

	feel: make default-feel [
		detect: func [f e /local gbo fac col double-click][
			if	(e/type) <> 'move [
				either all [
					any [
						f/hilite-row/show?
						f/hilite-cell/show?
					]
					within? e/offset gbo: win-offset? f/grid-box as-pair f/size/x - f/grid-box/offset/x - either f/vslider/show? [18][0] f/size/y - f/grid-box/offset/y - either f/hslider/show? [18][0]
				][
					fac: find-face e/offset f/grid-box/pane none

					double-click: any [
						e/double-click
						f/double-click-up?
					]

					if all [
						e/type = 'down
						not double-click
					][
						unset 'action-result
						if system/view/focal-face <> f [
							ctx-rebgui/edit/focus f
						]

						f/picked/row-number: f/get-row-by-index min f/scroll + f/rows max (f/scroll + 1) to-integer (e/offset/y - gbo/y) / f/row-size/y + 1 + f/scroll

						if all [
							find f/grid-box/pane fac
							(col: (index? find f/grid-box/pane fac) // f/columns) = 0
						][
							col: f/columns
						]
						if col [
							f/picked/column-number: f/col-index/:col
						]
						f/update-hilite
					]

					if all [
						double-click
						fac
						fac/feel
						function? get in f 'action
					][
						if f/double-click-up?: not f/double-click-up? [
							set/any 'action-result f/action fac
						]
						if value? 'action-result [
							pass-event fac e
						]
					]
				][
					if system/view/focal-face <> f [
						ctx-rebgui/edit/focus f
					]
				]
			]
			e
		]
		engage: func [f a e /local tmp][
			if all [
				a = 'key
				any [f/hilite-row? f/hilite-cell?]
				not empty? f/visible-columns
				not empty? f/visible-rows
			][
				switch e/key bind on-key 'e
			]
			if a = 'scroll-line [
				tmp: f/scroll
				f/scroll: max 0 min (length? f/visible-rows) - f/rows f/scroll + (e/offset/y / (abs e/offset/y))
				if (tmp: tmp - f/scroll) <> 0 [
					if all [
						any [f/hilite-row? f/hilite-cell?]
						not empty? f/visible-columns
						not empty? f/visible-rows
						f/hilite-follow?
					][
						f/picked/row-number: f/get-row-by-index f/get-row-index - tmp
					]
					f/update-content
					f/update-sliders
					f/update-hilite
				]
			]
		]
		redraw: func [f a][
			if a = 'show [
				f/edge/color: either f = system/view/focal-face [
					 colors/grid-focus
				][
					colors/edge
				]
			]
		]
	]

	hilite-row-spec: [
		size: as-pair p/size/x any [all [row-size row-size/y] 0]
		color: colors/grid-hilite-row
		effect: [merge alphamul 128]
		feel: make default-feel [
			redraw: func [f a][
				if a = 'show [
					either all [
						p/hilite-row?
						not empty? p/visible-columns
						not empty? p/visible-rows
					][
						f/offset/y: p/get-row-index - 1 - p/scroll * p/row-size/y
						if p/header? [f/offset/y: f/offset/y + header-box/size/y]
						f/size/x: min grid-box/size/x p/size/x
						if all [p/header? f/offset/y < p/header-box/size/y][
							f/offset/y: - f/size/y
						]
						f/show?: true
					][
						f/show?: false
					]
				]
			]
		]
	]

	hilite-cell-spec: [
		edge: make default-edge [
			size: 2x2
			color: colors/grid-hilite-cell
			effect: [merge alphamul 128]
		]
		color: none
		feel: make default-feel [
			redraw: func [f a /local cn][
				if a = 'show [
					either all [
						p/hilite-cell?
						not empty? p/visible-columns
						not empty? p/visible-rows
						not zero?  p/picked/column-number
					][
						cn: index? find p/col-index p/picked/column-number
						f/offset/x: p/grid-box/pane/:cn/offset/x + p/grid-box/offset/x
						f/offset/y: p/get-row-index - 1 - p/scroll * p/row-size/y
						if p/header? [f/offset/y: f/offset/y + header-box/size/y]
						if all [p/header? f/offset/y < p/header-box/size/y][
							f/offset/y: - f/size/y
						]
						size: as-pair p/grid-box/pane/:cn/size/x p/row-size/y
						f/show?: true
					][
						f/show?: false
					]
				]
			]
		]
	]


	hslider-spec: [
		offset: as-pair -1 p/size/y - 17
		size: as-pair p/size/x - 2 - 16 16
		options: [arrows]
		show?: false
		action:	func [face /local] [
			p/grid-box/offset/x: to-integer face/data * negate ((any [all [grid-box/size/x > 0 grid-box/size/x] row-size/x]) - p/size/x + 2 + either vslider/show? [16][0])
			if header? [p/header-box/offset/x: -1 + p/grid-box/offset/x]
			show p
		]
		span: #Y
	]

	vslider-spec: [
		offset: as-pair p/size/x - 18 -1 + either header? [header-height][0]
		size: as-pair 16 p/size/y - 2 - either header? [header-height][0]
		options: [arrows]
		show?: false
		action:	func [face /local tmp drows] [
			tmp: p/scroll
			drows: (length? p/visible-rows) - (to-integer p/root-face/size/y - (either p/header? [p/header-box/size/y][0]) - (either hslider/show? [16][0]) / max 1 p/row-size/y)
			p/scroll: to-integer face/data * (max 0 drows)		;((length? p/visible-rows) - p/rows)
			if all [
				any [p/hilite-row? p/hilite-cell?]
				p/hilite-follow?
				(tmp: tmp - p/scroll) <> 0
			][
				p/picked/row-number: p/get-row-by-index p/get-row-index - tmp
			]
			update-content
			update-visibility
			update-hilite
		]
		span: #XH
	]

	set-data: func [
		data [block!]
		/no-show
	][
		self/data: data
		re-init
		any [no-show show self]
	]
	
	init: re-init: func [
		[catch]
		/local
			header x y p idx row-spec-blk val
	][
		if not :action [action: func [face][false]]
		root-face: p: self
		edge: make default-edge []

		picked: make object! [
			row: none
			cell: none
			row-number: none
			column-number: none
		]
		
		unless block? data [data: copy []]

		content: copy []
		header: copy []
		row-spec: copy []
		
		parse data [
			some [
				'visible-columns set visible-columns [block! | word!] (
					if word? visible-columns [visible-columns: get visible-columns]
				)
				| 'visible-rows set visible-rows [block! | word!] (
					if word? visible-rows [visible-rows: get visible-rows]
				)
				| 'header set header [block! | word!] (
					header?: true
					if word? header [header: get header]
				) opt [set val integer! (header-height: val)]
				| 'row-spec set row-spec-blk [block! | word!] (
					if word? row-spec-blk [row-spec-blk: get row-spec-blk]
					parse-row-spec row-spec-blk
				)
				| 'content set content [block! | word!] (
					if word? content [content: get content]
				)
			]
		]

		if all [visible-rows 1 = length? visible-rows visible-rows/1 = 0][
			visible-rows: none
		]

		pane: copy []
		scroll: 0

		grid-box: make rebface [
			color: colors/widget
			pane: copy []
			ini-size: size: none
		]

		if header? [grid-box/offset/y: header-height]

		col-index: make hash! []
		if row-spec [
			repeat n length? row-spec [
				insert tail col-index n
			]
			build-row row-spec
			update-grid
		]

		grid-box/size: second span? grid-box/pane

;		grid-box/size/x: max grid-box/size/x root-face/size/x ;- 16
		grid-box/size/x: (max grid-box/size/x root-face/size/x) - (either grid-box/size/x < root-face/size/x [16][0])		
		grid-box/ini-size: grid-box/size

		insert tail pane grid-box

		if negative? size/x [
			size/x: first second span? pane
		]

		if header? [

			header-col:  make rebface header-col-spec []

			header-box: make rebface [
				offset: -1x-1
;					size: as-pair row-size/x header-height
				size: as-pair any [all [grid-box/size/x > 0 grid-box/size/x] all [row-size/x > 0 2 + row-size/x]] header-height					
				pane: copy []
			]

			build-header header

			insert tail pane header-box
		]

		row-index: make hash! []

		repeat n length? content [insert tail row-index n]

		if visible-rows [
			sort visible-rows
			visible-rows: to-hash visible-rows
		]
		if visible-columns [
			sort visible-columns
			visible-columns: to-hash visible-columns
		]

		update-visibility

		hilite-row: make rebface bind hilite-row-spec 'p
		insert tail pane hilite-row
		if hilite-row? [
			picked/row-number: any [all [not empty? visible-rows first visible-rows] 0]
			picked/row: any [all [not empty? row-index not empty? content pick content any [pick row-index picked/row-number 0]] 0]
		]

		hilite-cell: make rebface bind hilite-cell-spec 'p
		insert tail pane hilite-cell
		if hilite-cell? [
			picked/column-number: any [pick col-index any [all [not empty? visible-rows any [all [not empty? visible-columns first visible-columns	] none]] 0]	0]
			picked/cell: pick any [pick content any [pick any [all [not empty? row-index row-index] []] picked/row-number 0] []] any [picked/column-number 0]
		]

		vslider: make slider bind vslider-spec 'p
		vslider/init

		hslider: make slider bind hslider-spec 'p
		hslider/init

		insert tail pane vslider
		insert tail pane hslider

		update-sliders
;		print ["UC init" offset]
		update-content
	]
]
