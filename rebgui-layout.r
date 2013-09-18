REBOL [
	Title:		"RebGUI layout function"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.17
	Date:		25-May-2006
	Purpose:	"Parse / layout a block of widgets, attributes and keywords."
	History: {
		0.3.2	Split off from %rebgui-display.r
				Removed default-span and default-size keywords
				Added support for keycodes
				Attribute of #[false] for show? now works (Graham)
		0.3.3	-
		0.3.4	Added options attribute
		0.3.5	Added sort to span so directives are in #HWXY order as required by some widgets
		0.3.5	Added support for right-click and double-click actions
		0.3.6	Added alt-action & dbl-action support
		0.3.7	Fixed 'reverse logic where differing size/x were involved
				Added max-height where display is made up purely of 'at positioning
				Removed now redundant 'line-height calculations
				Added 'after keyword
		0.3.8	'at rule now correctly resets max-height
				Added support for on-focus / on-unfocus keywords
		0.3.9	Initial margin-size and spacing-size now derived from widgets settings
				layout/only now returns face not face/pane (as group-box and tab-panel require face/size)
				view-face is now activate-on-show by default
				Added button-size, field-size, label-size and text-size keywords

		0.4.0	Removed redundant size-1, size-2 words
		0.4.1	Renamed spacing-size to gap-size
				Changed widgets/unit-size references to sizes/cell
				Replaced func/function/does/has with make function!
				attribute-data and data now handle false correctly
		16		Added reduce/only logic to evaluate words / paths without need for compose
		17		Added opt clause to handle ()
	}
]

