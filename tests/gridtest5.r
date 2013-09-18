rebol []

do %../../framework/libraries/rebgui.r
print ""

; grid widget rendering issues

lo: [
	g: grid #HW 60x38 data [
		header 			["Data Column" "Widget column"]
		row-spec		[
			[text 25]
			[check #X 5 [
				poke
					pick
						pick test-content face/content-index/y 2
						2
					face/data
					test-content
				g/redraw
			]]
		]
	]
]

; [1] - widget column scrolled to bottom does not stop rendering at the last text row

test-content: [
	["a" [data: #[none]]]
	["b" [data: #[true]]]
	["c" [data: #[none]]]
	["d" [data: #[true]]]
	["e" [data: #[none]]]
	["f" [data: #[none]]]
	["g" [data: #[none]]]
	["i" [data: #[true]]] ; [1] - keeps rendering checkmarks after this row
]

ll: ctx-rebgui/layout copy/deep lo

g/sort-columns?:
g/hilite-cell?:
g/hilite-row?:
	false

g/insert-row/bulk 1 test-content
g/redraw
display "" ll
do-events