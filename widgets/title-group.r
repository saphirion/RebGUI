title-group: make rebface [
	color:	colors/widget
	font:	make default-font [valign: 'top]
	init:	make function! [/local parent indent] [
		if file? image [image: load image]
		indent: either image [size/y: image/size/y image/size/x + sizes/line] [sizes/line]
		parent: self
		;	create title text
		pane: make rebface [
			offset: as-pair indent sizes/line
			size:	as-pair parent/size/x - indent - sizes/line 1000000
			text:	parent/data
			font:	make default-font [size: to integer! sizes/font / .75 style: 'bold]
			para:	default-para-wrap
		]
		pane/size: 5x5 + size-text pane
		;	create body text
		para: make default-para-wrap compose [
			origin:	(as-pair indent parent/pane/size/y + sizes/line + sizes/line)
			margin:	(as-pair sizes/line 0)
		]
		;	auto-height?
		if all [not image negative? size/y] [
			size/y: 1000000 size/y: para/origin/y + second size-text self
		]
		data: none
	]
]