make function! [
	spec [block!]	"Block of widgets, attributes and keywords"
	/only			"Do not change face offset"
	/origin 		"Set layout origin"
		pos [pair!]
	/local
	view-face
	margin-size indent-width xy gap-size max-width max-height last-widget widget-face arg arg2 append-widget left-to-right?
	after-count after-limit
	here
	word
	widget
	button-size
	field-size
	label-size
	text-size
	text-align ;by Cyphre, sponsored by Robert
	attribute-size
	attribute-span
	attribute-text
	attribute-color
	attribute-image
	attribute-effect
	attribute-data
	attribute-user-data
	attribute-tool-tip
	attribute-cursor
	attribute-edge
	attribute-font
	attribute-para
	attribute-feel
	attribute-rate
	attribute-action
	attribute-alt-action
	attribute-dbl-action
	attribute-focus-action
	attribute-unfocus-action
	attribute-reset-action
	attribute-resize-action
	attribute-translate-action
	attribute-show?
	attribute-options
	attribute-keycode
][
	margin-size: xy:	any [pos sizes/cell * as-pair sizes/margin sizes/margin]
	gap-size:			sizes/cell * as-pair sizes/gap sizes/gap

	indent-width:		0
	max-width:			xy/x
	max-height:			xy/y

	left-to-right?:		true
	after-count:		1
	after-limit:		1000000

	view-face: make rebface [
		pane:		copy []	; copy needed to prevent "face in more than one pane" errors
		color:		colors/window
		effect:		effects/window
		options:	copy [activate-on-show]
		keycodes:	copy []
		reset: make function! [
			/widgets widget-types [block! none!] "block of 'sensitive widgets' or none"
		][
			reset-widgets/types self widget-types
		]
	]

	word:
	widget:
	button-size:
	field-size:
	label-size:
	text-size:
	text-align: ;by Cyphre, sponsored by Robert
	attribute-size:
	attribute-span:
	attribute-text:
	attribute-color:
	attribute-image:
	attribute-effect:
	attribute-data:
	attribute-user-data:
	attribute-tool-tip:
	attribute-cursor:
	attribute-edge:
	attribute-font:
	attribute-help:
	attribute-para:
	attribute-feel:
	attribute-rate:
	attribute-action:
	attribute-alt-action:
	attribute-dbl-action:
	attribute-focus-action:
	attribute-unfocus-action:
	attribute-reset-action:
	attribute-resize-action:
	attribute-translate-action:
	attribute-show?:
	attribute-options:
	attribute-keycode: none

	;	append widgets and set attributes

	append-widget: make function! [] [
		if widget [
			;	'type is used in place of 'val to prevent 'val becoming an attribute
			insert tail view-face/pane make get in widgets widget [
				init-offset: offset:	xy
				init-size: size:	sizes/cell * any [
					if attribute-size [either pair? attribute-size [attribute-size] [as-pair attribute-size size/y]]
					if widget = 'bar [as-pair max-width - margin-size/x / sizes/cell size/y]
					if all [button-size widget = 'button] [either pair? button-size [button-size] [as-pair button-size size/y]]
					if all [field-size any [widget = 'field widget = 'number-field]] [either pair? field-size [field-size] [as-pair field-size size/y]]
					if all [label-size widget = 'label] [either pair? label-size [label-size] [as-pair label-size size/y]]
					if all [text-size widget = 'text] [either pair? text-size [text-size] [as-pair text-size size/y]]
					size
				]
				span:		any [attribute-span span]
				text:		any [attribute-text text] [text: copy text]
				effect:		any [attribute-effect effect]
				data:		either any [:attribute-data = false data = false] [false] [any [:attribute-data data]]
				user-data:	:attribute-user-data
				rate:		any [attribute-rate rate]
				show?:		either not none? attribute-show? [attribute-show?] [show?]
				options:	any [attribute-options options]
				color:		any [attribute-color color]
				image:		any [attribute-image image]

				;	do we need I8N support for this widget?
				;		we need it if TEXT is a I8N ID of the form "id000105"
				unless any [
					all [
						series? text
						find/match text "<loc>"
					]
					all [
						block? effect
						find effect 'draw
					]					
				][loc: none]

;				text: translate text
;				data: translate data
comment {				if locale*/words [
					if all [string? text type: select locale*/words text] [text: type]
					if all [string? data type: select locale*/words data] [data: type]
					if block? data [
						foreach item data [
							if all [string? item type: select locale*/words item] [insert clear item type]
						]
					]
				]
}
				;	tool-tip
				if attribute-tool-tip [tool-tip: attribute-tool-tip]
				; mouse pointer
				if attribute-cursor [cursor: attribute-cursor]
				; help
				if attribute-help [help: attribute-help]
				;	edge / font / para / feel objects
				if attribute-edge [edge: make any [edge widgets/default-edge] attribute-edge]
				if attribute-font [font: make any [font widgets/default-font] attribute-font]
				if text-align [font: make font [align: text-align]] ;by Cyphre, sponsored by Robert
				if attribute-para [para: make any [para widgets/default-para] attribute-para]
				if attribute-feel [feel: make any [feel widgets/default-feel] attribute-feel]
				;	focus / unfocus actions
				focus-action: either attribute-focus-action [make function! [face /local var] attribute-focus-action] [either function? :focus-action [:focus-action][:on-focus]]
				unfocus-action: either attribute-unfocus-action [make function! [face /local var] attribute-unfocus-action] [either function? :unfocus-action [:unfocus-action][:on-unfocus]]
				reset-action: make function! [face] either attribute-reset-action [
					  attribute-reset-action
				][
					any [all [value? 'reset-action second :reset-action] [none]]
				]
				on-resize: either attribute-resize-action [
					 funct [] bind attribute-resize-action 'self
				][
					any [all [value? 'on-resize :on-resize] [none]]
				]
				reset: does [
					reset-action self
				]
				;	on-translate action
				translate-action: either attribute-translate-action [
					  make function! [face] attribute-translate-action
				][
					any [all [value? 'translate-action :translate-action] none]
				]
				;	action block and associated engage feel
				if any [attribute-action attribute-alt-action attribute-dbl-action] [
					all [attribute-action action: make function! [face /local var] attribute-action]
					all [attribute-alt-action alt-action: make function! [face /local var] attribute-alt-action]
					all [attribute-dbl-action dbl-action: make function! [face /local var] attribute-dbl-action]
					;	append or new?
					either feel [
						;	append if not already defined
						unless function? get in feel 'engage [
							feel: make feel [
								engage: make function! [face act event] [
									case [
										event/double-click	[face/dbl-action face]
										act = 'down			[face/action face]
										act = 'alt-down		[face/alt-action face]
									]
								]
							]
						]
					][
						feel: make widgets/default-feel [
							engage: make function! [face act event] [
								case [
									event/double-click	[face/dbl-action face]
									act = 'down			[face/action face]
									act = 'alt-down		[face/alt-action face]
								]
							]
						]
					]
				]
				;	set type to its real value
				type: widget
			]
			last-widget: last view-face/pane
			;	keycode attached?
			if attribute-keycode [
				insert tail view-face/keycodes reduce [attribute-keycode last-widget]
			]
			;	any init required?
			last-widget/init		; execute
			last-widget/init: none	; free
			;	1st reverse item?
			unless left-to-right? [
				last-widget/offset/x: last-widget/offset/x - last-widget/size/x
			]
			unless last-widget/type = 'timer [
				last-widget/type 
				xy: last-widget/offset
			
				;	max vertical size
				max-height: max max-height xy/y + last-widget/size/y
				;	horizontal pos adjustments
				if left-to-right? [
					xy/x: xy/x + last-widget/size/x
					max-width: max max-width xy/x
				]
				;	after limit reached?
				after-count: either after-count < after-limit [
					;	spacing
					xy/x: xy/x + either left-to-right? [gap-size/x] [negate gap-size/x]
					after-count + 1
				][
					xy: as-pair margin-size/x + indent-width max-height + gap-size/y
					after-count: 1
				]
			]
			if :word [name-widget :word last-widget] ; ladislav, test-env support
			word:
			widget:
			attribute-size:
			attribute-span:
			attribute-text:
			attribute-color:
			attribute-image:
			attribute-effect:
			attribute-data:
			attribute-user-data:
			attribute-tool-tip:
			attribute-cursor:
			attribute-edge:
			attribute-font:
			attribute-help:
			attribute-para:
			attribute-feel:
			attribute-rate:
			attribute-action:
			attribute-alt-action:
			attribute-dbl-action:
			attribute-focus-action:
			attribute-unfocus-action:
			attribute-reset-action:
			attribute-resize-action:
			attribute-translate-action:
			attribute-show?:
			attribute-options:
			attribute-keycode: none
		]
	]

	parse reduce/only spec words [ ; AGT 25-May-2006
		any [
			opt [here: set arg paren! (here/1: do arg) :here] [ ; AGT 25-May-2006
			'return (
				append-widget
				xy: as-pair margin-size/x + indent-width max-height + gap-size/y
				left-to-right?: true
				after-limit: 1000000
			)
		|	'reverse (
				append-widget
				xy: as-pair max-width max-height + gap-size/y
				left-to-right?: false
				after-limit: 1000000
			)
		|	'after set arg integer!	(
				;	return unless this is first widget
				if all [xy/x = (margin-size/x + indent-width) xy/y <> margin-size/y] [
					append-widget
					xy: as-pair margin-size/x + indent-width max-height + gap-size/y
				]
				after-count: 1
				after-limit: arg
			)
		|	'button-size [set arg integer! | set arg pair! | | set arg none!] (button-size: arg)
		|	'field-size [set arg integer! | set arg pair! | | set arg none!] (field-size: arg)
		|	'label-size [set arg integer! | set arg pair! | | set arg none!] (label-size: arg)
		|	'text-size [set arg integer! | set arg pair! | | set arg none!] (text-size: arg)
		|	'text-align set arg word! (	if find [left right center] arg [text-align: arg]) ;by Cyphre, sponsored by Robert
		|	'pad set arg integer!	(
				append-widget
				;BEG fixed by Cyphre, sponsored by Robert
				arg: either left-to-right? [arg * sizes/cell] [negate arg * sizes/cell]
				either any [all [after-count = 1 not empty? view-face/pane] after-limit = 1] [
					xy/y: xy/y + arg
				][
					xy/x: xy/x + arg
				]
				;END fixed by Cyphre, sponsored by Robert
			)
		|	'do set arg block!		(view-face/init: make function! [face /local var] arg)
		|	'margin set arg pair!	(append-widget margin-size: xy: arg * sizes/cell)
		|	'indent set arg integer! (
				append-widget
				indent-width: arg * sizes/cell
				xy/x: margin-size/x + indent-width
			)
		|	'space set arg pair!	(append-widget gap-size: arg * sizes/cell)
		|	'tight					(append-widget margin-size: xy: gap-size: 0x0)
		|	'at set arg pair!		(append-widget max-height: 0 xy: arg * sizes/cell + margin-size after-limit: 1000000)
		|	'effect [set arg word! | set arg block!]	(attribute-effect: arg)
		|	'options set arg [block! | lit-word!] (
			arg: either word? arg [
				get arg
			][
				copy arg
			]
			attribute-options: arg
		)
		|	'data set arg any-type!						(if get-word? arg [arg: get arg] attribute-data: :arg)
		|	'user-data set arg any-type!				(attribute-user-data: :arg)
;		|	'data set arg any-type!						(attribute-data: either block? arg [reduce/only arg words] [arg])
		|	'edge set arg block!						(attribute-edge: arg)
		|	'font set arg block!						(attribute-font: arg)
		|	'para set arg block!						(attribute-para: arg)
		|	'feel set arg block!						(attribute-feel: arg)
		|	'on-focus set arg block!					(attribute-focus-action: arg)
		|	'on-unfocus set arg block!					(attribute-unfocus-action: arg)
		|	'on-reset set arg block!					(attribute-reset-action: arg)
		|	'on-resize set arg block!					(attribute-resize-action: arg)
		|	'on-translate set arg block!				(attribute-translate-action: arg)
		|	'rate [set arg integer! | set arg time!]	(attribute-rate: arg)
		|	'tool-tip [set arg string! | set arg block!] (arg2: none) opt ['tooltip-action set arg2 block!] (attribute-tool-tip: reduce [arg arg2])
		|	'help [set arg lit-word! | set arg block!]  (attribute-help: arg)
		|	'cursor set arg lit-word!					(attribute-cursor: arg)
		|	[set arg integer! | set arg pair!]			(attribute-size: arg)
		|	set arg issue!								(attribute-span: arg)
		|	set arg string!								(attribute-text: arg)
		|	set arg tuple!								(attribute-color: arg)
		|	set arg image!								(attribute-image: arg)
		|	set arg file!								(attribute-image: load arg)
		|	set arg block!								(
															case [
																none? attribute-action [attribute-action: arg]
																none? attribute-alt-action [attribute-alt-action: arg]
																none? attribute-dbl-action [attribute-dbl-action: arg]
															]
														)
		|	set arg logic!								(attribute-show?: arg)
		|	set arg char!								(attribute-keycode: arg)
		|	set arg set-word!							(append-widget word: :arg)
;		|	set arg word!								(either in widgets arg [append-widget widget: arg] [attribute-color: get arg])
		|	set arg word!								(append-widget widget: arg) ; AGT 25-May-2006
		]]
	]

	append-widget

	;	any post-placement init2 required? (see splitter widget for an example)
	foreach widget view-face/pane [
		if in widget 'init2 [
			widget/init2 view-face	; execute
			widget/init2: none		; free
		]
	]

	;	any main init to do?
	if function? get in view-face 'init [
		view-face/init view-face	; execute
		view-face/init: none		; free
	]

	view-face/size: margin-size + as-pair max-width max-height

	unless only [
		;	center-face if no offset provided
		if zero? view-face/offset [
			view-face/offset: max 0x0 view*/screen-face/size - view-face/size / 2
		]
	]

	view-face
]
