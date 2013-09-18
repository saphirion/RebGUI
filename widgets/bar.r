bar: make rebface [
	size:	-1x1
	edge:	make default-edge [size 0x1 color: none effect: none]
	init: make function! [] [
		color: colors/edge
	]
]