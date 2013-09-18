REBOL [
	title: "Table 24 Playground, table columns crash with numeric sort on NONE"
]

; allow sorting in numeric columns, when NONE occurs.

; A column should not crash, as it does not contain at least 2 NONEs.
; B column should not crash, as it contains one NONE value.
; C column crashes, as it contains 2 NONEs. This crash must not occur.
; D column crashes, as it contains only NONEs. This crash must not occur.

do %../../framework/libraries/rebgui.r
print ""

; table layout
display "Table" [
	t: table 100x50
		options ["a" left 100 num-sort "b" left 100 num-sort "c" left 100 num-sort "d" left 100 num-sort]
;		data [1 2 3  5 #[none] 7 8 9 10 #[none] #[none] 13 14 15]
		data [1 2 3 #[none] 5 6 #[none] #[none] 9 #[none] #[none] #[none] 13 14 15 #[none]]
]

do-events

quit