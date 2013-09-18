REBOL [
	title: "Table 26 Playground, right click cell-data problems"
]

do %../../framework/libraries/rebgui.r
print ""

data-set: []

repeat i 20000 [append data-set checksum form i] ; 10000 rows

; [1] - menu shows the last cell instead of the current one, when generating the menu after a table redraw. possibly a redraw issue. maybe there is a better method.

t-menu: does [
	either object? t/cell-face [
? t/cell-face
		append copy [] mold t/cell-face/text ; [1]
	][
		copy []
	]
]

display "test" [
	button "select" [t/select-row [3 4 5]] ; [1]
	t: table #WH 189x70 options [multi] [
		probe t/picked
	][
		probe t/picked
	][
		probe t/picked
	]
	return
]
	 
options: [
	"foo" left 200
	"boo" center 200
]

add-ctx-menu t :t-menu

t/set-columns options
insert t/data data-set
t/redraw

do-events

quit