warn: make rebface [
	image: none
	reset-action: func [face] [show-data face false]
	warn-image: #do [load %../images/warn.png]
	; when SHOW-DATA sets TRUE, the image is shown
	feel: make default-feel [
		redraw: make function! [face act pos] [
			if act = 'show [
				face/image: if face/data [face/warn-image]
				; do not allow tool-tip to show, if the image is not shown
			]
		]
	]
	init:	make function! [] [
		size: warn-image/size
	]
]