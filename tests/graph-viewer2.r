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
;	graph-controls
	tool-tip-coords
;	tool-tip-delay 0:0:0
	cross-hair
	cross-hair-color orange
	point-over-color cyan
	point-select-color magenta
;	point-shape triangle
	graph-zoom
	quadratic-ratio
;	limit 150x150 0x100
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
	pan-action [
		set-vp none
	]
	zoom-action [
		set-vp none
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

; zooms by a ratio
zoom: func [coords factor /local center-x center-y] [
	center-x: coords/3 - coords/1 / 2 + coords/1
	center-y: coords/4 - coords/2 / 2 + coords/2
	coords/1: coords/1 - center-x * factor + center-x
	coords/2: coords/2 - center-y * factor + center-y
	coords/3: coords/3 - center-x * factor + center-x
	coords/4: coords/4 - center-y * factor + center-y
	coords
]

; frame a group of points
frame: func [ids /local all-coords coords group margin-x margin-y size-x size-y] [
	; find points block in graph or return the current viewport
	any [
		all [
			group: find graph-data 'point ; global
			group: find group block!
			group: first group
		]
		return none
	]
	; find frame
	coords: array 4
	foreach [id x y] group [
		if any [ids = 'all find ids id/3] [
			coords/1: any [all [coords/1 min x coords/1] x]
			coords/2: any [all [coords/2 min y coords/2] y]
			coords/3: any [all [coords/3 max x coords/3] x]
			coords/4: any [all [coords/4 max y coords/4] y]
		]
	]
	either 3 = length? group [
		;-- if there is only one point, add a unit of one around it.
		margin-x: margin-y: 1
	][
		either any [coords/1 = coords/3 coords/2 = coords/4] [
			; apply margin as 0.1% of the total size (not optimal, as it does not take actual dot population into account)
			all-coords: frame 'all
			size-x: all-coords/3 - all-coords/1
			size-y: all-coords/4 - all-coords/2
			margin-x: size-x * 0.001
			margin-y: size-y * 0.001
		][
			; apply margin as 10% of the frame size
			size-x: coords/3 - coords/1
			size-y: coords/4 - coords/2
			margin-x: size-x * 0.1
			margin-y: size-y * 0.1
		]
	]
	coords/1: coords/1 - margin-x
	coords/2: coords/2 - margin-y
	coords/3: coords/3 + margin-x
	coords/4: coords/4 + margin-y
	coords
]

as-limit: func [coords] [
	reduce [
		as-pair coords/1 coords/2
		as-pair coords/3 coords/4
	]
]

vp-format: func [frm] [
	either frm [
		reform [
			"x1:" frm/1 newline
			"y1:" frm/2 newline
			"x2:" frm/3 newline
			"y2:" frm/4 newline
		]
	][
		"None"
	]
]

set-vp: func [frm] [
	show-text ivp vp-format frm
	if frm [g/set-viewport-xy/center frm]
	show-text avp vp-format g/get-viewport-xy
]

problems: [
	"Select a problem"
		[]
	"Small Viewport won't show"
		[set-vp [7000 7000 7004 7004]]
	"This Viewport shows OK"
		[set-vp [7000 7000 70040 70040]]
]

problems-names: extract problems 2

display "Graph Viewer 2" [
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
			file: load file
			either object? file [
				;-- points
				append clear graph-data graph-points: file/points
				;-- settings
				foreach word [point-action pan-action zoom-action mouse-wheel-action tool-tip-action] [
					; find more stuff to do here
					if find file/settings word [
						change/only next find file/settings word either find graph-settings word [copy/deep graph-settings/:word][[]]
					]
				]
				g/set-graph file/settings
				;-- frame
				set-vp file/frame
			][
				append clear graph-data file
				g/set-graph either empty? graph-settings [graph-settings: copy/deep initial-graph-settings][graph-settings]
				set-vp none
			]
		][
			alert "Graph file does not exist."
		]
	]
	return
	button 5 "+" [set-vp probe zoom g/get-viewport-xy .9]
		tool-tip "Zooms in by ten percent of the frame size"
	button 5 "-" [set-vp probe zoom g/get-viewport-xy 1.1]
		tool-tip "Zooms out by ten percent of the frame size"
	button 25 "Frame" [set-vp frame [8 10 12]]
		tool-tip "Frames points 8, 10 and 12"
	button 25 "Frame All" [set-vp frame 'all]
		tool-tip "Frames all points"
	button 25 "Frame Specific" [set-vp [4 3 8 6]]
		tool-tip "Frames points 4, 3, 8 and 6 in that order"
	button 25 "Viewport" [set-vp remove-each v to-block ivp/text [all [not decimal? v not integer? v]]]
		tool-tip "Creates a viewport from the intended viewport field"
	;button 25 "Limit Frame" [
	;	change next find graph-settings 'limit probe as-limit frame 'all
	;	g/set-graph graph-settings
	;	update-vp
	;]
	d-problems: drop-list 60 data problems-names [do select problems face/picked]
	return
	label 125 "Graph"
	label 50 "Intended Viewport"
	return
	g: chart-new #HW 125x125 data graph-settings
	panel #X data [
		space 1x1
		ivp: area 60x25 return
			tool-tip "Enter viewport coordinates here and click the 'Viewport' button to set an intended custom viewport."
		label 50 "Actual Viewport" return
		avp: area 60x25
			tool-tip "The viewport value that is returned from the graph."
	]
]

d-problems/set-picked 1

do-events

quit