anim: make rebface [
	size:	-1x-1
	effect:	'fit
	feel:	make default-feel [
		engage: make function! [face act event] [
			if act = 'time [
				face/image: first face/data
				face/data: either tail? next face/data [head face/data] [next face/data]
				show face
			]
		]
	]
	rate:	1
	init:	make function! [] [
		repeat i length? data: reduce data [ ; AGT 25-May-2006
			if file? pick data i [
				poke data i load pick data i
			]
		]
		image: first data
		data: next data
		if negative? size/x [size/x: image/size/x]
		if negative? size/y [size/y: image/size/y]
	]
]