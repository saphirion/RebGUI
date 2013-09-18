REBOL [
	Title:		"RebGUI widgets"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.2
	Date:		30-Apr-2006
	Purpose:	"The RebGUI base widget set."
	History: {
		0.3.0	Merged into ctx-rebgui
				Moved colors to ctx-rebgui colors object
				Removed keep func as it made little difference when used
				wrap-para renamed to default-para-wrap and offset attribute corrected to origin
				column-header renamed column
				Added text-list widget
				Area and field now do a make para [] so scrolling doesn't effect other widgets
		0.3.1	Improved text-list selection logic
				Added "face/action face" to check and radio-group widgets (Anton)
				Replaced scroller & slider widgets with new combined slider (Anton)
				Table and text-list updated to use new slider widget and set dragger ratio
				Added actions to tab-panel
				Tab-panel pad changed from pixels to units
		0.3.2	group-box and tab-panel changed to use layout/only
				Removed check for duplicate tab select from tab-panel
				Moved password pane creation into init to allow > 1 (Graham)
				Increased password bullet size (Graham)
				Refactored toolbar to use SVG icons
				Added [SVG] icon widget
				Changed button to be image based
				Default-font valign changed from 'top to 'middle
				Added unfocus call to tab-panel engage
		0.3.3	-
		0.3.4	Reduced unit-size from 5 to 4 and increased base multiple from 4 to 5 times
				Updated default sizes from base 4 to base 5
				Updated text-list widget
				Split out data options into separate options block
				Updated resize function to cover all current widget definitions
				Tidied up state-based widgets (check, radio, led, etc)
				Added options [info] to check and check-group widgets
				edit-list and drop-list simplified
				Can now tab to / from edit-list
		0.3.5	Reworked text-list
				Made face-iterator function generic to list-based widgets
				Updated drop-list and edit-list to use same
				Totally rewrote table widget to use same
				Added init para: make para decs to area, field, password, edit-list
		0.3.6	Added alt-action and dbl-action support to text-list & table
				Slider data dialect changed to use options block
		0.3.7	Added info option to area & field
				Fixed logic! init for check and led
				Added title accessor to tab-panel
		0.3.8	Added none and 0 defaults to radio-group
				Face-iterator now replaces "^/" with "¶" to avoid embedded line breaks in displayed data
				Added list-view widget (finally!)
				Improved area scrolling
		0.3.9	Minimum dragger size for scroller widget
				Updated group-box & tab-panel to reflect layout/only change
				group-box and tab-panel now auto-size
				Added copy face/span to 'table and 'text-list to fix #XY problems with parent
				Table column headings are now always left aligned
				Added picked and selected accessors to radio-group (data accessor depreciated)
				Enabled action on radio group
				Added text: copy text to edit-list to preserve original string
				Moved color assignments for area, text, text-list, drop-list, group-box into 'init
				Fixed password (span #W was not being inherited)
				Radio-group, LED, check-boxes changed to use colors/true and colors/false
				choose func now bounds its list by min items / available space (used by edit-list and drop-list)

		0.4.0	Added pie-chart widget
				Replaced attempt with try (Oldes)
				Added font-height to speed char edit operations
				Fixed area scroll / slider problems ... at long, long last
				Fixed minor field scroll problems
				Added slider-width and set to 4 * unit-size (used by area, table, text-list, drop-list, edit-list)
				Cleaned up table column arrows (reduced size, changed color and more space for last)
		0.4.1	font-height assignment in set-sizes swapped after default-font/size
				Added set-colors to handle dynamic color changes
				set-sizes, set-colors, set-fonts added to global context
				Sizing parameters grouped under ctx-rebgui/sizes context
				face-iterator now fires action on CTRL-A
				Replaced func/function/does/has with make function!
				Replaced feel 'action with 'act (shorter and distinquishes from face/action)
				Fixed minor display bug with table (last column header shrank on resize)
				Errors now use gui-error
				radio-group, check-group and led-group now have -1 size/y as default
				State widgets that relied on "compose [... data (false)]" now work correctly (fix in layout)
				default-font/name now references effects/font
		0.4.2	led fixed to use reduce [false] instead of [#[false]] (which fails under encap)
	}
]

make block! [

	set 'set-sizes make function! [
		size [integer!]
		/margin
		/gap
		/slider
	][
		all [margin sizes/margin: size return]
		all [gap sizes/gap: size return]
		all [slider sizes/slider: sizes/cell * size return]
		sizes/slider:				sizes/slider / sizes/cell * size
		sizes/cell:					size
		sizes/line:					size * 5
		;	reset static para origins / margins
		area/para/margin/x:			sizes/slider + 2
		check/para/origin/x:		sizes/line
		drop-list/para/margin/x:	sizes/line + 2
		edit-list/para/margin/x:	sizes/line + 2
		group-box/para/origin/x:	sizes/cell * 2
		led/para/origin/x:			sizes/line
	]

	set 'set-fonts make function! [
		/size font-size [integer!]
		/name font-name [string!]
	][
		if size [
			default-font/size:			font-size
			sizes/font:					font-size
			;	reset static font sizes
			area/font/size:				font-size
			button/font/size:			font-size
			group-box/font/size:		font-size
			label/font/size:			font-size
			menu-list/font/size:			font-size
			password/font/size:			to integer! font-size * 1.5
			title-group/font/size:		font-size
		]
		if name [
			default-font/name:			font-name
			effects/font:				font-name
			;	reset static font names
			area/font/name:				font-name
			button/font/name:			font-name
			group-box/font/name:		font-name
			label/font/name:			font-name
			menu-list/font/name:			font-name
			title-group/font/name:		font-name
		]
		sizes/font-height: second size-text make rebface [text: "" font: default-font para: default-para]
	]

	set 'set-colors make function! [] [
		default-edge/color:			colors/edge
		arrow/effect/2:				colors/btn-text
		bar/color:					colors/window
		drop-list/color:			colors/widget
		edit-list/color:			colors/edit
		progress/color:				colors/widget
		slider/color:				colors/window
		splitter/color:				colors/window
		table/color:				colors/window
		text-list/color:			colors/widget
		title-group/color:			colors/widget
		tool-bar/color:				colors/window
	]

	;
	;	--- Default edge, font, para, feel objects ---
	;

	default-edge: make object! [
		color:	colors/edge
		image:	none
		effect:	none
		size:	1x1
	]

	default-font: make object! [
		name:	effects/font
		style:	none
		size:	sizes/font
		color:	black
		offset:	0x0
		space:	0x0
		align:	'left
		valign:	'middle
		shadow:	none
	]

	default-para: make object! [
		origin:	2x2
		margin:	2x2
		indent:	0x0
		tabs:	0
		wrap?:	false
		scroll:	0x0
	]

	; Unfortunately, offset-to-caret returns end of the string when offset is between two lines,
	; which is only possible when indent/y > 0. This ought to be submitted to rambo as a rebol/view bug.
	; I would not use indent until it is fixed.
	; offset-to-caret needs to work correctly to allow the new area widget functionality of keeping
	; the caret visible when scrolling. -AntonR

	;default-para-wrap: make default-para [origin: 2x0 indent: 0x2 wrap?: true]
	default-para-wrap: make default-para [origin: 2x0 indent: 0x0 wrap?: true]

	default-feel: make object! [redraw: detect: over: engage: none]

	sizes/font-height: second size-text make rebface [text: "" font: default-font para: default-para]

	menu-shortcuts: copy []
	
	set 'add-menu-shortcut func [
		item [string!]
		shortcut [block!]
		/local f s ctrl shift key
	][
		parse shortcut [
			set ctrl opt <ctrl> set shift opt <shift> set key opt issue!		
		]
		s: reduce [true? ctrl true? shift key]
		either f: find/case/skip menu-shortcuts item 2 [
			change/only next f s
		][
			insert tail menu-shortcuts reduce [
				item s
			]
		]
	]

	set 'remove-menu-shortcut func [
		item [string!]
	][
		remove/part find/case/skip menu-shortcuts item 2 2
	]
	
	menu-text-face: make face [
		size: 10000x100
		font: default-font
		para: default-para
	]

	build-menu-items: func [
		data [block!]
		/deep "recursively parse submenus for shortcuts"
		/local actions items menu-size item act blk aim ghosted ctrl shift key shortcut-width f checked sub
	][
		set [actions items menu-size] copy/deep [[][] 0x0]
		shortcut-width: 0
		parse data [
			some [
				<bar> (
					append items 'bar
					append actions none
					menu-size/y: menu-size/y + 6
				)
				| (checked: ghosted: none) any [<checked> (checked: true) | <ghosted> (ghosted: true)] set item string! [
					<sub> set sub [word! | block! | get-word!] (
						append/only items reduce ['item menu-text-face/text: item 'submenu sub 'y menu-size/y]
						if ghosted [insert tail last items reduce ['ghosted ghosted]]
						menu-size/x: max menu-size/x first size-text menu-text-face
						menu-size/y: menu-size/y + sizes/line
						append/only actions none
						if deep [
							unless block? sub [sub: get sub]
							apply :build-menu-items [sub deep]
						]
					)
					| (ctrl: shift: key: none) any [<ctrl> (ctrl: true) | <shift> (shift: true) | set key issue!] (
						menu-text-face/text: item
						menu-size/x: max menu-size/x first size-text menu-text-face
						menu-size/y: menu-size/y + sizes/line
						if f: find/case menu-shortcuts item [
							set [ctrl shift key] f/2
						]
						if any [key ghosted checked][
							item: reduce ['item item]
						]
						if key [
							insert tail item compose [
								shortcut (rejoin [either ctrl ["Ctrl+"][""] either shift ["Shift+"][""] uppercase key])
							]
							menu-text-face/text: item/shortcut
							shortcut-width: max shortcut-width first size-text menu-text-face
						]
						if ghosted [insert tail item reduce ['ghosted ghosted]]
						if checked [insert tail item reduce ['checked checked]]
						append/only items item
						
					)
					set act opt [word! | block!] (
						append/only actions act
						if all [key act] [
							add-key-shortcut true? ctrl	true? shift	key	act
						]
					)
				]
			]
		]
		reduce [actions items sizes/cell * 3x0 + menu-size + any [all [shortcut-width <> 0 shortcut-width + 5 * 1x0] 0]]
	]

	set 'add-ctx-menu func [
		face [object! word!]
		data [block! function!]
	][
		build-menu-items/deep data 
		repend context-menus [face :data]
	]
	
	set 'remove-ctx-menu func [
		face [object! word!]
	][
		remove/part find/skip context-menus face 2 2
	]

	get-work-bounds: func [
		oft [pair!]
		/local screens
	][
		screens: gui-metric 'work-origin
		foreach s gui-metric 'work-size [
			insert next screens s
			screens: skip screens 2
		]
		screens: head screens
		foreach [soft ssiz] screens [
			if inside? soft + ssiz oft [
				return reduce [soft soft + ssiz]
			]
		]
		return none
	]
	
	show-menu: func [
		parent [object!]
		offset [pair!]
		data [block! function!]
		/no-wait
		/local actions items menu-size result oft item wsize woft
	][
		set [actions items menu-size] ctx-rebgui/widgets/build-menu-items data
		menu-size/x: max 80 menu-size/x + 10

		set [woft wsize] get-work-bounds offset + screen-offset? parent

		oft: (confine parent/offset + offset menu-size woft wsize) - parent/offset		
		if oft/y < offset/y [
			offset/y: offset/y - menu-size/y
		]
		if oft/x < offset/x [offset/x: offset/x - menu-size/x]
		result: apply get in ctx-rebgui/widgets 'choose [
			parent menu-size/x offset items
			true
			false
			none
			true
			no-wait
			either no-wait [
				context compose/only [
					actions: (copy actions)
					items: (copy items)
					item: none
					on-result: func [result][
						all [
							item: find/only items result
							actions: pick actions index? item
							do funct [parent [object!] action-type [word!]] any [all [word? actions get actions] all [block? actions actions] []] parent 'mouse
						]
					]
				]			
			][
				none
			]
			none
			none
		]
		unless no-wait [
			all [
				result
				item: find/only items result
				actions: pick actions index? item
				do funct [parent [object!] action-type [word!]] any [all [word? actions get actions] all [block? actions actions] []] parent 'mouse
			]
		]
		ctx-rebgui/menu-open?: true
	]

	hide-menu: func [
		/from
			menu-face [object!]
	][
		foreach m reverse copy either menu-face [next find system/view/pop-list menu-face][system/view/pop-list][
			all [
				in m 'opts
				find m/opts 'menu
				hide-popup/only m
				not ctx-rebgui/menu-open?: false
			]
		]
	]

	set 'get-menu func [
		"Returns menu face."
		data [block! function!] "Menu dialect block or function that generates such block."
		/local actions items menu-size result
	][
		set [actions items menu-size] ctx-rebgui/widgets/build-menu-items data
		menu-size/x: max 80 menu-size/x + 10

		result: make ctx-rebgui/widgets/face-iterator [
			size: as-pair menu-size/x ctx-rebgui/sizes/line * length? items
			color: ctx-rebgui/colors/edit
			edge: ctx-rebgui/widgets/default-edge
			data: items
		]
		append result/opts 'menu
		result/init
		result
	]

	set 'get-tool-tip func [
		"Returns tool-tip face."
		fac [object! string! block!] "face containing tool-tip, simple text or layout block for tool-tip"
		/cell "specify table cell position for cell tool-tip action(only for TABLE widget!)"
			pos [pair!]
		/local
			result
	][
		unless object? fac [
			fac: make face [
				tool-tip: reduce [fac none]
			]
		]
		
		if cell [
			if fac/type <> 'table [make error! rejoin ["GET-TOOL-TIP: the /CELL refinement can be used only on TABLE widget, not on " uppercase form fac/type]]
			fac/ttip: get in fac 'cell-tooltip-act
			fac/cell-face: make face [cell-coord: pos]
		]

		unless select fac 'tool-tip [return none]
		result: make face [
			color: ctx-rebgui/colors/tooltip-bkg
			font: make ctx-rebgui/widgets/default-font [
				color: ctx-rebgui/colors/tooltip-text
			]
			para: make ctx-rebgui/widgets/default-para []
			edge: make face/edge [
				size: 1x1
				color: ctx-rebgui/colors/tooltip-edge
			]
			feel: none
		]
		
		if block? fac/tool-tip/2 [
			do func [face tool-tip event] fac/tool-tip/2 fac result make object! []
		]

		either all [
			block? fac/tool-tip/1
			not empty? fac/tool-tip/1
		][
			result/pane: ctx-rebgui/layout/only/origin fac/tool-tip/1 0x0
			result/size: result/pane/size + 2
			result/pane/effect: 'merge
			result/text: result/pane/color: none
		][
			either all [
				fac/tool-tip/1
				not empty? fac/tool-tip/1
			][
				result/text: translate fac/tool-tip/1
				result/size: 6 + size-text make system/standard/face [
					font: result/font
					para: result/para
					size: 1000x100
					text: result/text
				]
			][
				result/text: none
				result/size: 0x0
			]
		]
		result
	]
	
	;
	;	--- Iterator function ---
	;

	face-iterator: make rebface [
		type:	'face-iterator
		pane:	[]
		data:	[]
		timeout: now/time/precise
		vscr: none
		feel:	make default-feel [
			redraw: make function! [face act pos] [
;				print ["ibox redraw" act face/changes]
				if all [act = 'show face/size <> face/old-size] [face/resize]
			]
			engage: make function! [face act event /local i old] [
				if all [
					act = 'scroll-line
					face/rows > face/lines
				][
					face/scroll: max 0 min face/rows - face/lines face/scroll + (event/offset/y / (abs event/offset/y))
					face/vscr/data: face/scroll / (face/rows - face/lines)
					show face
					if find face/opts 'table [show face/vscr]
				]
				if act = 'time [
					if (now/time/precise - face/timeout) > 0:00:0.2 [
						face/action either find face/opts 'table [face/root][face]
						face/rate: none
						show face
					]
				]
				if all [act = 'key face/root/key-navigation] [
					switch event/key [
						#"^A"	[	; CTRL-A
							if find face/opts 'multi [
								old: copy face/picked
								clear face/picked
								unless event/shift [
									repeat i face/rows [insert tail face/picked i]
								]
								if old <> face/picked [
									face/action either find face/opts 'table [face/root][face]
								]
							]
						]
						down	[	; DnAr
								i: 1 + last face/picked
								;BEG fixed by Cyphre, sponsored by Robert
								if i <= face/rows [
									i: min face/rows i
									insert clear face/picked i
									if find face/opts 'table [
										face/timeout: now/time/precise
										face/rate: 60
										if i > (face/scroll + face/lines) [
											face/vscr/data: 1 / (face/rows - face/lines) * ((min (face/rows - face/lines + 1) (i - face/lines + 1)) - 1)
											face/scroll: face/scroll + 1
										]
										show face/vscr
									]
								]
								;END fixed by Cyphre, sponsored by Robert
						]
						up		[	; UpAr
							i: -1 + last face/picked
							;BEG fixed by Cyphre, sponsored by Robert
							if i > 0 [
								i: max 1 i
								insert clear face/picked i
								if find face/opts 'table [
									face/timeout: now/time/precise
									face/rate: 60
									if i = face/scroll [
										face/vscr/data: 1 / (face/rows - face/lines) * ((min (face/rows - face/lines + 1) i) - 1)
										face/scroll: face/scroll - 1
									]
									show face/vscr
								]
							]
							;END fixed by Cyphre, sponsored by Robert
						]
						;BEG fixed by Cyphre, sponsored by Robert
						#"^M" [
							if all [find face/opts 'table face/root/key-navigation face/root/return-key] [
								face/action face/root
							]
						]
						;END fixed by Cyphre, sponsored by Robert
					]
					show face
				]
			]
		]
		lines:	none	; number of current visible lines
		rows:	none	; number of data rows
		cols:	1		; number of columns (> 1 table option only)
		visible-cols: 1 ; number of visible columns (table option only)
		cols-offset: 0	; offset of visible columns (table option only)
		widths:	none	; pixel width of each column (table option only)
		aligns:	none	; column aligns
		picked:	[]		; current selection(s)
		scroll:	0		; scroll offset
		table?: false
		opts: any [options copy []]
		
		resize:	make function! [] [	; window size change(s)
			lines: to integer! size/y / sizes/line
			if 0 < length? pane [
				vscr/show?: either rows > lines [
					scroll: max 0 min scroll rows - lines
					true
				][
					scroll: 0
					false
				]
			]
		]
		redraw:	make function! [/no-show] [	; data change(s)
;			clear picked ;by Cyphre, sponsored by Robert
			rows: either empty? data [0] [(length? data) / cols]
			resize
			vscr/ratio: either zero? rows [1] [lines / rows]
			unless no-show [show self]
		]
		selected: make function! [/local blk] [
			if empty? picked [return none]	; are any rows selected?
			either any [find opts 'multi find opts 'table] [
				if rows = length? picked [return data]	; are all rows selected?
				blk: copy []
				either cols = 1 [
					foreach row picked [insert/only tail blk pick data row]
				][
					foreach row picked [
						repeat col cols [
							insert/only tail blk pick data -1 + row * cols + col
						]
					]
				]
				blk
			][
				blk: pick data first picked
			]
		]
		init:	make function! [/local p o] [
			;	remove XY span directives
			error? try [remove/part find span #XP 2]
			error? try [remove/part find span #YP 2]
			error? try [remove find span #X]
			error? try [remove find span #Y]
			all [span replace span #HP #H]

			;	iterated line handler
			p: self

			;	calculate lines & rows
			either find p/opts 'menu [
				rows: length? data
				o: lines: 0
				foreach d data [
					switch/default d [
						bar [
							o: o + 6
						]
					][
						o: o + sizes/line
					]
					if o <= size/y [lines: lines + 1]
				]
				size/y: min size/y o
			][
				lines: to integer! size/y / sizes/line
				rows: (length? data) / cols
			]
			;BEG fixed by Cyphre, sponsored by Robert
			clear pane
			;END fixed by Cyphre, sponsored by Robert
			insert pane make rebface [
				focal-target: either find p/opts 'table [p/root][p]
				size: p/size
				span: p/span
				last-index: 1
				show-row?: true
				oft: either find p/opts 'menu [array min lines rows][none]
				pane: make function! [face index /local col-offset cell font-color cell-action? data o idx ghosted? f] [
					either integer? index [
						if index <= min lines rows [
							line: p/pane/1/line
							line/offset/y: (index - 1 * line/size/y: sizes/line) + either find p/opts 'menu [
								o: 0
								foreach y copy/part oft index - 1 [
									all [y o: o + y]
								]
								o
							][
								0
							]
;							print ["render table" index o]
							line/size/x: size/x
							index: index + scroll
							either find p/opts 'table [
								col-offset: 0
								font-color: either find p/opts 'no-action [
									black
								][
									 either find picked index [white] [black]
								]
								cell-action?: get in p/root 'on-render-cell
;								print "render table BEGIN"
								tim: now/time/precise

								repeat i p/visible-cols [
									cell: pick line/pane i
									cell/offset/x: col-offset
									cell/size/x: p/widths/:i - either any [i = p/cols not p/root/column-resize] [1][sizes/cell] ; column gap
									cell/line-list: none
									cell/text: translate replace/all form pick p/data index - 1 * cols + i + p/cols-offset newline "¶"
									cell/font/color: font-color
									col-offset: col-offset + pick widths i
									cell/cell-coord: as-pair i index
									all [
										:cell-action?
										cell-action? cell cell/cell-coord
									]
								]
;								print ["render table END" now/time/precise - tim]
							][
								data: pick p/data index
								line/font/color: either find p/opts 'no-action [
									black
								][
									either find picked index [white] [black]
								]
								if find p/opts 'menu [
									line/color: line/effect: none
									line/font/color: either find picked index [colors/menu-item-hilite][colors/menu-item]
									line/para/origin/x: sizes/cell * 3
									line/effect: copy/deep [draw [font line/font]]
									either block? data [
										if ghosted?: find data 'ghosted [
											line/font/color: colors/menu-item-ghosted
										]
										if find data 'checked [
											insert tail line/effect/draw compose [
												pen (line/font/color) 
												line-width (sizes/cell * .333) 
												line
													(as-pair 3 sizes/cell * 2 + 2) 
													(as-pair sizes/cell * 1.4 sizes/cell * 3 + 2)
													(as-pair sizes/cell * 2.9 6)
											]
										]
										if find data 'shortcut [
											ctx-rebgui/widgets/menu-text-face/text: data/shortcut
											st: size-text ctx-rebgui/widgets/menu-text-face
											insert tail line/effect/draw compose [
												pen (line/font/color)
												text aliased (as-pair line/size/x - st/x - 10 3) (data/shortcut)
											]
										]

										if find data 'submenu [
											insert tail line/effect/draw compose [
												pen none
												fill-pen (line/font/color)
												triangle
													(as-pair line/size/x - 9 6)
													(as-pair line/size/x - 4 10)
													(as-pair line/size/x - 9 14)
											]
										]

										data: data/item
									][
										switch data [
											bar [
												line/size/y: 6
												line/text: none
												line/effect: compose/deep [draw [
													fill-pen (colors/edge)
													pen none
													box (as-pair 2 line/size/y * .5 - 1) (as-pair line/size/x - 4 line/size/y * .5 + 1)
												]]
												line/data: index
												poke oft index negate (sizes/line - line/size/y)
												return line
											]
										]
									]
								]
								line/text: translate replace/all form data newline "¶"
							]
							line/color: either find p/opts 'no-action [
								none
							][
								if all [not ghosted? find picked index] [colors/menu]
							]
							line/data: index
							line
						]
					] [
						either find p/opts 'menu [
							idx: 1
							o: 0
							foreach y oft [
								o: o + (sizes/line + any [y 0])
								if index/y < o [break]
								idx: idx + 1				
							]
							idx
						][
							to integer! index/y / sizes/line + 1
						]
					]
				]
				text: ""
				line: make rebface [
					size:	as-pair 0 sizes/line
					font:	make default-font []
					para:	make default-para []
					last-picked: none
					feel:	make default-feel [
						over: make function! [face act pos] [
							if find p/opts 'over [
								either act [insert clear picked data] [clear picked]
								show face
							]
						]
						engage: make function! [face act event /local pf a b oft f old] [
							pf: face/parent-face
							f: either p/table? [
								p/root
							][
								p/parent-face
							]
							old: if p/table? [copy picked]
							either find [up alt-down] act [
								;	allow parent to get key events
								view*/focal-face: pf
								view*/caret: tail pf/text

								either find p/opts 'multi [
									;	unflag previous selections?
									;BEG fixed by Henrik, sponsored by Robert
									case [
										none? face/last-picked [
											unless all [ ;hold multiple selection if it is right-clicked
												act = 'alt-down
												1 < length? picked
												find picked data
											][
												insert clear picked face/last-picked: data
											]
										]
										event/control [
											alter picked face/last-picked: data
										]
										event/shift [
											for i face/last-picked data either face/last-picked > data [-1][1] [
												remove find picked i
												insert tail picked i
											]
										]
										true [
											unless all [ ;hold multiple selection if it is right-clicked
												act = 'alt-down
												1 < length? picked
												find picked data
											][
												insert clear picked face/last-picked: data
											]
										]
									]
									;END fixed by Henrik, sponsored by Robert
								][
									insert clear picked face/last-picked: data
								]
								;	perform action if any and only on changes to picked
								if old <> picked [
									show pf
									either all [act = 'up not find p/opts 'no-action] [
										p/action f
									][
										p/alt-action f
									]
								]
							][
								if event/double-click [
									p/dbl-action f
								]
							]
						]
					]
				]
			]
			;	table?
			if find opts 'table [
				p/table?: true
				pane/1/line/pane: copy []
				repeat i cols [
					insert tail pane/1/line/pane make rebface [
						col-id: i
						cell-coord: none
						size:	as-pair 0 sizes/line
						font:	make default-font [align: aligns/:i]
						cursor-tmp: none
						feel: make default-feel [
							detect: make function! [face event] [
								p/root/picked-column: col-id + p/root/cols-offset
								event
							]
							over: make function! [face act pos /local cur][
								either act [
									face/cursor-tmp: p/root/cursor
									p/root/cursor: any [
										all [
											in face 'cursor
											face/cursor
										]
										face/cursor-tmp
									]
								][
									p/root/cursor: face/cursor-tmp
								]
								unless p/root/cell-face [p/root/cell-face: make face []]
								set p/root/cell-face next second face
								p/root/ttip: either act [
									any [
										get in face 'tool-tip
										get in p/root 'cell-tooltip-act
									]
								][none]
							]
						]
					]
				]
			]
			;	vertical scroller
			insert tail pane p/vscr: make slider [
				offset:	as-pair p/size/x - sizes/slider - 1 -1
				size:	as-pair sizes/slider p/size/y
				span: #
				if p/span [
					parse p/span [
						some [
							#H (insert tail span #H)
							| [#WP | #W] (insert tail span #X)
							| skip
						]
					]
				]
				options:	[arrows]
				show?:	either rows > lines [true] [false]
				action:	make function! [face /local scr] [
					switch/default face/hold [
						bottom-arrow [
							scroll: min rows - lines max 0 scroll + 1
							p/vscr/data: scroll / (rows - lines)
							p/vscr/state: none
							show p
						]
						top-arrow [
							scroll: min rows - lines max 0 scroll - 1
							p/vscr/data: scroll / (rows - lines)
							p/vscr/state: none
							show p
						]
					][
						scr: to integer! (rows - lines * data) + .5 ;NOTE: we have to add .5 to prevent the decimal accuracy issue
						if scr <> scroll [
;							print "scroll V"
							scroll: scr
							show p
						]
					]
 					
				]
				ratio:	either rows > 0 [lines / rows] [1]
			]
			p/vscr/init
		]
	]

	;
	;	--- Choose function ---
	;

	choose: make function! [
		parent [object!] "Widget to appear in relation to"
		width [integer!] "Width in pixels"
		xy [pair!] "Offset of choice box"
		items [block!] "Block of items to display"
		/outside
		/lines
			ln [integer! none!] "force number of visible lines"  ;fixed by Cyphre, sponsored by Robert
		/menu
		/no-wait
			cb [object!]
		/scroll-to
			line-idx [integer! none!]
		/local popup result wp wop wsize woft
	][
		result: none
		wp: find-window parent
		wop: win-offset? parent

		if outside [
			set [woft wsize] get-work-bounds xy + screen-offset? parent
		]

		popup: make face-iterator [
			type:	'choose
			;fixed by Cyphre, sponsored by Robert
			offset:	either outside [
				confine wp/offset + wop + xy as-pair width 0 woft wsize
			][
				xy + wop
			]
			size:	as-pair width sizes/line * any [
				ln
				min length? items either outside [
					to-integer (wsize/y - offset/y) / sizes/line
				][
					to-integer wp/size/y - wop/y - sizes/line / sizes/line
				]]
			color:	colors/edit
			data:	items
			feel:	make system/words/face/feel [
				close-events: [close]
				inside?: func [face event][face = event/face]
				process-outside-event: func [face event][
					unless find [move time active inactive key down up scroll-line] event/type [
						either find face/opts 'menu [
							hide-menu
						][
							hide-popup
						]
					]
					if all [
						event/type = 'scroll-line
						face/rows > face/lines
					][
						face/scroll: max 0 min face/rows - face/lines face/scroll + (event/offset/y / (abs event/offset/y))
						face/pane/2/data: face/scroll / (face/rows - face/lines)
						show face
					]
					event
				]
				pop-detect:	func [face event][
					either inside? face event [
						either find close-events event/type [
							either find face/opts 'menu [
								hide-menu
							][
								hide-popup
							]
							none
						][
							event
						]
					] [
						process-outside-event face event
					]
				]
			]
			edge:	default-edge
			opts: copy [over]
			callback: cb
			blocking?: not no-wait
			action: make function! [face /local sm] compose [
				result: pick data first picked
				if all [block? result find opts 'menu][
					if find result 'ghosted [
						clear picked
						result: none
						exit
					]
					if sm: find result 'submenu [
						clear picked
						result: none
						either self = last system/view/pop-list [
							ctx-rebgui/widgets/show-menu/no-wait self as-pair self/size/x - 3 1 + sm/y either block? sm/2 [sm/2][get sm/2]
						][
							hide-menu/from self
						]
						exit
					]
				]
				(either no-wait [[callback/on-result result]][[]])
				unfocus				
				either find opts 'menu [
					hide-menu
				][
					hide-popup
				]
			]
		]
		if menu [append popup/opts 'menu]
		popup/init
		
		if all [
			line-idx
			popup/rows > popup/lines
		][
			popup/scroll: max 0 min popup/rows - popup/lines line-idx - 1
			popup/vscr/data: popup/scroll / (popup/rows - popup/lines)
			show popup
		]
		
		;BEG fixed by Cyphre, sponsored by Robert
		either outside [
			popup/options: [no-title no-border]
			show-popup/away popup
		][
			show-popup/window/away popup wp;parent/parent-face
		]
		;END fixed by Cyphre, sponsored by Robert
		unless no-wait [do-events]
		result
	]

	;
	;	--- Widget definitions ---
	;

	#include %widgets/anim.r
	#include %widgets/area.r
	#include %widgets/arrow.r
	#include %widgets/bar.r
	#include %widgets/box.r
	#include %widgets/button.r
	#include %widgets/chart.r
	#include %widgets/chart-new.r
	#include %widgets/check.r
	#include %widgets/check-group.r
	#include %widgets/chevron.r
	#include %widgets/drop-list.r
	#include %widgets/drop-tree.r
	#include %widgets/edit-list.r
	#include %widgets/field.r
	#include %widgets/gauge.r
	#include %widgets/graph-edit.r
	#include %widgets/grid.r
	#include %widgets/group-box.r
	#include %widgets/help.r
	#include %widgets/image.r
	#include %widgets/input-grid.r
	#include %widgets/label.r
	#include %widgets/led.r
	#include %widgets/led-group.r
	#include %widgets/menu.r
	#include %widgets/menu-list.r
	#include %widgets/number-field.r
	#include %widgets/panel.r
	#include %widgets/password.r
	#include %widgets/pie-chart.r
	#include %widgets/plate.r
	#include %widgets/progress.r
	#include %widgets/radio-group.r
	#include %widgets/slider.r
	#include %widgets/splitter.r
	#include %widgets/table.r
	#include %widgets/tab-panel.r
	#include %widgets/text.r
	#include %widgets/text-list.r
	#include %widgets/timer.r
	#include %widgets/title-group.r
	#include %widgets/tool-bar.r
	#include %widgets/tree-view.r
	#include %widgets/spider.r
	#include %widgets/scroll-panel.r
	#include %widgets/warn.r
]
