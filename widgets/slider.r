slider: make rebface [
	size:	5x50
	data:	0
	state-words: [data show?]
	; color mapping
	color:						colors/window
	arrow-box-color:			colors/btn-up
	arrow-triangle-color:		colors/btn-text
	arrow-triangle-down-color:	colors/btn-down
	dragger-color:				colors/btn-up
	dragger-down-color:			colors/btn-down
	slider-edge-color:			colors/btn-up
	edge: make default-edge [
		color: slider-edge-color
		size: 1x1
	]
	effect:	[
		draw [
			pen slider-edge-color fill-pen dragger-color box 0x0 10x10 ; dragger
			; arrow buttons
			fill-pen arrow-box-color box 0x0 0x0
			fill-pen arrow-box-color box 0x0 0x0
			fill-pen arrow-triangle-color triangle 0x0 0x0 0x0
			fill-pen arrow-triangle-color triangle 0x0 0x0 0x0
		]
	]
	; custom facets
	ratio:	0.1
	step:	0.05
	hold:	none
	state:	none
	flags:	none
	feel:	make default-feel [
		redraw: make function! [
			face act pos
			/local width state-blk freedom axis dragdom arrow-width arrows? together? draw-blk arrow-blk arrow-size axis-inv
		][
			if act = 'draw [
				; has anything changed ?
				if face/state <> compose state-blk: [(face/data) (face/size) (face/ratio) (face/flags)][
					width: min face/size/x face/size/y
					face/ratio: any [face/ratio 0.1]
						
					freedom: 1 - face/ratio
					axis: either face/size/y > face/size/x ['y]['x]
					axis-inv: either axis = 'x ['y]['x]
					dragdom: face/size/:axis - any [all [face/edge (face/edge/size/:axis * 2)] 0]
					arrow-width: 0
					;BEG fixed by Cyphre, sponsored by Robert
					if all [face/flags arrows?: find face/flags 'arrows] [
					;END fixed by Cyphre, sponsored by Robert
						arrow-width: min face/size/x face/size/y
						dragdom: dragdom - (2 * arrow-width)
						together?: find face/flags 'together
					]

					draw-blk: face/effect/draw

					arrow-blk: at draw-blk 8
					either arrows? [
						arrow-size: as-pair arrow-width - face/edge/size/x arrow-width - face/edge/size/x

						arrow-blk/4: either together? [dragdom * either axis = 'y [0x1][1x0]][0x0]
						arrow-blk/5: arrow-blk/4 + arrow-size - either axis = 'y [2x0][0x2]

						arrow-blk/9: dragdom + arrow-width * either axis = 'y [0x1][1x0]
						arrow-blk/10: arrow-blk/9 + arrow-size - either axis = 'y [2x0][0x2]

						arrow-blk/14: arrow-blk/4 + (width * 0.1 * either axis = 'y [4x2][2x4])
						arrow-blk/15: arrow-blk/4 + (width * 0.1 * either axis = 'y [1x7][7x7])
						arrow-blk/16: arrow-blk/4 + (width * 0.1 * either axis = 'y [7x7][7x1])

						arrow-blk/20: arrow-blk/9 + (width * 0.1 * either axis = 'y [4x8][8x4])
						arrow-blk/21: arrow-blk/9 + (width * 0.1 * either axis = 'y [7x3][3x1])
						arrow-blk/22: arrow-blk/9 + (width * 0.1 * either axis = 'y [1x3][3x7])
					][
						repeat pos [4 5 9 10 14 15 16 20 21 22][arrow-blk/:pos: 0x0]
					]

					draw-blk/6: 0x0
					draw-blk/6/:axis: (dragdom * freedom * min 1 max 0 face/data) + either together? [0][arrow-width]

					draw-blk/7: draw-blk/6 + width - 1 - any [all [face/edge (face/edge/size/:axis-inv * 2)] 0]
					draw-blk/7/:axis: (freedom * min 1 max 0 face/data) + face/ratio * (dragdom - 1) + either together? [0][arrow-width]

					draw-blk/7: max draw-blk/7 draw-blk/6 + as-pair sizes/cell * 2 sizes/cell * 2
					either none? face/state [ ; first show ?
						face/state: compose state-blk
						; (do not do face/action)
					][
						face/state: compose state-blk
						face/action face ; <- this could recurse (user code does show face), so make sure do this after updating face/state
					]
				]
			]
		]
		set-data: make function! [face [object!] data [number!] /local old][
			old: face/data
			face/data: min 1 max 0 data
			if face/data <> old [
				show face ; (face/action is done in redraw)
			]
		]
		engage: make function! [
			face act event
			/local freedom axis dragdom arrows? together? arrow-width offset more? page oft win-face
		][
			freedom: 1 - face/ratio
			axis: either face/size/y > face/size/x ['y]['x]
			dragdom: face/size/:axis
			arrow-width: 0
			;BEG fixed by Cyphre, sponsored by Robert
			if all [face/flags arrows?: find face/flags 'arrows] [
			;END fixed by Cyphre, sponsored by Robert
				arrow-width: min face/size/x face/size/y
				dragdom: dragdom - (2 * arrow-width)
				together?: find face/flags 'together
			]

			;patch of nasty offset bug in time event - by Cyphre
			oft: event/offset
			if all [act = 'time event/face = system/view/screen-face/pane/1] [
				win-face: find-window face
;				print ["oft" oft event/face/offset win-face/offset oft + (event/face/offset - win-face/offset)]
				oft: oft + (event/face/offset - win-face/offset)
			]

			offset: oft - either act = 'time [win-offset? face][0]
			offset: offset/:axis - either together? [0][arrow-width] ; offset in dragdom
			if find [over away] act [
				if all [
					number? face/hold ; dragger held ?
					freedom > 0 
				][
					set-data face (offset - face/hold / (dragdom * freedom))
				]
				exit
			]
			if find [down time] act [
				either act = 'down [face/rate: 2][
					all [
						face/rate
						face/rate: 16
					]
				]
				either all [ ; inside dragger?
					more?: offset >= (dragdom * (freedom * face/data))
					offset < (dragdom * ((freedom * face/data) + max face/ratio sizes/cell * 2 / dragdom))
				][
					if act = 'down [
						; clicked on dragger
						face/hold: offset - (dragdom * (freedom * face/data))
						face/effect/draw/4: face/dragger-down-color show face
					]
				][
					; outside dragger, a "page-click" or arrow button
					case [
						offset < 0 [
							; top or left arrow button
							if act = 'down [
								face/hold: 'top-arrow
								face/effect/draw/9: face/arrow-triangle-down-color show face
							]
							if face/hold = 'top-arrow [
								set-data face (face/data - face/step)
							]
						]

						all [together? offset > dragdom offset < (dragdom + arrow-width)][
							; top or left arrow button (together)
							if act = 'down [
								face/hold: 'top-arrow
								face/effect/draw/9: face/arrow-triangle-down-color show face
							]
							if face/hold = 'top-arrow [
								set-data face (face/data - face/step)
							]
						]

						offset > (dragdom + either together? [arrow-width][0]) [
							; bottom or right arrow button
							if act = 'down [
								face/hold: 'bottom-arrow
								face/effect/draw/14: face/arrow-triangle-down-color show face
							]
							if face/hold = 'bottom-arrow [
								set-data face (face/data + face/step)
							]
						]

						true [ ; default
							; must be a "page-click"
							if act = 'down [face/hold: 'page]
							if face/hold = 'page [
								page: any [all [freedom = 0 0] face/ratio / freedom]
								set-data face (face/data + either more? [page][- page])
							]
						]
					]
				]
			]
			if act = 'up [
				face/rate: none face/hold: none
				face/effect/draw/4: face/dragger-color
				face/effect/draw/9: face/effect/draw/14: face/arrow-box-color
				show face
				face/alt-action face
			]
		]
	]
	state-action: make function! [word value /local p] [
		set word :value
	]
	init: make function! [] [
		if number? data [data: min 1 max 0 data]
		flags: copy []
		if find options 'arrows [insert tail flags 'arrows]
		if find options 'together [insert tail flags 'together]
		if find options 'ratio [ratio: select options 'ratio]
	]
]
