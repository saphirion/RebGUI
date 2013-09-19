REBOL [
	Title:		"RebGUI system"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.17
	Date:		2-Jun-2006
	Purpose:	"Creates the RebGUI context and associated global functions."
	Acknowledgements: {
		The following people have contributed code and / or coding suggestions to this project:

			Allen Kamp
			Alphe Salas-Schuman (shadwolf)
			Anton Rolls
			Ashley G. Trüter
			Carl Sassenrath
			Christian Ensel
			Christopher Ross-Gill
			David Oliver (Oldes)
			Gabriele Santilli
			Graham Chiu
			Gregg Irwin
			Henrik Mikael Kristensen
			Pascal Lefevre
			Richard (Cyphre)
			Robert M. Müench
			Romano Paolo Tenca
			Vincent Ecuyer
			Volker Nitsch
			...

		and the many others who have taken the time to look at RebGUI and discuss it on AltME.
	}
	Globals:	[
		ctx-rebgui
		display
		request-color
		request-date
		request-dir
		request-file
		show-focus
		show-color
		show-data
		show-text
		show-title
		splash
	]
	History: {
		0.3.0	Merged RebGUI contexts into a single context named ctx-rebgui
				Removed many words from global namespace
				Replaced slm, sld, slc and slw with locale*
				Removed pre View 1.3 code such as construct, as-pair, etc
				Added check for View version
				Renamed face to rebface
				Added show-color accessor function
				Added init as a standard attribute
				Added rebfocus synonym for ctx-rebgui/edit/focus
				Set old-size on span-resize
		0.3.1	Widget color changed
				Check for View 1.3 or higher
		0.3.2	Added %rebgui-layout.r
		0.3.3	Minor changes for SDK 1.3.1 compatibility
		0.3.4	span-resize now protects against negative sizes
		0.3.5	Swapped splash parameters around (Graham)
				rebface/options now defaults to []
				Renamed rebfocus to show-focus
				Added clear-text function
				Added /focus refinement to show-text
		0.3.6	Extended rebface definition by adding alt-action & dbl-action attributes
				Added clear-widget accessor
		0.3.7	Added unview-keep function
		0.3.8	clear-widget now accepts block of faces as well
				Extended rebface definition with focus-action and unfocus-action facets
				Added app-on-focus / app-on-unfocus handlers
		0.3.9	Fixed bug in unview-keep
				Added true and false colors

		0.4.0	Added set-locale function (for Robert)
		0.4.1	Added set-locale to global context
				Removed old reference to offset-cache
				Added new sizes context
				Replaced context with make object!
				Replaced func/function/does/has with make function!
				Added global error handler
				Added font [name] to effects
		0.4.2	Added face/line-list: none to 'show-text and 'clear-text
		16		Added words block for layout function
		17		Added set-attribute & set-attributes accessor functions
		18		Added enable-show and disable-show to override nested uses of SHOW
		19		Added rebgui-view-patch.r to patch certain View functions
	}
]

if system/version < 1.3.1 [make error! "RebGUI requires View 1.3.1 or greater"]

;	change these paths to suit your local dir structure

;#include %/c/rebol/rebol-sdk/source/gfx-colors.r
;#include %/c/rebol/rebol-sdk/source/gfx-funcs.r

#include-check %rebgui-view-patch.r

;query/clear system/words

;	system/locale (colors are given in descending order of brightness)

system/locale: make system/locale [
	colors: [
		black
		navy
		blue
		violet
		forest
		maroon
		coffee
		purple
		coal
		oldrab
		red
		brick
		crimson
		leaf
		brown
		aqua
		teal
		magenta
		sienna
		water
		olive
		papaya
		mint
		gray
		green
		orange
		pewter
		khaki
		cyan
		tan
		silver
		pink
		sky
		gold
		wheat
		yellow
		beige
		snow
		linen
		ivory
		white
	]
	words: []
	language: "English"
	dictionary: none
	dict: []
]

;	Generic mezz funcs

