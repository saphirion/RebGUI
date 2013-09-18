REBOL [
	title: "Graph Viewer"
]

do %../rebgui.r

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
;	color-ranges [
;		 0 60 220.220.220.120
;		60 120 200.200.200.120
;	]
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
display "Graph Viewer" [
	margin 1x1
	space 1x1
	text "Specify graph to load by clicking '...'. Then click 'Refresh'."
	return
	f-graph-file: field 100
	button 5 "..." [if file: request-file [show-text f-graph-file file]]
	button 15 "Refresh" [
		either all [
			exists? file: to-file f-graph-file/text
			%"" <> file
			#"/" <> last file
		] [
			append clear graph-data load file
			g/set-graph either empty? graph-settings [graph-settings: copy/deep initial-graph-settings][graph-settings]
		][
			alert "Graph file does not exist."
		]
	]
	return
	g: chart-new #HW 125x125 data graph-settings
]

do-events

quit