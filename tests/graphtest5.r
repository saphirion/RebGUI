REBOL [
	title: "Graph Playground for large data"
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
;	tool-tip-delay 0:0:0
	cross-hair
	cross-hair-color orange
	point-over-color cyan
	point-select-color magenta
;	point-shape triangle
	graph-zoom
	quadratic-ratio
	limit 150x150 0x100
	;note: the COLOR-RANGE is coloring graph background in the defined ranges
	color-ranges [
		 0 60 220.220.220.120
		60 120 200.200.200.120
	]
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
;		return probe rejoin [
;			"point" any [all [matched-point/2 join " " matched-point/2] ""] " at: " matched-point/3/1 "x" matched-point/3/2
;		]
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
	text "Test large data sets"
	return
	bar 142
	return
	g: chart-new #HW 125x125 data graph-settings
	panel data [
		button "Update" [
			append clear graph-data load %large-plot-data.txt
			then: now/precise ; only measure graph update duration, not data loading
			g/set-graph either empty? graph-settings [graph-settings: copy/deep initial-graph-settings][graph-settings]
			print ["Graph update duration:" difference now then]
		]
		return
		button "Redraw" [
			then: now/precise
			g/redraw
			print ["Graph redraw duration:" difference now then]
		]
	]
]

do-events

quit

;halt