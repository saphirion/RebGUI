menu: make rebface [
	size: 15x5
	menu:	false ; the menu-list face with the currently active menu
	last-selected: none
	options: [no-close-popup]
	deselect-menu-list: does [
		if last-selected [
			last-selected/edge/color:
			last-selected/edge/effect: none
			show last-selected
			last-selected: none
		]
	]
	select-menu-list: make function! [menu-list [object!]] [
		deselect-menu-list
		menu-list/edge/color: colors/edge
		menu-list/edge/effect: 'ibevel
		show menu-list
		last-selected: menu-list
	]
	init:	make function! [/local name items] [
		pane: copy [space 0x0 margin 0x0]
		parse data [
			any [
				set name string! (repend pane ['menu-list name 'data])
				set items [block! | get-word! | word!] (
					if word? items [
						items: either function? get items [
							to get-word! items
						][
							get items
						]
					]
					append/only pane items
				)
			]
		]
		pane: ctx-rebgui/layout pane
		size: pane/size
		pane: pane/pane
		; should resize this bit, as it seems that is necessary
	]
]
