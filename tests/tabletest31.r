REBOL [
	title: "Table 31 Playground, run HEADER-ALT-ACTION properly, when menu is shown."
]

; this demonstrates a problem where the HEADER-ALT-ACTION is not run
; when continuously right clicking the header to bring up a context menu.

; 1. First try out right clicking on the header. This should show the correct column ID in the console
; 2. Click "Assign Menu" to assign the menu to the table.
; 3. Right click over each column. Only on the first right click is the HEADER-ALT-ACTION run.
; 4. Left click elsewhere then repeat step 3.

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
header-column: none

test-menu: does [
	reduce [
		reform ["This column is:" header-column]
	]
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
			header-alt-action [probe header-column: column] ; this is only run the first time we are right clicking, when a menu is present
			on-render-cell render-cell
		]
		data tdata [
			probe t/cell-face/col-id
		] [
			probe t/cell-face/col-id
		]
	return
	button 25 "Assign Menu" [add-ctx-menu t :test-menu]
]

do-events

quit