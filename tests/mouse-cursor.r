REBOL [
	title: "Mouse-cursor"
]

; delayed mouse cursor changes

do %../../framework/libraries/rebgui.r
print ""

main: []

foreach type [
	app-start
	hand
	help
	hourglass
	arrow
	cross
	i-shape
	no
	size-all
	size-nesw
	size-ns
	size-nwse
	size-we
	up-arrow
	wait
] [
	append main compose/deep [
		box 25x5 red (form type) [main/cursor: (to-lit-word type)] ; type of face that does not cause a redraw
		button 25 (form type) [main/cursor: (to-lit-word type) repeat i 1000 [print i]] ; the cursor does not show until the action completes
		return
	]
]

ctx-rebgui/debug/redraws: true ; it is not a redraw problem, as the boxes do not cause a redraw

main: ctx-rebgui/layout main

display "test" main

do-events

quit