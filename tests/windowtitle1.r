REBOL [
	title: "Grid Playground, content generation"
]

do %../../framework/libraries/rebgui.r
print ""
lay: ctx-rebgui/layout [
	button "test" 40x10 [
		unview 
		display "Test-2" lay
	]
]

display "Test-1" lay
do-events