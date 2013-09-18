REBOL [
	title: "Graph Playground for graph range"
]

do %../rebgui.r
;do %../../framework/libraries/debug.r

graph-data: []

graph-settings: copy/deep initial-graph-settings: [
	graph xyplot
	grid 10x10 black
	hilite-points
	shadows
	graph-pan
	graph-controls
	tool-tip-coords
	cross-hair
	cross-hair-color orange
	point-over-color cyan
	point-select-color magenta
	graph-zoom
	quadratic-ratio
	limit 1x0 0x1 ; [!] - this does not appear to show the correct limit
	data graph-data
	x-label "Axis X"
	y-label "Axis Y"
	point-action [
;		probe matched-point
		print "matched-point"
		foreach [point-pos point-id point-data] matched-point [
			probe point-pos
			probe point-id
			probe point-data
		]
		print "adjacent-points"
		foreach [point-pos point-id point-data] adjacent-points [
			probe point-pos
			probe point-id
			probe point-data
		]
	]
	tool-tip-action [
		return either all [
			empty? matched-point empty? adjacent-points
		] [
			"outside points"
		][
			"on point"
		]
	]
]
prin ""
display "test" [
	text "Test range limitation"
	return
	bar 142
	return
	g: chart-new #HW 125x125 data graph-settings
	panel data [
		button "Update" [
			append clear graph-data load %small-range-plot-data.txt
			g/set-graph either empty? graph-settings [graph-settings: copy/deep initial-graph-settings][graph-settings]
		]
		return
		button "Redraw" [
			g/redraw
		]
	]
]

do-events

quit

;halt