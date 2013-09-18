REBOL [
	title: "Table 15 Playground, right click selection problems"
]

do %../../framework/libraries/rebgui.r
print ""

data-set: []

repeat i 20000 [append data-set checksum form i] ; 10000 rows

; [1] - use select button and right click selection in table. selection disappears.
; [2] - menu shows not current selection but previous selection

t-menu: does [
	append copy [] mold t/picked ; [2]
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