REBOL [
	title: "Table 17 Playground, mouse over crash on custom header"
]

do %../../framework/libraries/rebgui.r
print ""

display "test" [
	t: table #WH 189x70 options [multi]
	return
]

; [1] - mouse over column 2 to crash

t/set-columns [
	"Boo" left 100
	[label 25 "Foo"] left 100 ; [1]
]

t/redraw

do-events

quit