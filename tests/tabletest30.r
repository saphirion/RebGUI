REBOL [
	title: "Table 30 Playground, retrieve COL-ID, as table is being focused."
]

; this demonstrates a problem where the correct COL-ID is not retrieved
; as the table is brought into focus

; instead the previous COL-ID is retrieved.

; 1. First activate the dummy window
; 2. Then activate the table window, by right clicking right on top of the table
; 3. The COL-ID is written in the console, but this number does not necessarily
;    match the column that is selected
; 4. Repeat step 1.

do %../../framework/libraries/rebgui.r
;include %../rebgui-ctx.r
print ""

tdata: reduce [
	1 1 1 1 1
	none none none none none
	2 2 2 2 2
	none none none none none
	3 3 3 3 3
	none none none none none
]

render-cell: [true]

; table layout
display "Table" [
	t: table 200x50
		options [
			"col1-default(=above-max)" left .2 num-sort
			"col2-always-top" left .2 num-sort always-top
			"col3-always-bottom" left .2 num-sort always-bottom
			"col4-above-max" left .2 num-sort above-max
			"col5-under-min" left .2 num-sort under-min
			header-alt-action [probe column]
			on-render-cell render-cell
		]
		data tdata [
		probe t/header-face
			probe t/cell-face/col-id
		] [
			probe t/cell-face/col-id
		]
]

display "Dummy" [
	box red
]

do-events

quit