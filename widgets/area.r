area: make rebface [
	size:	50x25
	text:	""
	cursor: 'i-shape
	edge:	default-edge
	font:	make default-font [valign: 'top]
	para:	make default-para-wrap [margin: as-pair sizes/slider + 2 2]
	editable?: true
	selectable?: true
	reset-action: func [face] [
		face/text: copy ""
		face/line-list: 0
		face/data: 0
		if found? face/loc [face/loc/text: copy ""]
		show face
	]
	feel:	make edit/feel [
		redraw: func [face act pos /local height total visible] [
			if act = 'show [
				; check for size change and resize scroller
				if face/size <> face/old-size [
					face/pane/offset/x: max -1 (face/size/x - face/pane/size/x - 1)
					face/pane/size/y: face/size/y
				]

				if any [
					face/text-y <> height: second size-text face  ;	height of text changed ?
					face/size <> face/old-size  ; size changed ?
				][
					face/text-y: height

					total: face/text-y
					visible: face/size/y - (edge/size/y * 2) - para/origin/y - para/indent/y

					face/pane/ratio: min 1 (visible / total)

					; update scroller step
					face/pane/step: either visible < total [min 1 (sizes/font-height / (total - visible))][0]
				]
				;	Only update slider/data if scroll was caused by a key (not by slider itself). Avoids recursion.
				if all [face/pane/ratio < 1 face/key-scroll?] [

				do bind [
					; Update slider dragger position to reflect para/scroll/y
					; para/scroll is relative to  edge/size + para/origin + (para/indent * 0x1)

					total: text-y
					visible: size/y - (edge/size/y * 2) - para/origin/y - para/indent/y
					pane/data: - para/scroll/y / (total - visible)

				] face

				face/key-scroll?: false
				]
			]
		]
	]
	esc:	none
	undo:	make block! 20
	text-y:	none
	key-scroll?: false	; this is set to true by edit/edit-text to bypass slider action
	init:	make function! [/local p] [
		if find options 'no-feel [feel: none]
		color: either find options 'info [selectable?: editable?: false colors/widget] [colors/edit]
		para: make para [] ; avoid shared para object for scrollable input widget
		font: make font [] ; avoid shared font object for allowing individual font styles per area
		edge: make edge [] ; avoid shared edge object for allowing individual edge styles per area
		p: self
		text-y: second size-text self
		if negative? size/x [size/x: 1000000 size/x: 4 + first size-text self]
		if negative? size/y [size/y: 1000000 size/y: 8 + text-y]
		pane: make slider [
			offset:	as-pair p/size/x - sizes/slider - 1 -1
			size:	as-pair sizes/slider p/size/y
			span:	case [
				none? p/span	[none]
				find p/span #HW	[#XH]
				find p/span #H	[#H]
				find p/span #W	[#X]
			]
			options:	[arrows]
			action:	func [face /local visible] [
				;	Only update slider/data if scroll was caused by a key (not by slider itself). Avoids recursion.
				unless parent-face/key-scroll? [
					visible: (parent-face/size/y - (parent-face/edge/size/y * 2) - parent-face/para/origin/y - parent-face/para/indent/y)
					parent-face/para/scroll/y: negate parent-face/text-y - visible * data
					if all [
						view*/caret
						parent-face = view*/focal-face
					][
						; Keep caret inside the visible part of the area
						view*/caret: offset-to-caret parent-face min max
							(caret-to-offset parent-face view*/caret)	; get the current position of the caret
							(sizes/font-height * 0x1)					; minimum, plus height of one line of text, to keep caret fully visible
							(parent-face/size - (face/size * 1x0) - (sizes/font-height * 0x1)) ; maximum, subtract height of one line of text
					] ; -AntonR
					show parent-face
				]
				parent-face/key-scroll?: false
			]
			ratio: p/size/y - 4 / text-y
		]
		pane/init
	]
]
