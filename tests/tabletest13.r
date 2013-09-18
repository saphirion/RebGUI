REBOL [
	title: "Table 13 Playground, sort-column arrow update problem"
]

do %../../framework/libraries/rebgui.r

display "" [
	t: table 100x50
	options [
		"ID" right .5
		"Col 2" center .5
		resize-last-column-only
	]
	data [
		1 a
		2 b
		3 c
		4 d 
		5 e
		6 f
		7 g
		8 h
		9 i
		10 j
	]
	return
	button 25 "sort UP" [
		t/select-row/no-action none
		t/sort-column/dir 1 'up
	]
	button 25 "sort DOWN" [
		t/select-row/no-action none
		t/sort-column/dir 1 'down
	]
	button 25"sort TOGGLE" [
		t/select-row/no-action none
		t/sort-column 1
	]
]

do-events

quit

;halt