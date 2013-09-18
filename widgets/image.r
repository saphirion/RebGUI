image: make rebface [
	size:	-1x-1
	effect:	'fit
	reset-action: func [face][
		image: none
		show face
	]
	init:	make function! [] [
		if file? image [image: load image]
		if negative? size/x [size/x: image/size/x]
		if negative? size/y [size/y: image/size/y]
	]
]