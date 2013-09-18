panel: make rebface [
	size:	-1x-1
	pane:	copy []
	init:	make function! [] [
		data: layout/only/origin data 0x0
		pane: data/pane
;		foreach face pane [face/offset: face/offset + as-pair 0 sizes/cell * sizes/gap]
		if negative? size/x [size/x: data/size/x]
;		if negative? size/y [size/y: sizes/cell * sizes/gap + data/size/y]
		if negative? size/y [size/y: data/size/y]
		data: none
	]
]