;BEG fixed by Cyphre, sponsored by Robert
find-face: func [
	"Finds face under mouse cursor"
	pnt [pair!] "mouse coordinate"
	f [object! block!] "pane from where to start search"
	widgets [block! none!] "block of 'sensitive widgets' or none"
	/only "return the face only if the condition is true"
		condition [function!]
	/local p result w
][
	if all [
		object? :f
		any [
			not only
			all [
				only
				condition f
				any [
					not get in f 'pane
					not apply :find-face [pnt f/pane widgets only :condition]
				]
			]
		]
		any [
			all [
				none? widgets
				w: within? pnt win-offset? f f/size
				any [only not get in f 'pane]
			]
			all [
				widgets
				in f 'type
				find widgets f/type
				w: within? pnt win-offset? f f/size
			]
		]
	][
		return f
	]
	p: either object? :f [get in f 'pane][:f]
	any [
		either block? :p [
			result: none
			foreach fac head reverse copy p [
				if all [object? :fac fac: apply :find-face [pnt fac widgets only :condition]][
					result: fac
					break
				]
			]
			result
		][
			if object? :p [
				apply :find-face [pnt :p widgets only :condition]
			]
		]
		all [w f]
	]
]

resize-face: make function! [
	face [object!]
	/size
		new-size [pair!]
	/no-show
	/local
		span
][
	unless new-size [
		new-size: face/parent-face/size
	]
	unless face/init-size [
		face/init-size: face/size
	]
	ctx-rebgui/span-resize face new-size - face/size face/size/x / face/init-size/x face/size/y / face/init-size/y
	all [
		block? face/pane
		span: span? face/pane
		face/size: span/1 + span/2
	]
	unless no-show [
		show face
	]
]

reset-widgets: make function! [
	f [object! block!] "pane from where to start search"
	/types widget-types [block! none!] "block of 'sensitive widgets' or none"
	/local p
][
	if all [
		object? :f
		any [
			all [
				none? widget-types
				find first f 'type
			]
			all [
				widget-types
				find first f 'type
				find widget-types f/type
			]
		]
	][
		if find first f 'reset-action [
			f/reset-action f
		]
	]
	p: either object? :f [get in f 'pane][:f]
	either block? :p [
		foreach fac head reverse copy p [
			if object? :fac [
				reset-widgets/types :fac widget-types
			]
		]
    ][
		if object? :p [
			reset-widgets/types :p widget-types
		]
	]
]

;END fixed by Cyphre, sponsored by Robert

distance?: make function! [
	"Returns the distance between two points."
	p1 [pair!] "First point"
	p2 [pair!] "Second point"
][
	square-root abs p1/x - p2/x ** 2 + abs p1/y - p2/y ** 2
]

;	Accessor functions

show-color: make function! [
	"Sets a widget's color attribute."
	face [object!]
	color [tuple! word! none!]
	/no-show
][
	face/color: either word? color [get color] [color]
	unless no-show [
		show face
	]
]

show-panel: make function! [
	"Sets a panel widget's data content."
	panel [object!]
	data [object! block!]
	/no-show
] [
	panel/pane: either object? data [data/pane][data]
	resize-face/no-show/size panel panel/size
	unless no-show [
		show panel
	]
]

show-data: make function! [
	"Sets a widget's data attribute."
	face [object!]
	data [any-type!]
	/no-show
][
	face/data: either series? data [copy data] [data]
	unless no-show [
		show face
	]
]

show-text: make function! [
	"Sets a widget's text attribute."
	face [object!] "Widget"
	text [any-type!] "Text"
	/no-show
	/focus
][
	face/line-list: none

	insert clear face/text form text
	attempt [insert clear face/loc/text form text]

	all [face/type = 'area face/para face/para/scroll: 0x0 face/pane/data: 0]
	unless no-show [
		either focus [ctx-rebgui/edit/focus face] [show face]
	]
]

clear-text: make function! [
	"Clears a widget's text attribute."
	face [object!]
	/no-show "Don't show"
	/focus
][
	face/line-list: none
	clear face/text
	attempt [clear face/loc/text]
	all [face/type = 'area face/para face/para/scroll: 0x0 face/pane/data: 0]
	unless no-show [
		either focus [ctx-rebgui/edit/focus face] [show face]
	]
]

clear-widget: make function! [
	"Clears an iterated widget's data attribute(s)."
	face [object! block!]
	/default value [integer! logic! block!] "Reset to other value(s)"
][
	foreach f reduce either object? face [[face]] [face] [
		unless default [value: none]
		switch/default f/type [
			check-group [	; none! true! false!
				foreach item f/pane [item/data: value]
			]
			led-group [		; none! true! false!
				foreach item f/pane [item/data: value]
			]
			radio-group	[	; none! integer!
				if value = 0 [value: none] ; handle zero case
				either value [
					f/pane/:value/feel/engage f/pane/:value 'down none
				][
					if f/data [
						value: f/data
						clear skip f/pane/:value/effect/draw 7
						f/data: none ; 0.3.8
					]
				]
			]
			table [			; none! integer! block!
				clear f/picked
				if value [insert f/picked value]
				f/redraw
			]
			text-list [		; none! integer! block!
				clear f/picked
				if value [insert f/picked value]
				f/redraw
			]
		][
			gui-error reform [f/type "not supported by show-widget"]
		]
	]
	show face
]

set-attribute: make function! [
	face [object!] "Window dialog face"
	attribute [word!] "Attribute to set"
	value [any-type!]
	/no-show "Don't show"
	/focus
] [
	face/:attribute: case [
		string? value		[
			face/line-list: none
			all [face/type = 'area face/para face/para/scroll: 0x0 face/pane/data: 0]
			form value
		]
		series? value		[copy value]
		attribute = 'color	[either word? value [get value] [value]]
		true				[value]
	]
	unless no-show [
		either focus [ctx-rebgui/edit/focus face] [show face]
	]
]

set-attributes: make function! [
	face [object!] "Window dialog face"
	attributes [block!] "Block of attribute/value pairs to set"
	/no-show "Don't show"
] [
	foreach [attribute value] attributes [
		set-attribute/no-show face attribute value
	]
	any [no-show show face]
]

show-title: make function! [
	"Sets window title"
	face [object!] "Window dialog face"
	title [string!] "Window bar title"
][
	face/text: title
	all [face/loc face/loc/text: face/text]
	face/changes: 'text
	show face
]

get-state: make function! [
	"Retrieves face state as a state value block."
	face [object!] "Face to get state for"
	/local b w out
] [
	any [in face 'state-words return none]
	out: make block! length? face/state-words
	parse face/state-words [
		any [
			[set w word! set b block! (insert/only tail out do b)]
			| [set w word! (insert/only tail out get w)]
		]
	]
	out
]

set-state: make function! [
	"Sets face state from a state value block."
	face [object!] "Face to set state for"
	state "State value block"
	/local words
] [
	any [in face 'state-action return false]
	words: remove-each value copy face/state-words [not word? value]
	repeat i length? words [
		face/state-action pick words i pick state i
	]
	if in face 'redraw [face/redraw]
]

truncate-face: make function! [
	"Truncates the text in a face to one line and adds '...' or defined ending. Modifies face text."
	face [object!] "The face object to use (without paragraph wrapping)"
	/width w [integer!] "Maximum width of text in pixels"
	/ending end-string [char! string!] "Suitable for numeric and percent formatting"
	/no-show "Don't show"
	/local end-pos end-size font text text-size trunc-size
][
	if none? face/text [exit]
	font:		face/font
	face/font:	make face/font [align: 'left]
	text-size:	first size-text face
	text:		face/text
	end-string:	any [end-string "..."]
	face/text:	end-string
	end-size:	first size-text face
	trunc-size:	any [w face/size/x - either face/para [face/para/margin/x + face/para/origin/x][0]]
	face/text:	text
	end-pos:	offset-to-caret face as-pair trunc-size - end-size face/font/size / 2
	unless trunc-size > text-size [
		face/text: copy face/text
		face/text: head append clear at face/text index? end-pos end-string
	]
	face/font:	font
	any [no-show show face] ; do not show, when using this in an iterated face while also using locale
]

set-help-mode: make function! [
	"Sets the help mode and changes the cursor for all windows. Word! for a help mode. NONE to deactivate help mode."
	mode [word! none!]
][
	ctx-rebgui/help-mode: mode
]

get-help-mode: make function! [
	"Returns the current help mode."
] [
	ctx-rebgui/help-mode
]

set-help-function: make function! [
	"Sets the help mode callback function."
	function [function!]
] [
	ctx-rebgui/help-function: :function
]

set-help-face-function: make function! [
	"Sets the help face callback function."
	function [function!]
] [
	ctx-rebgui/help-face-function: :function
]

splash: make function! [
	"Displays a centered splash screen for one or more seconds."
	face [object!] "The face object to display"
	seconds [integer!] "Number of seconds to display splash"
][
	face/type: 'splash
	face/offset: max 0x0 system/view/screen-face/size - face/size / 2
	view/new/options face 'no-title
	wait seconds
]

watermark: make function! [
	src [image! block! object!]
	watermark [image! block! object!]
	/transparency
		alpha [integer!]
	/padding
		pad [pair!]
	/rotate
		rot [number!]
	/local
		dr s c lx ly
][
	src: to-image either block? src [ctx-rebgui/layout src][src]

	pad: any [pad 20x20]
	watermark: to-image	make face [
		image: either image? watermark [
			rot: any [rot -30]
			watermark
		][
			rot: any [rot 0]
			to-image either block? watermark [ctx-rebgui/layout watermark][watermark]
		]
		edge: none
		size: image/size
		effect: [grayscale]
	]

	watermark/alpha: any [alpha 240]
	s: watermark/size + pad

	lx: to-integer (src/size/x / s/x + 1) * 2
	ly: to-integer (src/size/y / s/y + 1) * 2

	c: as-pair lx * s/x / 2 ly * s/y / 2

	dr: compose [
		translate (c / 2)
		rotate (rot)
		translate (negate c)
		image-filter nearest
	]
		
	repeat y ly [
		repeat x lx [
			insert tail dr compose [image (as-pair x - 1 * s/x + either even? y [pad/x][- pad/x]  y - 1 * s/y) watermark]
		]
	]


	to-image make face [
		image: src
		edge: none
		size: image/size
		effect: [draw dr]
	]
]

;
;	--- RebGUI context ---
;

ctx-rebgui: make object! [
	view*: system/view
	update?: true
	level: 0
	mouse-offset: 0x0
	context-menus: copy []
	menu-open?: false
	key-shortcuts: copy []
	active-win: none
	help-mode: none
	help-function: none
	help-face-function: none

	debug: make object! [
		redraws: false		;show faces region when they are redrawn
	]
	
	set 'enable-show func [face /force] [
		level: max 0 either force [0][level - 1]
		if zero? level [
			update?: true
			;if face [show-native face]
			if face [show face]
		]
		face
	]
	set 'disable-show does [
		level: level + 1
		update?: false
	]
	;	global error handler
	gui-error: make function! [
		error [string!]
	][
		write/append/lines %rebgui.log reform [now error]
		make error! error
	]
	;	unview-keep
	unview-keep: make function! [num [integer!] /local pane] [
		pane: head view*/screen-face/pane
		while [(length? pane) > num] [remove back tail pane]
		show view*/screen-face
	]
	;	Localization
	locale*: system/locale
	set 'set-locale make function! [language [string! none!] /local dat-file] [
		clear locale*/words
		clear locale*/dict
		if exists? dat-file: join what-dir either language [rejoin [%language/ language %.dat]] [%locale.dat] [
			locale*: construct/with load dat-file locale*
		]
		if exists? locale*/dictionary: rejoin [what-dir %dictionary/ locale*/language %.dat] [
			locale*/dict: load locale*/dictionary
		]
	]

	set-locale none

	set 'load-locale make function! [file [file! block!]][
		clear locale*/words
		clear locale*/dict
		either file? file [
			locale*: construct/with load file locale*
		][
			locale*: construct/with copy/deep file locale*
		]
	]

	show-native: get in system/words 'show

	system/words/show: func [
		[catch]
		face [object! block!]
		/local err
	][
		ctx-rebgui/show-wrapper face
		if update? [ctx-rebgui/show-native face]
	]

	alpha: to-bitset [#"A" - #"Z" #"a" - #"z"]

	show-wrapper: func [
		face [object! block!]
	][
		either object? :face [
			trans face
		][
			if block? :face [
				foreach f face [
					unless function? :f [
						all [word? f f: get f]
						trans f
					]
				]
			]
		]
	]

	trans: func [
		f [object!]
		/local
			fac bl s
	][
		either found? get in f 'translate-action [
			f/translate-action f
		][
			if found? get in f 'loc [ ; changed by Robert
				if none? f/loc/text [
					f/loc/text: f/text
				]

				f/text: translate f/loc/text

				all [string? f/text not find f/text alpha f/loc/text: none]

				if block? f/effect [
					either any [
						none? f/loc/effect
						all [
							f/loc/last-effect
							f/loc/last-effect <> f/effect
						]
					][
						f/loc/effect: copy/deep f/effect
					][
						f/effect: copy/deep f/loc/effect
					]

					parse f/effect [
						some [
							'draw set bl block! (
								parse bl [
									some [
										s: string! (
											s/1: translate s/1
										)
										| skip
									]
								]
							)
							| skip
						]
					]
					f/loc/last-effect: copy/deep f/effect
				]
			]
		]
		all [
			debug/redraws
			f/edge: make ctx-rebgui/widgets/default-edge [color: random 255.255.255 size: 2x2]
		]
		switch type?/word get in f 'pane [
			block! [
				foreach fac f/pane [
					all [
						word? fac
						fac: get fac
					]
					all [
						object? fac
						trans fac
					]
				]
			]
			object! [
				trans f/pane
			]
		]
	]

	set 'translate make function! [
		"Dynamically translate a string or block of strings"
		text "String (or block or strings) to translate"
		/reverse "do reverse lookup"
		/local match txt loc?
	] [
		;	note that if text is not a string! or block! then no error will be raised
		;	this is an optimization so code that calls translate does not have to be wrapped
		;	in an "if string? text ..." type construct
		if all [series? text locale*/words] [
			txt: copy/deep any [loc?: find/match text "<loc>" text]
			all [
				string? txt
				any [
					; 1st try normal direction: from -> to
					match: select/skip/case locale*/words txt 2

					; 2nd try reverse direction: to -> from
					either reverse
						[attempt [match: first back find/case locale*/words txt]]
						[false]
				]
				insert clear txt match
				return txt
			]
			if block? txt [
				foreach word txt [
					all [
						string? word
						match: select/skip/case locale*/words word 2
						insert clear word match
					]
				]
				return txt
			]
		]
		either loc? [txt][text]
	]

	;	App-level event definitions
	on-focus: make function! [face] [true]
	on-unfocus: make function! [face] [true]
	;	Base face definition
	system/words/face: system/standard/face: make system/standard/face [
		loc: reduce ['data none 'text none 'effect none 'last-effect none]
	]
	rebface: make system/standard/face [
		init-offset: init-size: tool-tip: tool-tip-delay: cursor: color: edge: help: para: font: feel: alt-action: dbl-action: state-words: init: none
		dirty: false
		unfocus-action: focus-action: custom-action: true ; <<< Henrik added CUSTOM-ACTION, STATE-WORDS, HELP and DIRTY
		options: []
	]
	;	Base effect defintions
	effects: construct/with either exists? %effects.dat [load %effects.dat] [[]] make object! [
		window:			none
		font:			"Verdana"
	]
	;	Base sizes
	sizes: construct/with either exists? %sizes.dat [load %sizes.dat] [[]] make object! [
		cell:			4
		line:			cell * 5
		slider:			cell * 4
		font:			12				; pt size
		font-height:	none			; pixel height - set by widget init code
		margin:			4
		gap:			2
	]
	;	Base color definitions
	colors: construct/with either exists? %colors.dat [load %colors.dat] [[]] make object! [
		window:				236.233.216		; used by display.r
		widget:				244.243.238
		edge:				127.157.185
		edit:				white			; area, field, password, etc
		over:				gold			; active button, tab, splitter, etc
		menu:				49.106.197		; menu, popup highlight
		menu-item:			black
		menu-item-hilite:	white
		menu-item-ghosted:	140.140.140
		btn-up:				200.214.251
		btn-down:			216.232.255
		btn-text:			77.97.133
		true:				leaf			; radio-group, LED, check-box
		false:				red				; LED, check-box
		;BEG fixed by Cyphre, sponsored by Robert
		tooltip-bkg:		255.255.225
		tooltip-text:		0.0.0
		tooltip-edge:		0.0.0
		grid-hilite-row:	255.255.0
		grid-hilite-cell:	255.0.0
		grid-focus:			248.180.53
		grid-header:		200.214.251
		grid-header-over:	216.232.255
		;END fixed by Cyphre, sponsored by Robert
	]
	;	dialect words
	words: [
		after
		at
		button-size
		cursor
		data
		do
		edge
		effect
		feel
		field-size
		font
		help
		indent
		label-size
		margin
		on-focus
		on-unfocus
		on-reset
		on-resize
		on-translate
		options
		pad
		para
		rate
		return
		reverse
		space
		text-size
		tight
		;BEG by Cyphre, sponsored by Robert
		tool-tip
		tooltip-action
		text-align
		user-data
		left
		right
		center
		;END by Cyphre, sponsored by Robert
	]
	;widget names
	widget-names: none
	;BEG fixed by Cyphre, sponsored by Robert
	; list of tooltip sensitive widgets
	tooltip-sensitive: [
		anim
		area
		arrow
		bar
		box
		button
		chart-new
		check
		check-group
		chevron
		drop-list
		drop-tree
		edit-list
		field
		gauge
		help
		image
		input-grid
		label
		led
		led-group
		number-field
		password
		pie-chart
		progress
		radio-group
		slider
		spider
		splitter
		table
		text
		text-list
		title-group
		tool-bar
		xyplot
		warn
	]
	tool-tip-delay: 0:0:1

	set 'add-key-shortcut func [
		ctrl [logic!]
		shift [logic!]
		key [issue!]
		action [block!]
		/local f
	][
		either f: find/skip key-shortcuts reduce [ctrl shift key] 4 [
			change/only skip f 3 action
		][
			insert tail key-shortcuts reduce [ctrl shift key action]
		]
	]

	set 'remove-key-shortcut func [
		ctrl [logic!]
		shift [logic!]
		key [issue!]
	][
		remove/part find/skip key-shortcuts reduce [ctrl shift key] 4 4
	]
	
	os-win-metrics: switch/default fourth system/version [
		3	[8x27]	; Windows - XP theme height is 34px, Classic theme 27px. Better to use smaller value to avoid 'height jump'.
	][
		4x30		; Others
	]
	
	set 'resize-window make function! [
		"Force window to change its size."
		win-face [object!]
		new-size [pair!]
	][
		win-face/size: any [
			all [select win-face/options 'min-size max win-face/options/min-size - os-win-metrics new-size]
			new-size
		]
		show win-face
	]

	;END fixed by Cyphre, sponsored by Robert
	;	funcs
	span-resize: make function! [face [object!] delta [pair!] ratio-x [number!] ratio-y [number!] /local tmp] [
		if face/span = 'no-resize [exit]
		if face/span [
			tmp: face/old-size
			face/old-size: face/size
			any [face/init-size face/init-size: face/size]
			any [face/init-offset face/init-offset: face/offset]
			any [
				all [find face/span "WP" face/size/x: face/init-size/x * ratio-x]
				all [find face/span #"W" face/size/x: face/size/x + delta/x]
			]
			any [

				all [find face/span "HP" face/size/y: face/init-size/y * ratio-y]
				all [find face/span #"H" face/size/y: face/size/y + delta/y]
			]
			any [
				all [find face/span "XP" face/offset/x: face/init-offset/x * ratio-x]
				all [find face/span #"X" face/offset/x: face/offset/x + delta/x]
			]
			any[
				all [find face/span "YP" face/offset/y: face/init-offset/y * ratio-y]
				all [find face/span #"Y" face/offset/y: face/offset/y + delta/y]
			]
;			delta: face/size - any [tmp face/size]
			all [tmp delta: face/size - tmp]
		]
		;	pane could be an iterator function
		any [
			if block? get in face 'pane [foreach f face/pane [all [object? f span-resize f delta ratio-x ratio-y]]]
			if object? get in face 'pane [span-resize face/pane delta ratio-x ratio-y]
		]
		;BEG fixed by Cyphre
		;added on-resize global handler - useful for building resizing widgets
		if find first face 'on-resize [face/on-resize]
		;END fixed by Cyphre
	]
	;	Edit feel
	edit: #include %rebgui-edit.r
	if issue? :edit [edit: do bind load %rebgui-edit.r 'self]
	;	Widgets
	widgets: #include %rebgui-widgets.r
	if issue? :widgets [
		widgets: do bind load %rebgui-widgets.r 'self
		foreach widget sort read %widgets/ [insert tail widgets bind load join %widgets/ widget 'self]
	]
	widgets: make object! widgets
	;	Layout function
	name-widget: :set ; added by Ladislav to support the test-environment
	layout: #include %rebgui-layout.r
	if issue? :layout [layout: do bind load %rebgui-layout.r 'self]
	;	Display function
	display: #include %rebgui-display.r
	if issue? :display [display: do bind load %rebgui-display.r 'self]
	;	Requestors
	requestors: #include %rebgui-requestors.r
	if issue? :requestors [requestors: do bind load %rebgui-requestors.r 'self]
	
	;add event compression to make UI more responsible
	compress-events: make hash! [move offset scroll-line key scroll-page]
	
	system/ports/wait-list/1/awake: func [
		port
		/local event events type
	] bind [
		events: make block! 32 ;we need to copy here because port can be awaken in the middle of the function call (wake-event foction calls "do event")
		while [event: pick port 1] [
			either all [
				event/type = type
				find compress-events event/type
			][
				change back tail events event
			][
				insert tail events event
				type: event/type
			]
		]
		while [not tail? events][
			if wake-event events [return true]
			events: next events
		]
		false
	] in system/view 'self
]

enable: make function! [
	"Enable a widget."
	face [object! block!]
] [
	foreach f reduce either object? face [[face]] [face] [
		if 'disable = f/parent-face/type [
			f: f/parent-face
			f/pane/1/offset: f/offset
			f/pane/1/span: f/data
			change find f/parent-face/pane f f/pane/1
			show f/parent-face
		]
	]
]

disable: make function! [
	"Disable a widget."
	face [object! block!]
] [
	foreach f reduce either object? face [[face]] [face] [
		unless 'disable = f/parent-face/type [
			change find f/parent-face/pane f make ctx-rebgui/rebface [
				type: 'disable
				offset: f/offset
				size: f/size
				span: all [f/span copy f/span]
				pane: reduce [
					f
					make ctx-rebgui/rebface [
						size: f/size
						span: all [
							f/span
							case [
								all [find f/span #"H" find f/span #"H"] [#HW]
								find f/span #"H" [#H]
								find f/span #"W" [#W]
							]
						]
						effect: [merge colorize 224.224.224]
					]
				]
				data: all [f/span copy f/span]
				feel: action: none
			]
			f/offset: 0x0
			if f/span [
				remove find f/span #"X"
				remove find f/span #"Y"
			]
			show f/parent-face
		]
	]
]

;	add widget names to words
insert tail ctx-rebgui/words ctx-rebgui/widget-names: copy find first ctx-rebgui/widgets 'anim

set 'display get in ctx-rebgui 'display	; bind display function to global context
set 'show-focus get in ctx-rebgui/edit 'focus
set 'hide-focus get in ctx-rebgui/edit 'unfocus
system/view/screen-face/feel: none		; kill global events system (used by 'insert-event-func)
open-events								; needed in case we are running from rebface / enface
recycle									; free unused memory

;foreach word sort query/clear system/words [if value? word [print word]] halt

; any [none? system/script/parent system/script/parent/header halt]
