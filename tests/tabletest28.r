REBOL [
	title: "Table 25 Playground, table won't sort small numbers correctly."
]


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
	4 4 4 4 4
	none none none none none
]

; table layout
display "Table" [
	t: table 200x50
		options [
			"col1-default(=above-max)" left .2 num-sort
			"col2-always-top" left .2 num-sort always-top
			"col3-always-bottom" left .2 num-sort always-bottom
			"col4-above-max" left .2 num-sort above-max
			"col5-under-min" left .2 num-sort under-min
		]
		data tdata
]

do-events

quit