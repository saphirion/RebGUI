REBOL [
	title: "Tooltips Playground, multiple windows problem"
]

do %../../framework/libraries/rebgui.r


display "1" [
	box red 25x25
	button "Test" [
		; when display 2 is opened, tooltips stop working in display 1
		display "2" [
			button "Test2" tool-tip "This is the tool-tip for the area"
		]
	] tool-tip "This is the tool-tip^/for the first window"
]

do-events
