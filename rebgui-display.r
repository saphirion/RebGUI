REBOL [
	Title:		"RebGUI display function"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.1
	Date:		26-Mar-2006
	Purpose:	"Renders a window from a block of widgets, attributes and keywords."
	History: {
		0.3.0	Merged into ctx-rebgui
				Removed color keyword from parse - use "do [face/color: red]" instead
				Simplified init handling logic
		0.3.1	Fixed view-face feel init
				Removed /offset refinement
		0.3.2	Split parser / layout logic out
				Moved display function to rebgui.r
				Added keycode handler to window feel
		0.3.3	-
		0.3.4	Removed misplaced ":"
		0.3.5	Fixed min-size behaviour
		0.3.6	Removed redundant 'f word from window detect function
				Dialog handler reworked
		0.3.7	Hide-popup on close event
				Quit when 1st pane face is closed
				Prompt when more than one window open
				Added close refinement and handler
		0.3.8	-
		0.3.9	returns view-face
				Added position refinement
				Fixed close logic and replaced system/view references with view*

		0.4.0	Removed rendundant size-1, size-2 words
		0.4.1	Replaced func/function/does/has with make function!
	}
]

make function! [
	"Displays widgets in a centered window with a title."
	title [string!]		"Window title"
	spec [block! object!]		"Block of widgets, attributes and keywords"
	/no-resize			"force window to not resize"
	/maximize			"Maximize window"
	/min-size			"Specify a minimum OS window resize size"
		size [pair!]		"Minimum display size (including window border / title)"
	/scroll				"Handle scroll-line and scroll-page events"
		scroller [none! block!]	"The scroll handler block"
	/close				"Handle window close event"
		closer [none! block!]		"The close handler block"
	; >>> Henrik
	/custom				"Handle window events"
		custom-event [none! block!]	"The event handler block"
	; <<< Henrik
	/dialog				"Displays widgets in a modal popup window (ignores all other refinements)"
	/no-hide			"Modal window does not hide previous (used by requestors)"
	/position			"Use an alternative positioning scheme"
		offset [pair! word! block!]	"Offset pair or one or more of 'left 'right 'top 'bottom 'first 'second"
	/local view-face custom-action
][
	;	force display, even when update? is turned off
	enable-show/force none
	;	prevent duplicate display being opened
	foreach window view*/screen-face/pane [
		if title = window/text [return]
	]

	;	parse block spec into face object
	view-face: either object? spec [spec][layout spec]
	view-face/text: title
	all [view-face/loc view-face/loc/text: none]

	unless view-face/init-size [view-face/init-size: view-face/size]

	;	position?
	either position [
		either pair? offset [
			view-face/offset: max 0x0 offset
		][
			foreach word compose [(offset)] [
				if word = 'first [word: either view*/screen-face/size/x > view*/screen-face/size/y ['left] ['top]]
				if word = 'second [word: either view*/screen-face/size/x > view*/screen-face/size/y ['right] ['bottom]]
				switch word [
					left	[view-face/offset/x: max 0 view*/screen-face/size/x / 2 - view-face/size/x / 2]
					right	[view-face/offset/x: max 0 view*/screen-face/size/x / 2 - view-face/size/x / 2 + (view*/screen-face/size/x / 2)]
					top		[view-face/offset/y: max 0 view*/screen-face/size/y / 2 - view-face/size/y / 2]
					bottom	[view-face/offset/y: max 0 view*/screen-face/size/y / 2 - view-face/size/y / 2 + (view*/screen-face/size/y / 2)]
				]
			]
		]
	][
		view-face/offset: max 0x0 view*/screen-face/size - view-face/size / 2		
	]

	;	make every window after 1st a child of 1st - parent option broken in view 1.3.1, but fixed in 1.3.2
	unless empty? system/view/screen-face/pane [
		either system/view/screen-face/pane/1/type <> 'splash [
			insert tail view-face/options reduce ['parent first system/view/screen-face/pane]
		] [unview]
	]

	unless no-resize [
		;	resize window?
		either any [min-size maximize] [
			insert tail view-face/options 'resize
			if maximize [view-face/changes: 'maximize]
		][
			;	do any sub-faces require resize?
			foreach sub-face view-face/pane [
				if sub-face/span [insert tail view-face/options 'resize break]
			]
		]
	]
	
	;	min-size?
	if find view-face/options 'resize [
		insert tail view-face/options 'min-size
		insert tail view-face/options either min-size [size] [
			os-win-metrics + view-face/init-size 
		]
	]

	;	add window feel to handle scroll, resize, focus and / or keycodes
	if scroller [view-face/action: make function! [offset event /local var] scroller]
	if closer [view-face/alt-action: make function! [face /local var] closer]
	; >>> Henrik
	if custom-event [
		view-face/custom-action: make function! [face event /local var] custom-event
	]

	; <<< Henrik
	view-face/feel: make any [view-face/feel widgets/default-feel] [
		orig-size: view-face/size
		;BEG fixed by Cyphre, sponsored by Robert
		last-hface: none
		last-focus: none
		tool-tip-time: now/time/precise
		tool-tip: make face [
			offset: -10000x-10000
			color: ctx-rebgui/colors/tooltip-bkg
			rate: any [all [empty? system/view/screen-face/pane 24:00:00] none]
			visible?: false
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
		insert tail view-face/pane tool-tip
	
		;END fixed by Cyphre, sponsored by Robert
		detect: make function! [face event /local fac result delta show-tt? tip-face win-face tt oft hface cur] [
			;BEG fixed by Cyphre, sponsored by Robert
			if all [event/type <> 'time ctx-rebgui/mouse-offset <> event/offset] [
				tool-tip-time: now/time/precise
				tool-tip/visible?: false
				tool-tip/offset: -10000x-10000
				show-tt?: true
			]
			if all [
				win-face: fac: active-win
				not win-face/feel/tool-tip/visible?
				any [
					1 = length? view*/screen-face/pane				
					win-face <> view*/screen-face/pane/1
					foreach f next find view*/screen-face/pane win-face [
						oft: face/offset - f/offset + event/offset
						unless any [
							oft/x > f/size/x
							oft/y > f/size/y
							oft/x < 0
							oft/y < 0
						][
							break/return false
						]
						true
					]
				]
			][
				delta: now/time/precise - win-face/feel/tool-tip-time			
				oft: face/offset - win-face/offset + event/offset
				while [
					fac: find-face oft fac ctx-rebgui/tooltip-sensitive
				][
					all [
						fac/tool-tip
						delta >= any [fac/tool-tip-delay tool-tip-delay]
						tip-face: fac
					]
					unless fac: fac/pane [break] 					
				]

				if tip-face [
					result: true
					tt: win-face/feel/tool-tip
					tt/pane: none
					all [tt/loc tt/loc/text: none]

					if block? tip-face/tool-tip/2 [
						result: do func [face tool-tip event] tip-face/tool-tip/2 tip-face tt event 
					]

					either all [
						block? tip-face/tool-tip/1
						not empty? tip-face/tool-tip/1
					][
						tt/pane: layout/only/origin tip-face/tool-tip/1 0x0
						tt/size: tt/pane/size + 2
						tt/pane/effect: 'merge
						tt/text: tt/pane/color: none
					][
						either all [
							tip-face/tool-tip/1
							not empty? tip-face/tool-tip/1
						][
							tt/text: translate tip-face/tool-tip/1
							tt/size: 6 + size-text make system/standard/face [
								font: tt/font
								para: tt/para
								size: 1000x100
								text: tt/text
							]
						][
							tt/text: none
							tt/size: 0x0
						]
					]
					if all [
						tt/parent-face
						block? tt/parent-face/pane
					][
						remove find tt/parent-face/pane tt
					]
					insert tail win-face/pane tt
					if result [
						show-tt?: true
						tt/offset: min win-face/size - tt/size - 2 max 2x2 oft + either win-face/size/y - 22 - tt/size/y < oft/y [5x-22][0x22]
						tt/visible?: true
					]
				]
			]
			all [show-tt? win-face show win-face/feel/tool-tip]
			;END fixed by Cyphre, sponsored by Robert

			if find [down alt-down] event/type [
					unless empty? system/view/pop-list [
						use [tmp][
							tmp: true
							foreach pf system/view/pop-list [
								if  any [
									pf/type = 'choose
									pf = event/face
									all [pf/parent-face event/face = find-window pf]
								][
									tmp: false
									break
								]
							]
							if tmp [
								system/view/pop-face/changes: 'activate
								show system/view/pop-face
								return none
							]
						]
					]
			
			]
			switch event/type [
				;BEG fixed by Cyphre, sponsored by Robert
				down [
					if all [
							view*/pop-face
							not all [in view*/pop-face 'opts block? view*/pop-face/opts find view*/pop-face/opts 'no-close-outside]
							not within? event/offset either view*/pop-face/parent-face [win-offset? view*/pop-face][view*/pop-face/offset - event/face/offset] view*/pop-face/size
					][
						unless all [
								fac: find-face event/offset event/face ctx-rebgui/widget-names
								fac/options 
								find fac/options 'no-close-popup
						][
							either all [
								in view*/pop-face 'opts
								find view*/pop-face/opts 'menu
							][
								ctx-rebgui/widgets/hide-menu
							][
								hide-popup
							]
						]
					]
					if all [
						ctx-rebgui/help-mode
						get in ctx-rebgui 'help-function
					][
						if hface: find-face/only event/offset face none func [face][all [in face 'help face/help]] [
							ctx-rebgui/help-function ctx-rebgui/help-mode hface
							set-help-mode none
							return none
						]
					]
				]
				alt-up [
					foreach [f data] ctx-rebgui/context-menus [
						if word? f [f: get f]
						if all [
							within? event/offset win-offset? f f/size
							f = find-face event/offset event/face all [f/type reduce [f/type]]
						][
							ctx-rebgui/widgets/show-menu/no-wait event/face event/offset :data
							break
						]
					]
				]
				up [
					if view*/focal-face [
						unless any [
							all [
								in view*/focal-face 'focal-target
								within? event/offset win-offset? view*/focal-face/focal-target view*/focal-face/focal-target/size
							]
							within? event/offset win-offset? view*/focal-face view*/focal-face/size
						][
							ctx-rebgui/edit/unfocus/force
						]
					]
				]
				;END fixed by Cyphre, sponsored by Robert
				key				[edit/process-keystroke face event]
				move			[ctx-rebgui/mouse-offset: event/offset]
				scroll-line	[face/custom-action ctx-rebgui/mouse-offset event]
				scroll-page	[face/custom-action ctx-rebgui/mouse-offset event]
				minimize	[
					face/custom-action face event ; <<< Henrik
				]
				restore		[
					face/custom-action face event ; <<< Henrik
				]
				offset 		[
					face/custom-action face event ; <<< Henrik
				]
				maximize	[
					face/custom-action face event ; <<< Henrik
				]
				active		[
					active-win: face
					all [
						system/view/pop-face 
						in system/view/pop-face 'blocking?
						not system/view/pop-face/blocking?
						ctx-rebgui/widgets/hide-menu
					]
					all [
						last-focus
						ctx-rebgui/edit/focus/force last-focus
					]
					
					face/custom-action face event ; <<< Henrik
				]
				inactive	[
					active-win: none
					last-focus: all [
						view*/focal-face
						event/face = find-window view*/focal-face
						view*/focal-face
					]
					all [
						last-focus
						ctx-rebgui/edit/unfocus/force
					]
					face/custom-action face event ; <<< Henrik
				]
				resize		[ ; /resize
					if face/size <> orig-size [
						span-resize face face/size - orig-size face/size/x / face/init-size/x face/size/y / face/init-size/y
					]
					;	refresh
					show face
					face/custom-action face event ; <<< Henrik
					orig-size: face/size
				]
				close		[
					hide-popup
					if all [get in face 'alt-action not face/alt-action face][return]
					if face = pick view*/screen-face/pane 1 [
						unless 1 = length? view*/screen-face/pane [
							if question "Do you really want to quit this application?" [quit]
							return
						]
					]
				]
			]

			;handle mouse pointer (in active window only)
			if all [
				event/type <> 'time
				active-win = face
			][
				either ctx-rebgui/help-mode [
					cursor 'help
					if get in ctx-rebgui 'help-face-function [
						either hface: find-face/only event/offset face none func [face][all [in face 'help face/help]][
							ctx-rebgui/help-face-function event/offset hface
						][
							if last-hface [
								ctx-rebgui/help-face-function event/offset none
							]
						]
					]
					last-hface: hface
				][
					any [
						all [
							cur: find-face/only event/offset face none func [face][all [in face 'cursor face/cursor]]
							cursor any [cur/cursor 'arrow]
						]
						cursor 'arrow
					]
				]
			]
			
			event
		]
	]

	span-resize view-face 0x0 1.0 1.0
	
	if dialog [
		unless no-hide [
			hide-popup ; workaround until /away and parent options work
		]
;		view-face/feel: system/view/window-feel
		show-popup view-face
		do-events
		exit
	]
	view/new view-face
]
