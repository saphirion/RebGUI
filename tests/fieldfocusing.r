REBOL [
	title: "Field focusing problem"
]

do %../../framework/libraries/rebgui.r

lay: ctx-rebgui/layout [
	f: field
	g: field
]

show-dialog: does [
	show-focus g ; focus before opening the dialog
	display/dialog/no-hide "dialog" lay
]

display "test" [
	button 25 "open dialog" [show-dialog]				; focuses 'g properly
	return
	radio-group 50 data ["a" "b"] [show-dialog]	; does not focus 'g
	return
	d: drop-list [show-dialog] data ["a" "b"]		; focuses 'g properly
]

d/popup-mode: 'outside ; grrr...

do-events