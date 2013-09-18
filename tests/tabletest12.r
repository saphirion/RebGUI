REBOL [
	title: "Table 12 Playground, last row scrolling problem"
]

do %../../framework/libraries/rebgui.r
print ""

data-set: []

repeat i 262 [ ; [1] - 262 rows. this seems to be important.
	repend data-set [form i form now/precise random "abcdefghijkl"]
]

display "test" [
	t: table #WH 189x70 ; [2] - shows 13 lines. the number of lines seems to be important, as changing the number of displayed lines, such as by resizing to anything else but 13 lines, removes the bug.
	return
]

options: [
	"ID" right 100
	"Col 2" center 100
	"Col 3" center 100 ; [3] - sorts by column 2 for some reason
]

t/set-columns options
insert clear t/data data-set
t/redraw

do-events

quit

;halt