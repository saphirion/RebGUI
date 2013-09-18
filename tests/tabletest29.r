REBOL [
	title: "Table 29 Playground, scroll bar appears when using the keyboard, when it has no reason to."
]

; click a row with the mouse to focus the table
; use cursor up or down keys to display the scroller. it should not display.
; SHOW in the table action will cause the scroller to disappear again.

; this is only a problem, when the amount of information in the table does not warrant a scroller.

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
			on-render-cell render-cell
		]
		data tdata [
			show t
		]
]

do-events

quit