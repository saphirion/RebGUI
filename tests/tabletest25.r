REBOL [
	title: "Table 25 Playground, table columns crash with numeric sort when words are present."
]

; allow sorting in numeric columns, when words occurs.

; D column crashes, as it contains only Words. This crash must not occur.

do %../../framework/libraries/rebgui.r
print ""

; table layout
display "Table" [
	t: table 100x50
		options ["a" left 100 num-sort "b" left 100 num-sort "c" left 100 num-sort "d" left 100 num-sort]
		data [1 2 3 no-model no-model no-model no-model no-model]
]

do-events

quit