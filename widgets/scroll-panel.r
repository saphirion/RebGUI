scroll-panel: make rebface [
	size: 0x0
	root: hscr: vscr: viewport: plane: none
	state-words: [
		offset [negate plane/offset]
	]

	update-sliders: does [
		hscr/ratio: hscr/size/x / plane/size/x
		vscr/ratio: vscr/size/y / plane/size/y
	]

	update-plane: does [
		plane/span: #W
		either plane/init-size/x < viewport/size/x [
			span-resize plane viewport/size - plane/size plane/size/x / plane/init-size/x  plane/size/y / plane/init-size/y
			plane/offset: 0x0
		][
			span-resize plane plane/init-size - plane/size plane/size/x / plane/init-size/x  plane/size/y / plane/init-size/y
		]
		plane/span: 'no-resize
	]

	on-resize: does [
		update-plane
		update-sliders
	]

	set-content: func [
		content [block! object!]
		/no-show
	][
		viewport/pane: plane: either block? content [layout/only/origin content 0x0][content]
		plane/init-size: plane/size
		plane/span: 'no-resize
		update-sliders
		unless no-show [show root]
	]

	scroll-to: func [
		pos [pair!]
		/local
			oft siz faces
	][
		faces: clear []
		oft: negate max 0x0 min plane/size - viewport/size pos

		if oft <> plane/offset [
			plane/offset: oft
			insert tail faces plane
			plane/changes: 'offset
		]

		siz: negate (plane/size - viewport/size)

		if siz/y <> 0 [
			vscr/data: plane/offset/y / siz/y
			insert tail faces vscr
		]

		if siz/x <> 0 [
			hscr/data: plane/offset/x / siz/x
			insert tail faces hscr
		]

		unless empty? faces [show faces]
	]

	state-action: make function! [word [word!] value /local p] [
		p: self
		if word = 'offset [
			p/scroll-to value
		]
	]

	init: has [] [
		root: self
		plane: layout/only/origin any [root/data []] 0x0
		if plane/size = 0x0 [plane/size: 100x100]
		plane/init-size: plane/size
		plane/span: 'no-resize

		if root/size = 0x0 [
			root/size: min system/view/screen-face/size / 1.2 plane/size + 16
		]

		pane: reduce [
			viewport: make rebface [
				pane: plane
				span: #WH
				offset: 0x0
				size: root/size - 16
			]
			hscr: make slider [
				offset: as-pair 0 viewport/size/y
				size: as-pair viewport/size/x 16
				options: [arrows]
				span: #WY
				action:	make function! [face /local oft] [
					if face/ratio = 1 [exit]
					oft: face/data * negate (plane/size/x - viewport/size/x)
					if oft <> plane/offset/x [
						plane/offset/x: oft
						plane/changes: 'offset
						show plane
					]
				]
				ratio: 1
			]
			vscr: make slider [
				offset: as-pair viewport/size/x 0
				size: as-pair 16 viewport/size/y
				options: [arrows]
				span: #HX
				action:	make function! [face /local oft] [
					if face/ratio = 1 [exit]
					oft: face/data * negate (plane/size/y - viewport/size/y)
					if oft <> plane/offset/y [
						plane/offset/y: oft
						plane/changes: 'offset
						show plane
					]
				]
				ratio: 1
			]
		]
		vscr/init
		hscr/init
		update-plane
		update-sliders
;		foreach face pane [face/offset: face/offset + as-pair 0 sizes/cell * sizes/gap]
		if negative? size/x [size/x: data/size/x]
;		if negative? size/y [size/y: sizes/cell * sizes/gap + data/size/y]
		if negative? size/y [size/y: data/size/y]
		data: none
	]
]
