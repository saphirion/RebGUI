REBOL [
	title: "Graph Playground"
]

do %../rebgui.r

graph-data: []

overflow: [
	line 1 blue [837.040931815934 837.040931815934 1945.87942063753 1945.87942063753]
	line 1 green [837.040931815934 799.546052146896 1945.87942063753 1858.71460951058]
	line 1 red [837.040931815934 900.309761654388 1945.87942063753 2092.96125292424]
	point 4 blue [
		1945.87942063753 2181.0
		837.040931815934 904.74
		1392.00000000006 1392.0
		1382.2540119225 1144.35
		1382.2540119225 1300.32
		1382.2540119225 1465.0
		103223114753.301 103223114753.301 ; overflow
	]
]

same: [
	line 1 blue [837.040931815934 837.040931815934 1945.87942063753 1945.87942063753]
	line 1 green [837.040931815934 799.546052146896 1945.87942063753 1858.71460951058]
	line 1 red [837.040931815934 900.309761654388 1945.87942063753 2092.96125292424]
	point 4 blue [
		1945.87942063753 2181.0 ; invisible
		800 800 ; visible
		850 850 ; invisible, should not appear
		1000 1000 ; visible
		1000 1000 ; invisible
		1005 1010 ; visible
		1005 1020 ; invisible, should not shown as be overlapping
		1382.2540119225 1144.35 ; visible
		1382.2540119225 1300.32 ; invisible
		1382.2540119225 1465.0 ; visible
	]
	visible-points [
		2 4 6 8 10
	]
	points-colors [
		red [2 6]
		7 [black yellow none green]
	]
	
]

problem: [
	line 1 0.0.255.255 [487.294494356491 487.294494356491 1908.77327845167 1908.77327845167]
	line 1 0.255.0.255 [487.294494356491 441.559710064076 1908.77327845167 1729.62630436489]
	line 1 255.0.0.255 [487.294494356491 534.138621706598 1908.77327845167 2092.26564205071]
	point 4 blue [
		1308.97974131743 1655.6
		1908.77327845167 2181.0
		1092.19112425237 904.74
		1142.76574437046 1392.0
		;1476.21277392286 1144.35
		;1476.21277392286 1300.32
		;1476.21277392286 1465.0
		;1476.21277392286 1465.0
		;502.462944749219 547.34
		;502.462944749219 530.6
		;502.462944749219 420.76
		;541.707580535152 565.32
		;541.707580535152 605.0
		;541.707580535152 568.6
		;541.707580535152 395.35
		;487.294494356491 509.04
		;601.909919468821 550.59
		;549.812183637339 569.5
		;549.812183637339 556.0
		;601.909919468821 713.0
		;734.620385899566 734.620385899566
	]
;	visible-points [1 2 3 4 6 9 10 11 12 13 14 15 16 17 18 19 20 21]
	visible-points [
		2 4 6 8 10
	]
	points-colors [
	;	red [2 6]
	;	7 [black yellow none green]
	]
]

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
print ""
display "test" [
	text "View port size is not maintained when resizing the graph, while zoomed in. Notice the ranges."
	return
	g: chart-new #HW 125x125 data graph-settings
	return
	panel #Y data [
		button 25 "Big" [g/size: 500x500 g/redraw]
		button 25 "Small" [g/size: 400x400 g/redraw]
	]
]

;init graph
append clear graph-data problem
g/set-graph either empty? graph-settings [graph-settings: copy/deep initial-graph-settings][graph-settings]

do-events

quit

;halt