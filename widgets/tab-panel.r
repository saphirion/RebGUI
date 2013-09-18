;	widget
;		data (current pane# / tab# + 1)
;		pane
;			panel (pane/1)
;				pane (active tab spec)
;			tabs (pane/2 onwards)
;				data (tab spec)
;				resize (original size)

tab-panel: make rebface [
	size:	-1x-1
	pane:	[]
	feel:	make default-feel [
		redraw: make function! [face act pos] [
			if act = 'show [face/pane/1/size: face/size - as-pair 0 sizes/line]
		]
	]
	edge-color:			colors/edge
	over-color:			colors/over
	background-color:	colors/widget
	tab-color:			colors/widget
	selected: make function! [] [pane/:data/text]
	init:	make function! [/local p tmp-size tab-offset last-tab trigger] [
		p: self
		tmp-size: 0x0
		;	create main display area
		insert pane make rebface [
			offset: as-pair 0 sizes/line
			color: p/background-color
			edge: default-edge
		]
		;	add tabs
		tab-offset: 0x0
		foreach [title spec] data [
			either title = 'action [
				trigger: make function! [face /local var] spec
			][
				insert tail pane make rebface [
					offset:	tab-offset
					size:	as-pair 1 sizes/line
					pane:	[]
					text:	title
					color:	p/tab-color
					action:	any [:trigger get in p 'action]
					effect:	reduce ['round p/edge-color 5 'draw copy []]
					resize:	0x0
					font:	make default-font [align: 'center]
					para:	default-para
					feel:	make default-feel [
						over: make function! [face act pos] [
							either act [
								insert face/effect/draw compose [	; compose required for AGG betas
									pen (p/over-color)
									line 3x1 (as-pair face/size/x - 4 1)
									line 2x2 (as-pair face/size/x - 3 2)
									line 1x3 (as-pair face/size/x - 2 3)
								]
								show face
							][
								if face/parent-face/pane/1/pane <> face/data [	; clear unless selected
									clear face/effect/draw
									show face
								]
							]
						]
						engage: make function! [face act event /local pf old-face] [
							if act = 'down [
								pf: face/parent-face
								old-face: pick pf/pane pf/data			; find previous tab
								if old-face = face [exit]
								clear face/effect/draw
								old-face/resize: pf/size				; remember last size
								old-face/size: old-face/size - 0x1		; deflag old
								clear old-face/effect/draw
								face/size: face/size + 0x1				; flag new
								face/feel/over face true 0x0
								pf/data: index? find pf/pane face		; set new pane#
								pf/pane/1/pane: face/data				; init tab panel
								if pf/size <> face/resize [				; recursive resize
									span-resize pf/pane/1 pf/size - face/resize 1 1
									face/resize: pf/size
								]
								edit/unfocus							; unfocus previous
								either get in face 'action [
									if face/action pf/pane/1 [show pf]	; perform action if any, and show if it returns TRUE
								][
									show pf								; perform SHOW if no action is available
								]
							]
						]
					]
				]
				trigger: none
				last-tab: last pane
				last-tab/size/x: sizes/line + first size-text last-tab	; set tab title width
				last-tab/data: layout/only spec							; generate tab spec into tab data
				;	get size
				last-tab/resize/x: either negative? size/x [tmp-size/x: max tmp-size/x last-tab/data/size/x] [size/x]
				last-tab/resize/y: either negative? size/y [tmp-size/y: max tmp-size/y sizes/line + last-tab/data/size/y] [size/y]
				last-tab/data: last-tab/data/pane
				tab-offset/x: tab-offset/x + last-tab/size/x			; set offset for next tab title
			]
		]
		if negative? size/x [size/x: tmp-size/x + (2 * pane/1/edge/size/x)]
		if negative? size/y [size/y: tmp-size/y + (2 * pane/1/edge/size/y)]
		pane/2/size: pane/2/size + 0x1		; flag 1st tab
		data: 2								; set pane#
		pane/1/pane: pane/2/data			; init tab panel
		pane/2/feel/over pane/2 true 0x0	; flag first as active
		p/action: none
	]
]