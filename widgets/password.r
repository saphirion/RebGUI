password: make field [
	size:	50x5
	font:	make default-font [size: to integer! sizes/font * 1.5 name: font-fixed]
	init:	make function! [/local p char-width radius] [
		p: self
		para: make para []
		pane: make rebface [
			color:	colors/edit
			effect:	[draw [pen black fill-pen black]]
			feel:	make default-feel []
			span:	all [p/span find p/span #W #W]
		]
		char-width: first size-text make rebface [
			text: "M" font: make default-font [
				size: to integer! sizes/font * 1.5 name: font-fixed
			]
		]
		radius: to integer! char-width + 1 / 3
		pane/size: size
		pane/feel/redraw: make function! [face act pos /local offset] compose/deep [
			if act = 'show [
				;	clear previous mask
				clear skip face/effect/draw 4
				either all [view*/caret same? face/parent-face/text head view*/caret] [	; dirty? view*/caret
					;	append new mask
					repeat i length? head view*/caret [
						insert tail face/effect/draw reduce ['circle i * (as-pair char-width 0) + (as-pair 1 - radius sizes/line / 2) (radius)]
					]
					;	add cursor
					offset: (as-pair char-width 0) * index? view*/caret
					offset/x: offset/x - char-width
					insert tail face/effect/draw reduce [
						'box offset + (as-pair 2 2) offset + (as-pair 3 sizes/line - 4)
					]
				][
					repeat i length? face/parent-face/text [
						insert tail face/effect/draw reduce ['circle i * (as-pair char-width 0) + (as-pair 1 - radius sizes/line / 2) (radius)]
					]
				]
			]
		]
	]
]