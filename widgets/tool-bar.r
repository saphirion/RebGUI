tool-bar: make rebface [
	size:	100x-1
	pane:	[]
	color:	colors/window
	init:	make function! [/local icon-offset] [
		size/y: 30
		icon-offset: 2x2
		foreach [tooltip icon spec] data [
			either string? tooltip [
				insert tail pane make rebface [
					offset:	icon-offset
					size:	22x22
					text:	""
					image:	any [
						if word? icon [get icon]
						if file? icon [load icon]
						icon
					]
					data:	tooltip
					feel: make default-feel [
						over: make function! [face act pos /local tooltip] [
							tooltip: last face/parent-face/pane
							either act [
								tooltip/text: data
								tooltip/show?: true	; required for size-text to work
								tooltip/size/x: 4 + first size-text tooltip
								tooltip/offset/x: face/offset/x + 24
								face/color: colors/widget
								show [tooltip face]
							][
								face/color: none
								show face
								hide tooltip
							]
						]
						engage: make function! [face act event] [
							switch act [
								down	[face/action face]
								away	[face/feel/over face false 0x0]
							]
						]
					]
					action:	make function! [face /local var] spec
				]
				icon-offset: icon-offset + 24x0
			][
				icon-offset/x: icon * sizes/cell + icon-offset/x	; pad n none
			]
		]
		insert tail pane make rebface [
			offset:	0x16
			size:	100x14
			text:	""
			color:	wheat
			edge:	make default-edge [color: black]
			font:	make default-font [size: 9 align: 'center]
			show?:	false
		]
		data: none
	]
]