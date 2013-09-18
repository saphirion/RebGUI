REBOL [
	title: "Table 15 Playground, too small scrolling knob problem"
]

do %../../framework/libraries/rebgui.r
print ""

data-set: []

repeat i 20000 [append data-set checksum form i] ; 10000 rows

display "test" [
	t: table #WH 189x70 ; vertical scroller knob is hard to drag
	return
]

options: [
	"foo" left 200
	"boo" center 200
]

t/set-columns options
insert t/data data-set
t/redraw

do-events

quit