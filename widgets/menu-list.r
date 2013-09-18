menu-list: make rebface [
	size: 15x5
	text:		""
	font:		make default-font [align: 'center]
	popup?: false
	feel: make default-feel [
		engage: make function! [face act event] [
			switch act [
				down [
					if any [
						not system/view/pop-face 
						face/parent-face/last-selected <> face
					][
						ctx-rebgui/widgets/hide-menu
						face/popup?: true
						face/parent-face/select-menu-list face
						show-menu face as-pair 0 face/size/y + 1 face/data
						face/parent-face/deselect-menu-list
					]
				]
				up [
					if all [not face/popup? face/parent-face/last-selected = face] [
						ctx-rebgui/widgets/hide-menu
					]
					face/popup?: false
				]
			]
		]
	]
	init:	make function! [] [
		edge: make default-edge [color: none]
		size/x: 1000
		size/x: first size-text self
		size/x: size/x + 10 ; hardcoded spacing
		
		;parse the items to gather and add possible keyboard shortcuts
		ctx-rebgui/widgets/build-menu-items/deep data
	]
]
