splitter: make rebface [
	size:	1x50
	color:	colors/window
	feel:	make default-feel [
		over: make function! [face act pos] [
			face/color: either act [colors/over] [colors/window]
			show face
		]
		engage: make function! [face act event /local p n delta] [
			if event/type = 'move [
				p: first face/data
				n: second face/data
				either face/size/y > face/size/x [
					delta: face/offset/x - face/offset/x: min n/offset/x + n/size/x - face/size/x - 1 max p/offset/x + 1 face/offset/x + event/offset/x
					p/size/x: p/size/x - delta
					n/size/x: n/size/x + delta
					n/offset/x: n/offset/x - delta
				][
					delta: face/offset/y - face/offset/y: min n/offset/y + n/size/y - face/size/y - 1 max p/offset/y + 1 face/offset/y + event/offset/y
					p/size/y: p/size/y - delta
					n/size/y: n/size/y + delta
					n/offset/y: n/offset/y - delta
				]
				show [p face n]
			]
			;	reset color if splitter is dragged out of bounds
			if act = 'away [face/feel/over face false 0x0]
		]
	]
	init2:	make function! [parent [object!] /local f p n] [
		f: find parent/pane self
		p: back f
		n: next f
		if size/y <= size/x [
			while [offset/x <> p/1/offset/x] [
				if head? p [gui-error "Splitter failed to find previous widget"]
				p: back p
			]
			while [offset/x <> n/1/offset/x] [
				if tail? p [gui-error "Splitter failed to find next widget"]
				n: next n
			]
		]
		data: reduce [first p first n]
	]
]