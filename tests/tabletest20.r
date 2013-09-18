REBOL [
	title: "Table 20 Playground, right adjustment is uneven."
]

do %../../framework/libraries/rebgui.r
print ""

cell: [
	face/font/style: if pos/y = 2 ['bold]
]

display "Text Adjustment" [
	t: table #WH 90x30
		options [multi on-render-cell cell]
		data ["Boo" "Boo" "Boo" "Boo"]
	return
]

t/set-columns ["Boo" right 100 "Boo" right 100]

; bug 1: In the left column, the bold text is not vertically adjusted correctly
; bug 2: In the right column, the normal and the bold text does not vertically adjust with the title, while it does so in the left column.
; bug 3: The title of the right column creeps to the right, when dragging column width adjustment bar

t/redraw

do-events

quit