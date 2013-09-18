REBOL [
	title: "Window resize problem"
]

do %../../framework/libraries/rebgui.r

print ""

; the layout is pre-generated

test: ctx-rebgui/layout [
	button #WH "Hello"
]

resize-face/size/no-show test 500x500
display "Test" test

do-events

quit

;halt