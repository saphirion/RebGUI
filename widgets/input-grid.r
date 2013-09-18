input-grid: make rebface [
	do-action: func [
		face [object!]
		action [function! none!]
		/local res
	][
		if none? :action [return false]
		set/any 'res action face face/text
		if all [
			value? 'res
			res
		][
			return true
		]
		return false
	]

	rows: 0
	cols: 0
	ctx-cells: none
	row-actions: col-actions: cell-action: none
	tabbing-mode: 'left-right

	lab-edge: make default-edge []

	feel: make default-feel [
		detect: func [f e][
			if all [e/type = 'up function? get in f 'action][
				f/action f
			]
			e
		]
	]

	set-cell: func [
		cell [pair!]
		txt [any-type!]
		/data
		/cell-action
		/no-show
	][
		if any [
			cell/x > cols
			cell/x < 1
			cell/y > rows
			cell/y < 1
		][
			make error! "cell-pair out of range"
		]
		either data [
			set in cell: pick pane (cell/y) * (cols + 1) + cell/x + 1 'data txt
		][
			change clear get in cell: pick pane (cell/y) * (cols + 1) + cell/x + 1 'text txt
		]
		if cell-action [
			cell/action cell
		]
		unless no-show [
			show cell
		]
	]

	get-cell: func [
		cell [pair!]
		/data
	][
		get in pick pane cell/y * (cols + 1) + cell/x + 1 either data ['data]['text]
	]

	get-grid: func [/data /local result][
		result: copy []
		repeat r rows [
			insert/only tail result copy []
			repeat c cols [
				insert tail last result either data [
					get-cell/data as-pair c r
				][
					get-cell as-pair c r
				]
			]
		]
		result
	]

	set-data: func [/local cell][
		repeat c cols [
			repeat r rows [
				cell: pick pane (r * (cols + 1) + c + 1)
				if error? try [cell/data: load cell/text][
					cell/data: cell/text
				]
			]
		]
	]

	set-grid: func [
		values [block! word!]
		/data
		/no-show
		/cell-action
		/local result c r
	][
		if word? values [values: get values]
		result: copy []
		r: c: 0
		foreach row values [
			r: r + 1
			foreach col row [
				c: c + 1
;				either data [
;					set-cell/data as-pair c r col
;				][
;					set-cell as-pair c r col
;				]
				do to-path compose [set-cell (either data ['data][]) (either cell-action ['cell-action][])] as-pair c r col
			]
			c: 0
		]
		unless no-show [
			show self
		]
		result
	]

	get-label-faces: func [
		/rows
		/columns
		/local result r c
	][
		result: copy []
		if rows [
			r: copy []
			repeat n self/rows [
				insert tail r pick self/pane n * (self/cols + 1) + 1
			]
			either columns [
				insert/only tail result r
			][
				insert tail result r
			]
		]
		if columns [
			c: copy []
			repeat n cols [
				insert tail c pick self/pane n + 1
			]
			either rows [
				insert/only tail result c
			][
				insert tail result c
			]
		]
		result
	]

	get-cell-names: does [
		all [ctx-cells bind copy next first ctx-cells in ctx-cells 'self]
	]

	make-cell-names: func [
		row-names [block!]
		column-names [block!]
		name-divider [string!]
		/local
			ctx-spec
	][
		ctx-spec: copy []
		repeat c cols [
			repeat r rows [
				insert tail ctx-spec compose [
					(to-set-word rejoin [form pick row-names r name-divider form pick column-names c]) pick pane (r * (cols + 1) + c + 1)
				]
			]
		]
		ctx-cells: context ctx-spec
	]

	reset-action: func [face] [
		repeat r face/rows [
			repeat c face/cols [
				face/set-cell/no-show 			as-pair c r copy ""
				face/set-cell/data/no-show	as-pair c r 0
			]
		]
		show face
	]

	redraw: does [
		build-grid
		show self
	]

	on-tab: func [
		back? [logic!]
		/local idx result f
	][
		f: system/view/focal-face
		result: either back? [
			any [
				all [(idx: (index? find f/parent-face/pane f) - (f/parent-face/cols + 1)) > (f/parent-face/cols + 1) pick f/parent-face/pane idx]
				pick f/parent-face/pane f/parent-face/rows * (f/parent-face/cols + 1) + ((index? find f/parent-face/pane f) // (f/parent-face/cols + 1) - 1)
			]
		][
			any [
				pick f/parent-face/pane f/parent-face/cols + 1 + index? find f/parent-face/pane f
				pick f/parent-face/pane f/parent-face/cols + 1 + ((index? find f/parent-face/pane f) // (f/parent-face/cols + 1)) + 1
			]
		]
		if all [result result/type <> 'field] [
			result: system/view/focal-face
		]
		result
	]

	build-grid: make function! [
		/local rows-blk columns-blk spec result ctext csize ctype calign tf rw row-title auto-cell-naming? idx values ralign cell-type cell-size rtext rtalign row-names column-names name-divider prio row-action col-action set-data?
	][
		set-data?: false
		rtalign: 'left
		name-divider: "_"
		if parse data [
			some [
				'columns set columns-blk [block! | word!] (
					if word? columns-blk [columns-blk: get columns-blk]
					parse copy columns-blk [
						(clear columns-blk)
						some [
							(col-action: none prio: false csize: 22 ctype: 'field calign: 'left)
							opt [set ctype ['label | 'field]] opt [set csize integer!] set ctext string! opt [set calign ['left | 'right | 'center]] opt ['type-prio (prio: true)] opt [set col-action block!]  (
								if not col-actions [col-actions: copy []]
								insert tail col-actions any [all [col-action func [face value] col-action] col-action]
								insert tail columns-blk reduce [ctype csize ctext calign prio any [all [col-actions :col-action length? col-actions] none]]
							)
						]
					]
				)
				| 'rows set rows-blk [block! | word] (
					if word? rows-blk [rows-blk: get rows-blk]
					parse copy rows-blk [
						(clear rows-blk)
						some [
							(prio: false row-action: none cell-size: cell-type: none ralign: 'left)
							opt [set cell-type ['label | 'field]] opt [set cell-size integer!] set rtext string! opt [set ralign ['left | 'right | 'center]] opt ['type-prio (prio: true)] opt [set row-action block!] (
								if not row-actions [row-actions: copy []]
								insert tail row-actions any [all [row-action func [face value] row-action] row-action]
								insert tail rows-blk reduce [ralign rtext cell-type cell-size prio any [all [:row-action row-actions length? row-actions] none]]
							)
						]
					]
				)
				| 'row-title set row-title string! opt [set rtalign ['left | 'right | 'center]]
				| 'auto-cell-naming (auto-cell-naming?: true)
				| 'values opt ['and 'data (set-data?: true)] set values [block! | word!] (if word? values [values: get values])
				| 'cell-action set cell-action [block! | word!] (
					if word? cell-action [cell-action: get cell-action]
					cell-action: func [face value] cell-action
				)
				| 'row-names set row-names [block! | word!] (if word? row-names [row-names: get row-names])
				| 'column-names set column-names [block! | word!] (if word? column-names [column-names: get column-names])
				| 'name-divider set name-divider string!
				| 'tabbing set tab-mode word! (tabbing-mode: tab-mode)
			]
		][
			tf: make system/standard/face [size: 10000x100 font: ctx-rebgui/widgets/label/font]
			rw: 0

			rows: (length? rows-blk) / 6
			cols: (length? columns-blk) / 6

			foreach [a t ct cs prio ract] rows-blk [
				tf/text: t
				rw: max rw first size-text tf
			]

			rw: to-integer (rw + 8 / ctx-rebgui/sizes/cell)

			spec: compose/deep [margin 0x0 space 0x0 label (rw) (any [row-title ""]) font [align: (to-lit-word rtalign)]]

			foreach [ctype csize ctext calign prio cact] columns-blk [
				insert tail spec compose/deep [
					label (csize) (ctext) font [align: (to-lit-word calign)]
				]
			]
			insert tail spec 'return
			idx: 0
			foreach [a r ct cs pr ract] rows-blk [
				if pr [
					if not ct [ct: 'field]
					if not cs [cs: 22]
				]
				insert tail spec compose/deep [
					label (rw) (r) font [align: (to-lit-word a)] para [wrap?: false]
				]
				foreach [ctype csize ctext calign prio cact] columns-blk [
					idx: idx + 1
					insert tail spec compose/deep [
						(any [all [any [not prio pr] ct] ctype]) (any [all [any [not prio pr] cs] csize]) (any [all [values pick values idx] copy ""])
						[
							either any [
								(either ract [compose [do-action face pick row-actions (ract)]][])
								(either cact [compose [do-action face pick col-actions (cact)]][])
								do-action face :cell-action
							][
								ctx-rebgui/edit/focus either tabbing-mode = 'top-bottom [on-tab false][ctx-rebgui/edit/next-field system/view/focal-face]
							][
								all [
									system/view/caret
									system/view/caret: tail system/view/caret
								]
								all [
									system/view/focal-face
									ctx-rebgui/edit/hilight-all system/view/focal-face
								]
							]
						]
						font [align: (to-lit-word calign)]
					]
				]
				insert tail spec 'return
			]
			pane: get in ctx-rebgui/layout spec 'pane
			if set-data? [set-data]
			repeat x cols [
				repeat y rows [
					f: pick pane y * (cols + 1) + x + 1
					if f/type = 'label [
						f/edge: lab-edge
					]
					f/options: either block? f/options [
						head insert tail f/options 'input-grid-item
					][
						copy [input-grid-item]
					]
				]
			]
			if all [auto-cell-naming? row-names column-names] [make-cell-names row-names column-names name-divider]
			size: second span? pane
		]
	]
	init: make function! [] [
		build-grid
	]
]
