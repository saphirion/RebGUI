chart-new: make rebface [
;added - support for Ladislav's code
	old-size: size: -1x-1
;
	strip-zero: func [
		n [number! string!]
		/local tmp
	][
		if 1 = length? tmp: parse/all either string? n [n][n: form n] "." [	
			return form n
		]
		while ["0" = back tail tmp/2][remove back tail tmp/2]
		
		return either empty? tmp/2 [
			tmp/1
		][
			rejoin [tmp/1 "." tmp/2]
		]
	]

	form-number: func [num [number! string!] /local tmp][
			unless string? num [num: form num]
			if 1 < length? parse/all num "E" [
				return num
			]
			if 1 < length? tmp: parse/all num "." [
				if 0 = to-integer tmp/2 [
					return tmp/1
				]
			]
			num
		]

	viewport-specs: [
		x-center-neg:
		y-center-neg:
		x-center:
		y-center: none
		x-trans:
		y-trans: 0
		y-scale-inv:
		x-scale-inv:
		x-scale:
		y-scale: 1

		x-trans-txt: copy []
		x-trans-txt-spec: copy []
		y-trans-txt: copy []
		y-trans-txt-spec: copy []
		scale-max: 1962
		scale-min: 1 / (scale-max * .1)

		vscale-inv: scale-max
		vscale: 1 / vscale-inv
		
		x-min-value: y-min-value:
		x-max-value: y-max-value: none
	]
	viewport: make object! viewport-specs

	controls?: false

	resize?: false
	
	old-graph: graph: none
	graph-specs: [
		order-mode: none
		order-blk: none
		values-mode: 'absolute
		hide-zeros?: false
		full-scaling?: false
		quadratic?: false
		type:
		subtype: none
		title-color: white
		back-color: white
		grid-color: black
		lwidth: 1
		point-color:
		point-size:
		point-shapes:
		point-shape: none
		font: make face/font [
			size: 18
		]
		font-size: none
		title: none
		x-label:
		y-label:
		y-label-horiz: none
		min-value:
		max-value:
		min-gap:
		max-gap:
		alpha: 0
		fill-alpha: 0
		data: none
		;BB added
		grid-type: none
		;
		points-array: none
		point-action: none
		tool-tip-action: none

		pan-action?: all [graph graph/pan-action?]
		zoom-action?: all [graph graph/zoom-action?]
		zoom-action: none
		mouse-wheel-action: none
		pan-action: none
		tool-tip-delay: none
		tool-tip-coords: none
		tool-tip-handler: none
		
		dec-nums: 3
		dec-nums-x: 0
		dec-nums-y: 0
		
;NEEDS CLEANUP!!! --Cyphre
	img: none
;	draw-result: none
	last-graph-size: none
	size-value: graph-size: none
	offset-value: 0x0
	graph-data: none
	graph-controls: none
	zoom-slider: all [graph graph/zoom-slider]
	update-zoom-slider: none
	pan-graph: none
	hilited-points: none
	selected-points: none
	cross-hair: none
	hilite-points?: false
	cross-hair?: false
	reset: none
	shadows?: false
	x-scale-coords: x-scale-axis: y-scale-coords: y-scale-axis: none
	
	;xyplot locals
	vp-box: none
	selected-point-ids: any [all [graph graph/selected-point-ids] make list! []]
	point-colors: reduce [red leaf]
	cross-hair-color: 255.200.0.192
	x-scale-pen: y-scale-pen: grid-pen: grid-pen2: 0.0.0.0 ;alpha part is a must here
	bl-padding:	tr-padding: none
	line-widths: any [all [graph graph/line-widths] array/initial 3 1]
	shadow-widths: any [all [graph graph/shadow-widths] copy []]
	mouse-oft: any [all [graph graph/mouse-oft] none]
	last-mouse-pos: any [all [graph graph/last-mouse-pos] none]
	trans-pos: any [all [graph graph/trans-pos] 0x0]
	x-grid-values:
	y-grid-values:
	get-point-shape:
	get-selection-shape:
	auto-precision:
	update-anim-points:
	update-mouse-pos:
	update-cross-hair:
	make-scale-x:
	make-scale-y:
	make-grid:
	update-widths:
	update-selected-points:
	center-mouse-pos:
	grad-img:
	graph-layer-cache:
	graph-layer-dialect:
	graph-layer:
	labels-layer:
	clip-points:
	all-points:
	bkg-layer:
	grid-layer:
	shadows-layer:
	shadows-layer-dialect:
	point-count:
	last-hilite:
	alternate-labels:
	update-center:
	update-trans:
	set-main-scale:
	update-grid:
	update-vp-box:
	pan?:
	zoom?:
	match-points:
	lh-plot:
	rh-plot:
	above-plot:
	x-spread-value:
	y-spread-value:
	x-ratio:
	y-ratio:
	convert*:
	below-plot:
	compute-scaleOLD:
	compute-scale:
	compute-grid:
	layer1:
	data-length: none
	visible-points: all [graph graph/visible-points]
	points-colors: none
	;spider locals
	chart-centre:
	spider-radius:
	category-horiz:
	category-vert:
	direction-block:
	auto-scale-ticks:
	tick-distance:
	scale-max:
	spider-ratio:
	data-count:
	angle:
	direction:
	position-x:
	position-y: none

	clip-face: any [all [graph graph/clip-face] none]
	size-data: face/size
	offset-data: 0x0
	;current-font: default-font: make ctx-rebgui/widgets/default-font []
	axis-label-font: make face/font [style: 'bold size: 14]
	current-font: default-font: make face/font []
	current-pen: default-pen: black
	current-fill-pen: none
	current-grid-pen: 0.0.0
	
	legend-colors: make block! 0
	legend-pen: black

	scale-data: none ; scale
	scale-font: none
	
	categories-data: none ; list of strings describing data
	category-font: current-font
	
	data-max: 0.0 ; maximal data value
	data-data: make block! 0 ; charted data

	precision-data: 1
	
	auto-scaling?: no
	scales: none
	
	empty-graph?: true
	
;xyplot part

;	current-font: default-font: make system/words/face/font []
;	current-pen: default-pen: white
;	current-fill-pen: none

;	legend-colors: make block! 0
;	legend-pen: none

;	scale-font: current-font
;	scale-max: none
	x-min-value: none
	x-max-value: none
	x-scale-ticks: 0 ;set 0 to autoscale
	y-min-value: none
	y-max-value: none
	y-scale-ticks: 0 ;set 0 to autoscale
	x-data-min-value: none
	x-data-max-value: none
	y-data-min-value: none
	y-data-max-value: none
	x-scale-font: none
	y-scale-font: none
	init-x-scale-font: does [
		x-scale-font: any [
			x-scale-font
			make current-font []
		]
	]
	init-y-scale-font: does [
		y-scale-font: any [
			y-scale-font
			make current-font []
		]
	]
	log-x: false
	log-y: false
	
	; change the default, Ladislav
	x-precision-value: none
	y-precision-value: none

	f: none
	l-size: none
	xy-to-graph: screen-to-xy: screen-to-xy-precise: none

	]
	
	trim-decimal: func [
		num [number!]
		cifre [integer!]
		/no-round
		/local m n o p q result
	][
		p: ""
		either find num: form num #"e" [
			result: copy ["0" ""]
			parse num [
				any [copy m to #"." skip] copy n to #"E" skip o: (
					all [
						not m
						m: n
						n: ""
					]
					all [
						m/1 = #"-"
						m: next m
						p: #"-"
					]
					q: (length? m) + to integer! o
					any [
						all [
							q <= 0
							result/2: rejoin [(head insert/dup copy "" #"0" abs q) m n]
						]
						result/1: rejoin [o: join m n (head insert/dup copy "" #"0" (q - length? o))]
					]
				)
			]
		][
			result: parse num "."
			all [
				not result/2
				insert tail result ""
			]
		]
;		o: skip tail result/1 -3
;		while [all [not head? o #"-" <> first back o]][insert o #"." o: skip o -3]
		m: pick result/2 cifre + 1
		result/2: copy/part result/2 cifre
		unless any [no-round empty? result/2] [
			if m [
				m: form round to decimal! rejoin [skip tail result/2 -2 "." m]
				either (length? result/2) >= length? m [
					change skip tail result/2 negate length? m m
				][
					either #"-" = n: first result/1 [remove result/1][n: none]
					result/1: form 1 + to integer! result/1
					result/2: form last m
					if n [insert result/1 n]
				]
			]
		]
		insert/dup tail result/2 #"0" cifre - length? result/2	
		all [result/1/1 = #"0" not find result/2 charset [#"1" - #"9"] p: ""]
		all [cifre > 0 insert next result #"."]
		join p result
	]

	size-text-face: make face [
		size: 1000000x1000000
	]
	
;get graphs
	graphs: [
		bar [ #include %charts/chart-bar.r ]
		pie [ #include %charts/chart-pie.r ]
		spider [ #include %charts/chart-spider.r ]
		xyplot [ #include %charts/chart-xyplot.r ]
	]

	draw-graph: func [
		graph [object!]
		graph-size [pair!]
		/local result old-vp
	][
		if any [
			not graph/type
			not graph/data
			empty? graph/data
		][
			return none
		]
		effect: copy [merge]

		if graph-size <> old-size [
			old-vp: this/viewport
			this/viewport: make object! viewport-specs
		]
		
		graph/size-value: graph/graph-size: graph-size * this/viewport/vscale-inv
		graph/graph-data: copy/deep graph/data

		if graph/font-size [
			either equal? 'xyplot graph/type 
			[
				 ;do not resize font for XYPLOT
				graph/font/size: graph/font-size
			][
				graph/font/size: to integer! graph/font-size * 0.2 * graph-size/y
			]
		]

		graph/bkg-layer: []
		graph/grid-layer: []
		graph/x-scale-axis: []
		graph/x-scale-coords: []
		graph/y-scale-axis: []
		graph/y-scale-coords: []
		
		if graph/back-color insert tail clear graph/bkg-layer compose [
			pen none fill-pen graph/back-color
			box 0x0 size
		]
		
;===choose graph type
		graph/graph-layer: result: switch graph/type bind graphs in graph 'self ;added BB
		unless viewport/x-center-neg [
			viewport/x-center-neg: negate viewport/x-center: graph/size-value/x / 2 + graph/offset-value/x - viewport/x-trans
			viewport/y-center-neg: negate viewport/y-center: graph/size-value/y / 2 + graph/offset-value/y - viewport/y-trans
		]
		if all [this/graph/trans-pos <> 0x0 old-vp] [
			;transform old viewport values
			this/graph/set-main-scale/abs-scale old-vp/x-scale
			this/graph/update-trans/abs-pos 
				old-vp/x-trans / (old-graph/size-value/x / (old-vp/x-max-value - old-vp/x-min-value)) * (graph/size-value/x / (this/viewport/x-max-value - this/viewport/x-min-value))
				old-vp/y-trans / (old-graph/size-value/y / (old-vp/y-max-value - old-vp/y-min-value)) * (graph/size-value/y / (this/viewport/y-max-value - this/viewport/y-min-value))
			old-graph: none
		]
;===add graph title
		if graph/title [
			insert tail result compose [
				fill-pen (graph/title-color)
				pen none
				text vectorial (
					as-pair 320 - (
						size-text-face/text: translate graph/title
						size-text-face/font: graph/font
						(first size-text size-text-face) / 2
					) graph/font/size
				)(translate graph/title)
			]
		]

		if all [this/controls? graph/graph-controls not this/pane/2] [
			this/pane/2: layout/only/origin bind graph/graph-controls in graph 'self 0x0; as-pair graph-size/x - 80 20]
			this/pane/2/offset: as-pair graph-size/x * this/viewport/vscale - 80 20
			this/pane/2/effect: this/pane/2/color: none
		]
		
		if all [not this/controls? this/pane/2][
			this/pane/2: none
		]
		
;===insert resizing to the beginnig
		insert result compose [
		
			(either equal? 'xyplot graph/type [
				;	XYPLOT graph does not need to be resized
				use [min-size][
					if graph/quadratic? [
						;print "quadrant"
						min-size: min graph-size/x graph-size/y
						graph-size/x: graph-size/y: min-size
					]
					compose [
;						line-width 3
;						pen none fill-pen red
;						circle oft 3 3
						scale viewport/vscale viewport/vscale
						translate viewport/x-trans viewport/y-trans
						translate viewport/x-center viewport/y-center
						scale viewport/x-scale viewport/y-scale
						translate viewport/x-center-neg viewport/y-center-neg
					]
				]
			][
				compose [scale (
					either graph/quadratic? [
						min graph-size/x / 640 graph-size/y / 480
					][
						graph-size/x / 640
					]
				) (
					either graph/quadratic? [
						min graph-size/x / 640 graph-size/y / 480
					][
						graph-size/y / 480
					]
				)]
			])
			font (graph/font)
			line-width graph/line-widths/1
		]

		graph/graph-layer-cache: make image! graph-size
		graph/graph-layer-cache/rgb: 220.220.220.255
		graph/graph-layer-dialect: graph/graph-layer
		draw graph/graph-layer-cache either graph/all-points [graph/clip-points][graph/graph-layer-dialect]
		
		graph/graph-layer: copy [image graph/graph-layer-cache]
		graph/selected-points: []
		graph/hilited-points: []

		unless graph/bkg-layer [exit]
comment {
		print [
			"bkg-layer" length? graph/bkg-layer
			"grid-layer" length? graph/grid-layer
			"x-scale-axis" length? graph/x-scale-axis
			"x-scale-coords" length? graph/x-scale-coords
			"y-scale-axis" length? graph/y-scale-axis
			"y-scale-coords" length? graph/y-scale-coords
			"graph-layer" length? graph/graph-layer
			"selected-points" length? graph/selected-points
			"hilited-points" length? graph/hilited-points
		]
}		
		effect: compose [
			merge
			(
				reduce [
					'draw graph/bkg-layer
					'draw graph/grid-layer
					'draw graph/x-scale-axis
					'draw graph/x-scale-coords
					'draw graph/y-scale-axis
					'draw graph/y-scale-coords
					'draw graph/graph-layer
					'draw graph/labels-layer
					'draw graph/selected-points
					'draw graph/hilited-points
				]
			)
			(
				either graph/alpha > 0 [
					[alphamul graph/alpha]
				][
					[]
				]
			)
			(
				either graph/cross-hair? [
					reduce  ['draw graph/cross-hair: compose [
						scale viewport/vscale viewport/vscale
						clip (viewport/vscale * graph/offset-value) (graph/offset-value + graph/size-value * viewport/vscale)
						translate viewport/x-trans viewport/y-trans
						translate viewport/x-center viewport/y-center
						scale viewport/x-scale viewport/y-scale
						translate viewport/x-center-neg viewport/y-center-neg
						pen graph/cross-hair-color ;255.200.0.192
						line-width graph/line-widths/1
						fill-pen none
						line 0x0 0x0
						line 0x0 0x0
						]
					]		
				][
					[]
				]
			)
		]
		this/graph/update-cross-hair
]

	render-graph: does [
		if any [none? graph/img graph/graph-size <> graph/last-graph-size][
			graph/img: make image! graph/last-graph-size: graph/graph-size
		]
		either none? graph/back-color [
			graph/img/rgb: 0.0.0.255
		][
			graph/img/rgb: graph/back-color
		]
		draw graph/img graph/draw-result
		all [graph/back-color graph/img/alpha: graph/alpha]
		graph/img
	]

	regenerate-on-redraw: true
	description: []
	old-size: size: -1x-1
	this: none
	
	; initialization
	description: face/data

;------
	parse-specs: func [
		[catch]
		gdata [block!]
		/local
			result graph-types var var2 mark lad?
	][
		result: make object! graph-specs
		graph-types: [
			'pie set var2 opt 'torus
		 	| 'bar set var2 ['horizontal | 'vertical | 'stacked]
			| 'spider ;BB
			| 'xyplot ;BB
		]

;---------
		;print "desc parsing"
		parse description: gdata [
			some [
				(var: var2: none)
				'graph set var graph-types (result/type: var result/subtype: var2)
				;;;;
				;;;;;;SPIDER KEYWORDS;;;;;;
				| 'grid some [
					set var pair! 
					| 'circle (result/grid-type: 'circle )
				;	| set var tuple!  (result/grid-color: var)
				;	| set var word!  (var result/grid-color: get var)
				] opt [set var [tuple! | word!] (result/grid-color: either word? var [get var][var])] 
				| 'limit pair! pair!
				;Lad's keywords are added so parser won't crash, no action done
				| 'pen set var [word! | tuple!] ()
;				| 'fill-pen set var [word! | tuple!] ()
;				| 'scale set var number! ()
				| 'graph-transparency set var integer! (result/fill-alpha: var)
				| 'legend pair! block! ()
				;following keywords are for xyplot to run
				| 'x-scale number!
				| 'x-min number!
				| 'x-max number!
				| 'x-grid number!
				| 'x-axis
				| 'y-scale number!
				| 'y-min number!
				| 'y-max number!
				| 'y-grid number!
				| 'y-axis
				| 'x-precision number!
				| 'y-precision number!
				| 'scale pair!
;				| 'point integer! block!
				| 'color-ranges block!
				| 'style word! integer! () ;style: plot (plot size) line (line thickness)
				| 'tool-tip-coords
				| 'point-action block!
				| 'pan-action block!
				| 'zoom-action block!
				| 'mouse-wheel-action block!
				| 'tool-tip-action block!
				| 'tool-tip-delay time!
				| 'graph-pan
				| 'graph-zoom
				| 'graph-max-zoom set var number! (viewport/scale-max: max 1 var)
				| 'graph-controls (controls?: true)
				| 'hilite-points (result/hilite-points?: true)
				| 'cross-hair (result/cross-hair?: true)
				| 'cross-hair-color set var [tuple! | word!] (result/cross-hair-color: either word? var [get var][var])
				| 'point-over-color [word! | tuple!]
				| 'point-select-color [word! | tuple!]
				| 'shadows (result/shadows?: true)
				;---
;				| 'directions (print "SPIDER:directions")
;				| 'odata set var [block! | word!] (result/data: either block? var [var][get var])
				;odata is temporary
				;;;;;;
				| 'back-color set var [tuple! | word!](result/back-color: either word? var [get var][var])
				| 'grid-color set var [tuple! | word!] (result/grid-color: either word? var [get var][var])
				| 'line-width set var number! (result/lwidth: var)
				| 'point-color set var [tuple! | word!] (result/point-color: either word? var [get var][var])
				| 'point-size set var number! (result/point-size: var)
				| 'point-shape set var ['square | 'circle | 'diamond | 'cross | 'triangle | 'dot] (result/point-shape: var)
				| 'graph-font set var object! (result/font: var)
				| 'font-size set var integer! (result/font-size: var)
				| 'title opt [set var [tuple! | word!] (result/title-color: either word? var [get var][var])] set var [string! | word!] (result/title: get 'var)
				| 'x-label set var [string! | word!] (result/x-label: get 'var)
				| 'y-label set var [string! | word!] (result/y-label: get 'var)
				| 'y-label-horiz set var [string! | word!] (result/y-label-horiz: get 'var)
				| 'min-value set var [pair! | integer!] (result/min-value: var)
				| 'max-value set var [pair! | integer!] (result/max-value: var)
				| 'min-gap set var number! (result/min-gap: var)
				| 'max-gap set var number! (result/max-gap: var)
				| 'data set var [block! | word!] (result/data: either block? var [var][get var])
				| 'transparency set var integer! (result/alpha: var)
				| 'order-by set var ['size-up | 'size-down | 'id set var2 [block! | word!] (result/order-blk: either block? var2 [var2][get var2])] (result/order-mode: var)
				| 'show-values-as set var ['percentage | 'absolute] (result/values-mode: var)
				| 'hide-zero-values (result/hide-zeros?: true)
				| 'full-scaling (result/full-scaling?: true)
				| 'quadratic-ratio (result/quadratic?: true)
				| mark: (if not tail? mark [throw make error! rejoin ["chart dialect: bad syntax near: " copy/part mold/only mark 40 "..."]]) end skip

				
			]
		]
		return result
		

	]

	set-colors: func [colors [block!] /local idx][
		if graph [
			idx: 0
			while [not tail? graph/data][
				idx: idx + 1
				graph/data/2: any [colors/:idx graph/data/2]
				graph/data: skip graph/data 3
			]
			graph/data: head graph/data
;			graph-layer: draw-graph graph size
			draw-graph graph size
			show self
		]
	]

	on-resize: does [
		this/resize?: this/graph/update-vp-box
	]
	
	redraw: has [/no-show] [
		either regenerate-on-redraw [
			this/controls?: false
			old-graph: graph
			graph: parse-specs data
;			print ["REDRAW" now/time/precise]
;			graph-layer: draw-graph graph size

			draw-graph graph size
			if all [graph/selected-point-ids not empty? head graph/selected-point-ids][
				graph/update-selected-points
			]
		][
;			render-graph
;print ""
;foreach x this/effect [if block? x [prin [length? x " "]]]
			if query/clear viewport [
				graph/graph-layer: compose [image 0x0 (graph/graph-layer-cache/rgb: 220.220.220.255 draw graph/graph-layer-cache either graph/all-points [graph/clip-points][graph/graph-layer-dialect])]
			]
			regenerate-on-redraw: true
		]

		if this/resize? [
			this/set-viewport-xy/no-show this/resize?
			this/resize?: false
			regenerate-on-redraw: false
			redraw/no-show
			exit
		]

		if all [this/controls? graph/graph-controls this/pane/2] [
			this/pane/2/offset: as-pair graph/graph-size/x * this/viewport/vscale - 80 20
		]

		unless no-show [
			show self
		]
	]

	save-image: func [
		dst [file!]
		/bmp
	][
		either bmp [
			save/bmp dst image
		][
			save/png dst image
		]
	]

	on-mouse-move: none
	on-mouse-up: none
	on-mouse-down: none
	on-mouse-drag: none
	on-mouse-scroll: none
	on-mouse-away: none
	on-time: none

	select-point: none
	set-point: none
	goto-point: none
	anim-point: none

	feel: make default-feel [
		down?: false
		detect: func [f e ][
			either find [down alt-down] e/type [
				down?: true
				return e
			][
				if find [up alt-up] e/type [
					down?: false
					return e
				]
			]
			all [not down? in f 'on-mouse-move f/on-mouse-move e/offset - win-offset? f]
			e
		]
		redraw: func [fac act pos][
			if act = 'show [
				fac/redraw/no-show
			]
			
;BB added from spider
;			if all [act <> 'hide face/old-size <> face/size] [
;				face/old-size: face/size
;				face/redraw
;			]
;----------------------
		]
		over: func [f into pos][
			all [not into in f 'on-mouse-away f/on-mouse-away pos]
		]
		mouse-p: none
		engage: func [f a e][
			switch a [
				down [
					mouse-p: e/offset
					if system/view/focal-face <> f [
						ctx-rebgui/edit/focus f
					]
					all [in f 'on-mouse-down f/on-mouse-down e]
				]
				up [
					mouse-p: none
					all [in f 'on-mouse-up f/on-mouse-up e]
				]
				scroll-line [
					all [in f 'on-mouse-scroll f/on-mouse-scroll e]
				]
				time [
					all [in f 'on-time f/on-time f]
				]
			]
			if find [over away] a [
				all [mouse-p in f 'on-mouse-drag f/on-mouse-drag e e/offset - mouse-p mouse-p: e/offset]
			]
		]
	]

	focus-action: :on-focus
	unfocus-action: :on-unfocus	

	clear-graph: does [
		all [graph graph/reset]
	]

	set-graph: func [data [block!] /no-show][
		;avoid clearing of same data block
		if self/data = data [self/data: copy []]
		all [graph graph/reset]
		self/data: data
		re-init
		any [no-show show self]
	]

	get-viewport: func [
	][
		return make this/viewport []
	]
	
	set-viewport: func [
		viewport-obj [object!]
		/no-show
	][
		this/viewport: viewport-obj
		this/graph/update-widths
		this/graph/update-zoom-slider
;		this/regenerate-on-redraw: true
		either no-show [redraw/no-show][redraw]
	]

	get-viewport-xy: has [
		x1 y1 x2 y2 oft siz
	][
		oft: this/graph/offset-value
		siz: oft + this/graph/size-value

		set [x1 y2] this/graph/screen-to-xy-precise oft/x * this/viewport/vscale oft/y * this/viewport/vscale
		set [x2 y1] this/graph/screen-to-xy-precise siz/x * this/viewport/vscale siz/y * this/viewport/vscale

		reduce [
			x1 - oft/x / this/graph/x-ratio + this/graph/x-min-value
			siz/y - y1 / this/graph/y-ratio + this/graph/y-min-value
			x2 - oft/x / this/graph/x-ratio + this/graph/x-min-value
			siz/y - y2 / this/graph/y-ratio + this/graph/y-min-value
		]
	]
	
	set-viewport-xy: func [
		coords [block!]
		/no-show
		/center		
		/local
			x1 y1 x2 y2 dx dy pos tmp rx ry rrx rry sc
	][
		set [x1 y1 x2 y2] coords
		if y2 < y1 [
			tmp: y2
			y2: y1
			y1: tmp
		]
		if x2 < x1 [
			tmp: x2
			x2: x1
			x1: tmp
		]

		rx: x2 - x1
		ry: y2 - y1

		sc: either (rrx: this/graph/x-ratio * rx) > (rry: this/graph/y-ratio * ry) [
			all [center y2: y2 + ((this/graph/y-spread-value / this/graph/x-spread-value) * rx - ry / 2)]
			this/graph/size-value/x / rrx
		][
			all [center x1: x1 - ((this/graph/x-spread-value / this/graph/y-spread-value) * ry - rx / 2)]
			this/graph/size-value/y / rry
		]

		if any [
			sc < this/viewport/scale-min
			sc > this/viewport/scale-max
		][
			return false
		]
		
		this/graph/set-main-scale/abs-scale sc

		pos: this/graph/convert*/precise x1 y2

		dx: (this/viewport/x-center - pos/1) * this/viewport/x-scale + (this/graph/offset-value/x - this/viewport/x-center)
		dy: (this/viewport/y-center - pos/2) * this/viewport/y-scale + (this/graph/offset-value/y - this/viewport/y-center)

		this/graph/update-trans/abs-pos dx dy

		this/graph/update-grid

		unless no-show [
			this/graph/update-zoom-slider
			this/regenerate-on-redraw: false
			show this
		]
		this/graph/center-mouse-pos
	]

	state-words: [
		data
		[
			use [d][
				d: copy/deep data
				foreach w [x-label y-label y-label-horiz data][
					if word? select d w [
						d/:w: get d/:w
					]
				]
				d
			]
		]
		visible-points [all [graph graph/visible-points to-block head graph/visible-points]]
		selected-points [all [graph graph/selected-point-ids to-block head graph/selected-point-ids]]
		viewport
		anim-points [
			reduce [
				all [graph graph/clip-face graph/clip-face/points]
				all [graph graph/clip-face graph/clip-face/duration]
				rate
				all [graph graph/clip-face graph/clip-face/pcolor]
			]
		]
		show?
	]

	state-action: make function! [word [word!] value /local p] [
		p: self

		switch/default word [
			data [p/set-graph/no-show value]
			visible-points [if :value [p/set-point/no-show 'all false p/set-point/no-show :value true]]
			selected-points [if all [get in p 'select-point :value] [p/select-point/no-show 'all false p/select-point/no-show :value true]]
			viewport [p/set-viewport :value]
			anim-points [if :value/1 [p/anim-point/color :value/1 :value/2 :value/3 :value/4]]
		][
			either series? :value [insert clear get word :value][set word :value]
		]
	]

	re-init: init: make function! [] [
		this: self
		pane: reduce [none none]
		either block? data [
			redraw/no-show
		][
			throw make error! "chart widget: no data block supplied"
		]
	]
	if negative? size/x [size/x: 200]
	if negative? size/y [size/y: 200]
	color: any [color none] ;system/words/face/color]
	old-size: size
	;redraw
]
