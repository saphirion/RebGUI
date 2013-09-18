REBOL [
	Date: 14-Sep-2011/22:07:17+2:00
]

; define the necessary functions

auto-precision: func [
	{calculate auto precision (a power of 10.0)}
	min-value [number!]
	max-value [number!]
	slack [number!] {the "slack space" limit}
	/local precision rounded-min rounded-max
][
	; zero range?
	if min-value = max-value [return 1.0]
	
	; start with "the most significant digit" precision
	precision: max abs min-value abs max-value	
	precision: 10.0 ** round/ceiling log-10 precision
	
	slack: 1.0 + slack
	
	while [
		rounded-min: round/floor/to min-value precision
		rounded-max: round/ceiling/to max-value precision
		(rounded-max - rounded-min) / (max-value - min-value) >  slack
	][
		precision: precision / 10.0
	]

	precision
]

reset: does [
	all [this/data clear this/data]
	all [bkg-layer clear bkg-layer]
	all [grid-layer clear grid-layer]
	all [x-scale-axis clear x-scale-axis]
	all [x-scale-coords clear x-scale-coords]
	all [y-scale-axis clear y-scale-axis]
	all [y-scale-coords clear y-scale-coords]
	all [hilited-points clear hilited-points]
	all [selected-points clear selected-points]
	all [cross-hair clear cross-hair]
	all [graph-layer clear graph-layer]
	visible-points: none
	this/on-mouse-move:
	this/on-mouse-up:
	this/on-mouse-scroll:
	this/on-mouse-drag:
	this/on-mouse-away:
	this/graph: 
	this/pane: none
	this/viewport: make object! this/viewport-specs
	this/regenerate-on-redraw: true
]

compute-scale: lfunc [
	scale-ticks [number! block!]
	scale-min [word!]
	scale-max [word!]
][][
	if block? scale-ticks [return scale-ticks]

	scale: make block! 0

	scale-min-value: get scale-min
	scale-max-value: get scale-max

	append scale scale-min-value

	tick-distance: scale-max-value - scale-min-value / scale-ticks

	precision: auto-precision 0.0 tick-distance 0.15
	
	repeat i scale-ticks - 1 [
		append scale round/to tick-distance * i + scale-min-value precision
	]

	append scale scale-max-value

	scale
]

compute-scaleOLD: lfunc [
	scale-ticks [number! block!]
	scale-min [word!]
	scale-max [word!]
	log? [logic!]
	precision [number!]
][][
	if block? scale-ticks [return scale-ticks]

	scale: make block! 0

	scale-min-value: get scale-min
	scale-max-value: get scale-max

	append scale scale-min-value

	tick: none
	log-scale-min: none

	if log? [
		; ATT! may be problematic
		log-scale-min: log-e scale-min-value
		either decimal? scale-ticks [
			tick-distance: scale-ticks
			scale-ticks: (log-e scale-max-value / scale-min-value) / tick-distance
		][
			tick-distance: (log-e scale-max-value / scale-min-value) / scale-ticks
		]
		scale-max-value: max
			scale-max-value
			round/to exp tick-distance * scale-ticks + log-scale-min precision
		set scale-max scale-max-value

		repeat i scale-ticks [
			append scale round/to exp tick-distance * i + log-scale-min precision
		]
		return scale
	]

	tick-distance: round/floor/to either decimal? scale-ticks [
		scale-ticks
	][
		scale-max-value - scale-min-value / scale-ticks
	] precision
	if zero? tick-distance [tick-distance: precision]
	if integer? scale-ticks [
		scale-max-value: max
			scale-max-value
			tick-distance * scale-ticks + scale-min-value
		set scale-max scale-max-value
	]

	scale-ticks: round/floor scale-max-value - scale-min-value / tick-distance

	repeat i scale-ticks [
		append scale tick-distance * i + scale-min-value
	]

	scale
]

compute-grid: lfunc [grid scale-min scale-max][][
	if block? grid [return grid]

	grid-count: grid
	grid-distance: none

	grid: make block! 0
	append grid scale-min

	either decimal? grid-count [
		grid-distance: grid-count
		grid-count: round/floor scale-max - scale-min / grid-distance
	][
		grid-distance: scale-max - scale-min / grid-count
	]

	repeat i grid-count [append grid grid-distance * i + scale-min]

	grid
]

clip-points: has [
	sl gl
][
	update-vp-box
	append sl: copy graph-layer-dialect copy/part all-points 3
	gl: copy/part all-points 5
	foreach [x y s p] skip all-points 5 [
		all [
			x >= vp-box/1
			x <= vp-box/3
			y <= vp-box/4
			y >= vp-box/2
			insert tail gl p
			insert tail sl s
		]
	]
	insert tail sl gl
	sl
]

make-scale-x: func [
	/ticks
		tb [block!]
	/even
		tmp [logic!]
	/local
		xfs
		clip-point-b
		clip-point-e
		start-point
		end-point
		x-coordinate
		f
		idx
		start-point2
		pen-e
		pen-o
		fpen-e
		fpen-o
		f-max
		coords
		n
		d
][
	unless tb [tb: x-scale-ticks]

	clear x-scale-axis
	clear x-scale-coords
	xfs: round x-scale-font/size / 2
	clip-point-b: convert* x-min-value y-min-value
	clip-point-b/x: clip-point-b/x - xfs - 1
	clip-point-e: convert* x-max-value y-max-value
	clip-point-e/y: clip-point-b/y + (x-scale-font/size * 3)
	clip-point-e/x: clip-point-e/x + xfs
	insert tail x-scale-coords [font x-scale-font pen none]
	f-max: 0
	size-text-face/font: x-scale-font
	idx: 0
	clear this/viewport/x-trans-txt-spec

	all [none? tmp tmp: true]

	pen-e: compose [pen graph/grid-pen]
	fpen-e: compose [fill-pen graph/x-scale-font/color]
	pen-o: compose [pen graph/x-scale-pen]
	fpen-o: compose [fill-pen graph/x-scale-pen]
	coords: clear []
	graph/dec-nums-x: 0

	forall tb [
		; draw the tick
		start-point: convert* tb/1 y-min-value
		end-point: as-pair start-point/x start-point/y + xfs
		insert tail either tmp [pen-e][pen-o] compose [
			line (start-point) (end-point)
		]
		
		n: graph/dec-nums

		while [
			x-coordinate: this/strip-zero this/trim-decimal/no-round tb/1 n
			d: none
			any [
				all [
					tb/2
					(d: to-decimal x-coordinate) >= tb/2
				]
				all [
					tb/-1
					(any [d to-decimal x-coordinate]) <= tb/-1
				]
			]
		][
			n: n + 1
		]
		graph/dec-nums-x: max graph/dec-nums-x n

		insert tail coords x-coordinate
		
		size-text-face/text: x-coordinate
		f: size-text size-text-face
		f-max: max f-max f/x
;		clip-point-e/x: max clip-point-b/x start-point/x
		start-point: as-pair start-point/x - round f/x / 2
			start-point/y + x-scale-font/size + either all [
				alternate-labels odd? idx
			][x-scale-font/size][0]
		idx: idx + 1
		insert tail this/viewport/x-trans-txt-spec compose [this/viewport/x-scale - 1 * (start-point/x + (f/x / 2))]
		insert tail either tmp [fpen-e][fpen-o] compose/deep [
			push [
				scale viewport/x-scale-inv 1
				translate (to-path reduce ['viewport 'x-trans-txt idx]) 0
				text vectorial (start-point) (x-coordinate)
			]
		]
		tmp: not tmp
	]
	
	graph/dec-nums-x: graph/dec-nums-x + 1
	
	insert x-scale-axis compose [
		fill-pen default-pen
		pen default-pen
		line-width 2
		line
			(tmp: as-pair graph/offset-value/x * viewport/vscale graph/size-value/y + graph/offset-value/y * viewport/vscale)
			(as-pair graph/size-value/x + graph/offset-value/x * viewport/vscale tmp/y)		
	
		scale viewport/vscale viewport/vscale
		translate viewport/x-trans 0
		translate viewport/x-center viewport/y-center
;		scale viewport/x-scale-grid viewport/grid-mul-inv
		scale viewport/x-scale 1
;		translate viewport/x-center-neg-grid viewport/y-center-neg-grid
		translate viewport/x-center-neg viewport/y-center-neg
		line-width line-widths/3
		fill-pen default-pen
		pen default-pen
		clip (viewport/vscale * (clip-point-b + as-pair xfs + 1 0)) (viewport/vscale * clip-point-e)
	]
	insert tail x-scale-axis pen-e
	insert tail x-scale-axis pen-o

	insert x-scale-coords compose [
		scale viewport/vscale viewport/vscale
		translate viewport/x-trans 0
		translate viewport/x-center viewport/y-center
		scale viewport/x-scale 1
		translate viewport/x-center-neg viewport/y-center-neg
		clip (viewport/vscale * (clip-point-b + as-pair negate f-max: f-max / 2 viewport/vscale-inv * 10))
			 (viewport/vscale * (clip-point-e + as-pair f-max 0))
		fill-pen default-pen
		pen default-pen
		line-width line-widths/1
	]
	insert tail x-scale-coords fpen-e
	insert tail x-scale-coords fpen-o
	
	viewport/x-trans-txt: reduce viewport/x-trans-txt-spec
]

make-scale-y: func [
	/ticks
		tb [block!]
	/even
		tmp [logic!]
	/local
		yfs
		clip-point-b
		clip-point-e
		start-point
		end-point
		y-coordinate
		f
		idx
		start-point2
		pen-e
		pen-o
		fpen-e
		fpen-o
		coords
		n
		d
][
	unless tb [
		tb: y-scale-ticks
	]
	
	clear y-scale-axis
	clear y-scale-coords
	yfs: round y-scale-font/size / 2
	clip-point-b: as-pair 0 offset-value/y - yfs * viewport/vscale
	clip-point-e: viewport/vscale * convert* x-min-value y-min-value
	clip-point-e/y: clip-point-e/y + (viewport/vscale * yfs + .5)
	insert tail y-scale-coords [font y-scale-font pen none]
	start-point: none
	end-point: none
	y-coordinate: none
	f: none
	size-text-face/font: y-scale-font
	idx: 0
	clear this/viewport/y-trans-txt-spec
	all [none? tmp tmp: true]
	pen-e: compose [pen graph/grid-pen]
	fpen-e: compose [fill-pen graph/y-scale-font/color]
	pen-o: compose [pen graph/y-scale-pen]
	fpen-o: compose [fill-pen graph/y-scale-pen]
	coords: clear []
	graph/dec-nums-y: 0
	forall tb [
		; draw the tick
		start-point: convert* x-min-value tb/1
		end-point: as-pair start-point/x - yfs start-point/y
		insert tail either tmp [pen-e][pen-o] compose [
			line (start-point) (end-point)
		]

		n: graph/dec-nums
		while [
			y-coordinate: strip-zero this/trim-decimal/no-round tb/1 n
			d: none
			any [
				all [
					tb/2
					(d: to-decimal y-coordinate) >= tb/2
				]
				all [
					tb/-1
					(any [d to-decimal y-coordinate]) <= tb/-1
				]
			]
		][
			n: n + 1
		]
		graph/dec-nums-y: max graph/dec-nums-y n

		insert tail coords y-coordinate
		
		size-text-face/text: y-coordinate
		f: size-text size-text-face
		start-point: as-pair start-point/x - (y-scale-font/size / 2) - f/x
			start-point/y - yfs
		idx: idx + 1
		insert tail this/viewport/y-trans-txt-spec compose [
			this/viewport/y-scale - 1 * (start-point/y + (to-integer y-scale-font/size / 2))
		]
		insert tail either tmp [fpen-e][fpen-o] compose/deep [
			push [
				scale 1 viewport/y-scale-inv
				translate 0 (to-path reduce ['viewport 'y-trans-txt idx])
				text vectorial (start-point) (y-coordinate)
			]
		]
		tmp: not tmp
	]

	graph/dec-nums-y: graph/dec-nums-y + 1
	
	insert y-scale-axis compose [
		scale viewport/vscale viewport/vscale
		translate 0 viewport/y-trans
		translate viewport/x-center viewport/y-center
;		scale viewport/grid-mul-inv viewport/y-scale-grid
		scale 1 viewport/y-scale
;		translate viewport/x-center-neg-grid viewport/y-center-neg-grid
		translate viewport/x-center-neg viewport/y-center-neg
		line-width graph/line-widths/3
		clip (clip-point-b) (clip-point-e)
		fill-pen default-pen
		pen default-pen
	]
	insert tail y-scale-axis pen-e
	insert tail y-scale-axis pen-o

	insert y-scale-coords compose [
		fill-pen default-pen
		pen default-pen
		line-width 2
		line
			(tmp: as-pair viewport/vscale * graph/offset-value/x graph/size-value/y + graph/offset-value/y * viewport/vscale)
			(as-pair tmp/x graph/offset-value/y * viewport/vscale)

		scale viewport/vscale viewport/vscale
		translate 0 viewport/y-trans
		translate viewport/x-center viewport/y-center
		scale 1 viewport/y-scale
		translate viewport/x-center-neg viewport/y-center-neg
		clip (clip-point-b) (clip-point-e + 1)
		line-width line-widths/1
;		line (convert* 0 vp-box/2) (convert* 0 vp-box/4)		
;		line
;			(tmp: as-pair graph/offset-value/x graph/size-value/y + graph/offset-value/y)
;			(as-pair tmp/x graph/offset-value/y)
	]
	insert tail y-scale-coords fpen-e
	insert tail y-scale-coords fpen-o
	viewport/y-trans-txt: reduce viewport/y-trans-txt-spec
]

update-vp-box: does [
	 vp-box: either this/viewport/x-center [
		this/get-viewport-xy
	][
		reduce [x-min-value y-max-value x-max-value y-min-value]
	]
]

update-grid: has [
	values tmp z ticks pen-e pen-o grid? n t b e
][
	update-vp-box
	
	graph/bl-padding: 1x0 + (viewport/vscale * convert* x-max-value y-max-value)
	graph/tr-padding: 0x1 + (viewport/vscale * convert* x-min-value y-min-value)

	if this/viewport/x-scale = 1 [
		graph/bl-padding: graph/bl-padding + 3x-3 + as-pair graph/point-size negate graph/point-size
		graph/tr-padding: graph/tr-padding + -3x3 + as-pair negate graph/point-size graph/point-size
	]

	n: 2 ** to-integer (log-2 this/viewport/x-scale)
	if n > 1 [n: to-integer n]

	graph/grid-pen2: graph/grid-pen
	graph/x-scale-pen: graph/x-scale-font/color + 0.0.0.0
	graph/y-scale-pen: graph/y-scale-font/color + 0.0.0.0
	graph/x-scale-pen/4: graph/y-scale-pen/4: graph/grid-pen2/4: 255 - (to-integer 255 / n * this/viewport/x-scale - 127)
	
	grid?: not graph/grid-pen/4 = 255
	
	if all [grid? any [graph/x-grid-values graph/y-grid-values]][
		insert tail clear grid-layer compose [
			scale viewport/vscale viewport/vscale
			translate viewport/x-trans viewport/y-trans
			translate viewport/x-center viewport/y-center
;			scale viewport/x-scale-grid viewport/y-scale-grid
			scale viewport/x-scale viewport/y-scale
;			translate viewport/x-center-neg-grid viewport/y-center-neg-grid
			translate viewport/x-center-neg viewport/y-center-neg
		
			line-width graph/line-widths/2
			clip (1x0 + (viewport/vscale * convert* x-max-value y-max-value)) (0x1 + (viewport/vscale * convert* x-min-value y-min-value))
		]
	]

	ticks: graph/y-grid-values
	if none? ticks [ticks: y-scale-ticks]
	if block? ticks [ticks: -1 + length? ticks]

;	values: compute-grid ticks * z y-min-value y-max-value

	e: vp-box/4
	b: vp-box/2
	t: (round/to t: y-max-value - y-min-value / ticks auto-precision 0 t 1.0) / n
	e: e - (e // t)
	b: b - (b // t)

	z: tmp: even? b / t

	values: compute-grid to-integer (e - b / t + .5) b e

	if all [grid? graph/y-grid-values] [
		pen-e: copy [pen graph/grid-pen]
		pen-o: copy [pen graph/grid-pen2]
		foreach value values [
			insert tail either tmp [pen-e][pen-o] compose [
;				line (convert*/mul vp-box/1 value viewport/grid-mul) (convert*/mul vp-box/3 value viewport/grid-mul)
				line (convert* vp-box/1 value) (convert* vp-box/3 value)
			]
			tmp: not tmp
		]
	]

	make-scale-y/ticks/even values z

	ticks: graph/x-grid-values
	if none? ticks [ticks: x-scale-ticks]
	if block? ticks [ticks: -1 + length? ticks]
	
;	values: compute-grid ticks * z x-min-value x-max-value

	b: vp-box/1
	e: vp-box/3

	t: (round/to t: x-max-value - x-min-value / ticks auto-precision 0 t 1.0) / n
	b: b - (b // t)
	e: e - (e // t)
	tmp: even? b / t

	values: compute-grid to-integer (e - b / t + .5) b e

	if all [grid? graph/x-grid-values] [	
		unless pen-e [
			pen-e: copy [pen graph/grid-pen]
			pen-o: copy [pen graph/grid-pen2]
		]
		z: tmp
		foreach value values [
			insert tail either tmp [pen-e][pen-o] compose [
;				line (convert*/mul value vp-box/2 viewport/grid-mul) (convert*/mul value vp-box/4 viewport/grid-mul)
				line (convert* value vp-box/2) (convert* value vp-box/4)
			]
			tmp: not tmp
		]
	]

	all [
		pen-e
		insert tail grid-layer pen-e
		insert tail grid-layer pen-o
	]
	
	make-scale-x/ticks/even values z

	graph/update-cross-hair
]

; the conversion function
convert*: func [x [number!] y [number!] /mul m [number!] /precise] build/with [
	m: any [m 1]
	either precise [
		reduce [cvtx cvty]
	][
		as-pair round cvtx round cvty
	]
][
	cvtx: either log-x [
		[(log-e x / x-min-value) * x-ratio + offset-value/x]
	][
		[x - graph/x-min-value * graph/x-ratio + graph/offset-value/x * m]
	]
	cvty: either log-y [
		[size-value/y - (y-ratio * log-e y / y-min-value) + offset-value/y]
	][
		[graph/size-value/y - (y - graph/y-min-value * graph/y-ratio) + graph/offset-value/y * m]
	]
]

this/goto-point: func [
	p [string! block! integer!]
	/direct
	/local pos dx dy lcx lcy s
][
	unless integer? p [
		p: find/skip/only skip graph/points-array 3 p 3
		if p [p: (index? p) - 1 / 3]
	]

	if p [
		
		pos: pick graph/points-array (p - 1) * 3 + 2
		dx:  viewport/x-center - pos/x * this/viewport/x-scale
		dy:  viewport/y-center - pos/y * this/viewport/y-scale

		dx: dx + ((size-value/x / 2  + offset-value/x) - viewport/x-center)
		dy: dy + ((size-value/y / 2  + offset-value/y) - viewport/y-center)

		if direct [
			pan-graph/abs-pos as-pair dx dy
			center-mouse-pos
			exit
		]
		dx: dx - viewport/x-trans * viewport/vscale
		dy: dy - viewport/y-trans * viewport/vscale

		s: max 2 to integer! (max abs dx abs dy) / (10 * viewport/x-scale)
		dx: dx / s
		dy: dy / s

		loop s [
			pan-graph as-pair dx dy
		]
		center-mouse-pos
	]
]

match-points: func [
	pos [block!]
	/single
	/hilite
	/local siz result p1 p2 cx cy closest rest fp i hp
][
	unless graph/points-array [return none]
	pos: as-pair pos/1 pos/2
	closest: none
	result: copy []
	rest: copy []
	hp: clear []
	siz: this/viewport/vscale-inv * this/viewport/x-scale-inv * first graph/points-array
	p1: pos - siz
	p2: pos + siz
	if hilite [
		clear hilited-points
	]
	i: 0
	foreach [p idx id] next graph/points-array [
		i: i + 1
		
		if any [none? graph/visible-points any [find graph/visible-points i find graph/visible-points id]][

;			pp: p * viewport/x-scale
;			print [p1 p2 pp]
			if all [
				p/x > p1/x
				p/y > p1/y
				p/x < p2/x
				p/y < p2/y
			][
				all [id id: first back idx]
				fp: any [fp p]
				p: as-pair p/x * viewport/vscale p/y * viewport/vscale
				either single [
					cx: abs p/x - pos/x
					cy: abs p/y - pos/y
					if any [
						not closest
						closest/1 > cx
						closest/2 > cy
					][
						closest: reduce [cx cy]
						result: reduce [p id idx]
					]
					insert tail rest reduce [p id idx]
				][
					if hilite [insert tail hp get-selection-shape point-shape p to integer! this/viewport/vscale-inv * 4]
					insert tail result reduce [p id idx]
				]
			]
		]
	]
	if all [hilite not empty? result][
		insert tail hp get-selection-shape point-shape fp to integer! this/viewport/vscale-inv * 4
		insert tail hilited-points compose [
			scale viewport/vscale viewport/vscale
			translate viewport/x-trans viewport/y-trans
			translate viewport/x-center viewport/y-center
			scale viewport/x-scale viewport/y-scale
			translate viewport/x-center-neg viewport/y-center-neg
			clip (1x0 + (viewport/vscale * convert* x-max-value y-max-value)) (0x1 + (viewport/vscale * convert* x-min-value y-min-value))
			pen (point-colors/1) fill-pen none
			(hp)
		]
	]
	if single [
		remove/part find/skip rest result 3 3
		result: compose/only [(result) (rest)]
	]
	result
]

update-zoom-slider: does [
	if graph/zoom-slider [
		graph/zoom-slider/data: 1 - (this/viewport/x-scale - 1 / (this/viewport/scale-max - 1))
		graph/zoom-slider/options: [no-update]
	]
]

update-trans: func [
	dposx [number!]
	dposy [number!]
	/abs-pos
	/local lx ly gsxb gsyb gsxe gsye
][
	if abs-pos [this/viewport/x-trans: this/viewport/y-trans: 0]

;	lx: size-value/x * this/viewport/x-scale - size-value/x
;	ly: size-value/y * this/viewport/y-scale - size-value/y

;	gsxb: this/viewport/x-center - offset-value/x * (this/viewport/x-scale - 1)
;	gsyb: this/viewport/y-center - offset-value/y * (this/viewport/y-scale - 1)
	
;	gsxe: gsxb - lx
;	gsye: gsyb - ly
	
	this/viewport/x-trans: 
;	max gsxe min gsxb
	this/viewport/x-trans + dposx
	this/viewport/y-trans: 
;	max gsye min gsyb
	this/viewport/y-trans + dposy

	update-anim-points
]

update-center: has [/with oft][
	oft: any [
		oft
		graph/mouse-oft
		as-pair
			this/viewport/x-center + this/viewport/x-trans
			this/viewport/y-center + this/viewport/y-trans
		]
;	this/viewport/x-center-neg-grid: this/viewport/grid-mul
;		* 
		this/viewport/x-center-neg: negate 
			this/viewport/x-center: oft/x - this/viewport/x-trans
;	this/viewport/y-center-neg-grid: this/viewport/grid-mul
;		* 
		this/viewport/y-center-neg: negate
			this/viewport/y-center: oft/y - this/viewport/y-trans
]

set-main-scale: func [
	val [number!]
	/scroll
	/abs-scale
][
	this/viewport/x-scale: this/viewport/y-scale: min
		this/viewport/scale-max
		max
			this/viewport/scale-min
			either abs-scale [val][this/viewport/x-scale + val]
;	this/viewport/x-scale-grid: this/viewport/x-scale / this/viewport/grid-mul
;	this/viewport/y-scale-grid: this/viewport/y-scale / this/viewport/grid-mul
	this/viewport/x-scale-inv: 1 / this/viewport/x-scale
	this/viewport/y-scale-inv: 1 / this/viewport/y-scale
	
	update-widths

	update-trans/abs-pos graph/trans-pos/x / this/viewport/x-scale - .5 graph/trans-pos/y / this/viewport/y-scale - .5

;	either scroll [
		update-center
;	][
;		update-center/with as-pair this/viewport/x-center + this/viewport/x-trans this/viewport/y-center + this/viewport/y-trans
;	]

	update-grid
]

update-widths: has [t][
	t: this/viewport/vscale-inv * lwidth
	line-widths/1: t * this/viewport/x-scale-inv
	line-widths/2: line-widths/1
	line-widths/3: t * min 1 this/viewport/x-scale-inv	
	if shadows? [
		forskip shadow-widths 2 [
			shadow-widths/2: shadow-widths/1 + max
				1
				this/viewport/vscale-inv * 4 * this/viewport/x-scale-inv
		]
	]
]

pan-graph: func [
	dpos [pair!]
	/force
	/abs-pos
][
	if any [force graph/pan?] [
		either abs-pos [
			update-trans/abs-pos dpos/x dpos/y
		][
			update-trans viewport/vscale-inv * dpos/x viewport/vscale-inv * dpos/y
		]
;		update-center

		update-grid

		this/regenerate-on-redraw: false
		show this
	]
]

this/set-point: func [
	p [integer! block! word!]
	visible [logic!]
	/no-show
	/local i
][
	unless graph [exit]
	either all [word? p p = 'all][
		either none? graph/visible-points [
			graph/visible-points: make hash! []
		][
			clear graph/visible-points
		]
		either visible [
			repeat n graph/point-count [
				insert tail graph/visible-points n
			]
		][
			clear head graph/selected-point-ids
			graph/update-selected-points
		]
	][
		unless block? p [p: reduce [p]]
		either visible [
			unless none? graph/visible-points [
				foreach point p [
					either integer? point [
						i: point
						point: pick graph/points-array i * 3 + 1
					][
						i: (index? find/only graph/points-array point) - 1 / 3
					]
					all [point remove any [find graph/visible-points point []]]
					remove any [find graph/visible-points i []]
					any [
						all [
							point
							insert tail graph/visible-points point
						]
						insert tail graph/visible-points i
					]
				]
			]
		][
			either none? graph/visible-points [
				graph/visible-points: make hash! []
				repeat n graph/point-count [
					either not find p n [
						insert tail graph/visible-points n
					][
						remove find head graph/selected-point-ids n
					]
				]
			][
				foreach point p [
					either integer? point [
						i: point
						point: pick graph/points-array i * 3 + 1
					][
						i: (index? find/only graph/points-array point) - 1 / 3
					]
					all [
						point
						remove any [find graph/visible-points point []]
;						remove any [find/only head graph/selected-point-ids point []]
					]
					remove any [find graph/visible-points i []]
					remove any [find head graph/selected-point-ids i []]
				]
			]
			graph/update-selected-points
		]
	]
	unless no-show [show this]
]

this/on-time: func [
	face [object!]
][
	f: this/graph/clip-face
	unless f/beg [f/beg: now/time/precise f/show?: true]
	either f/show-state: not f/show-state [show f/pane][hide f/pane]
	if now/time/precise > (f/beg + f/duration) [
		f/beg: none
		f/show?: false		
		f/points: none
		face/rate: none
		show face
	]
]

this/anim-point: func [
	p [string! integer! block! word!]
	dur [time!]
	anim-rate [integer!]
	/color
		col [tuple!]
	/local i cf
][
	unless block? p [p: reduce [p]]
	col: any [col red]
	unless cf: this/graph/clip-face [
		cf: this/pane/1: this/graph/clip-face: make face [
			edge: color: effect: feel: none
			offset: 0x0
			pane: copy []
			pcolor: points: size: show-state: duration: beg: none
			fx: compose/deep [draw [pen none fill-pen pcolor circle 4x4 4 4]]
		]
	]
	
	clear cf/pane
	cf/show-state: false
	cf/beg: none
	cf/duration: dur
	cf/size: graph-size
	cf/points: p
	cf/pcolor: col

	repeat n length? p [
		insert tail this/graph/clip-face/pane make face [
			feel: edge: color: none
			size: 8x8 
			effect: this/graph/clip-face/fx
		]
	]

	update-anim-points
	
	this/rate: anim-rate
	show this
]

update-anim-points: has [cf cp id f] [
	if all [cf: this/graph/clip-face cf/points][
		cp: cf/pane
		forall cp [
			id: pick cf/points index? cp
			id: either integer? id [
				id
			][
				(index? find/only this/graph/points-array id) - 1 / 3
			]
			f: cp/1
			f/offset: pick this/graph/points-array (id - 1) * 3 + 2
			f/offset/x: f/offset/x + viewport/x-center-neg * viewport/x-scale + viewport/x-center + viewport/x-trans * viewport/vscale - 4 
			f/offset/y: f/offset/y + viewport/y-center-neg * viewport/y-scale + viewport/y-center + viewport/y-trans * viewport/vscale - 4
		]
	]
]

this/select-point: func [
	p [string! integer! block! word!]
	state [logic! word!]
	/no-show
	/point-data-index ;this is not working ATM
	/local
		f bl show? flip? c i
][
	unless graph [exit]
	flip?: state = 'switch
	show?: false
	graph/selected-point-ids: head graph/selected-point-ids
	either all [word? p p = 'all][
		if flip? [
			state: empty? graph/selected-point-ids
		]
		clear graph/selected-point-ids
		if state [
			c: either none? graph/visible-points [
				(length? graph/points-array) - 1 / 3
			][
				graph/visible-points
			]
			repeat i c [
				insert tail graph/selected-point-ids i
			]
;			foreach p extract/index graph/points-array 3 2 [
;				insert tail graph/selected-point-ids p
;			]
		]
		show?: true
	][
		unless block? p [p: reduce [p]]
		foreach id p [
comment {
			unless integer? id [
				id: find/skip/only skip graph/points-array 3 id 3
				if id [id: (index? id) - 1 / 3]
			]
}
			either integer? id [
				i: id
				id: pick graph/points-array i * 3 + 1
			][
				i: (index? find/only graph/points-array id) - 1 / 3
			]
	
			
			if any [
					none? graph/visible-points
					all [id find graph/visible-points id]
					find graph/visible-points i
			][
				f: any [
;					all [id find/only graph/selected-point-ids id]
					find head graph/selected-point-ids i
				]
				either all [any [flip? state] not f][
					insert/only tail graph/selected-point-ids i ;any [id i]
					show?: true
				][
					if all [any [flip? not state] f][
						remove f graph/selected-point-ids
						show?: true
					]
				]
			]
		]
	]

	if show? [
		update-selected-points
		regenerate-on-redraw: false
		unless no-show [show this]
	]
]

update-selected-points: has [sp] [
	if graph/selected-points [
		sp: clear []
		clear graph/selected-points
		foreach p head graph/selected-point-ids [
			p: pick graph/points-array (p - 1) * 3 + 2
			insert tail sp get-selection-shape point-shape p to integer! this/viewport/vscale-inv * 4
		]
		
		unless empty? sp [
			insert graph/selected-points compose [
				scale viewport/vscale viewport/vscale		
				translate viewport/x-trans viewport/y-trans
				translate viewport/x-center viewport/y-center
				scale viewport/x-scale viewport/y-scale
				translate viewport/x-center-neg viewport/y-center-neg
				clip ((viewport/vscale * convert* x-max-value y-max-value) + 1x0) ((viewport/vscale * convert* x-min-value y-min-value) + 0x1)
				pen (point-colors/2) fill-pen (point-colors/2 + 0.0.0.164)
				(sp)
			]
		]
	]
]

center-mouse-pos: does [
	update-mouse-pos this/size / 2
]

update-mouse-pos: func [
	oft
][
	graph/mouse-oft: graph/screen-to-xy oft
	graph/mouse-oft: as-pair graph/mouse-oft/1 graph/mouse-oft/2
	graph/trans-pos: as-pair oft/x * this/viewport/vscale-inv - graph/mouse-oft/x oft/y * this/viewport/vscale-inv - graph/mouse-oft/y
]

update-cross-hair: has [p xy c goft][
	if all [
		graph/cross-hair?
		c: graph/cross-hair
	][
		update-vp-box
		p: convert* graph/vp-box/1 graph/vp-box/2
		c/27/y: p/y
		c/29/x: p/x
		p: convert* graph/vp-box/3 graph/vp-box/4
		c/26/y: p/y
		c/30/x: p/x
		
		if graph/last-mouse-pos [
			xy: graph/screen-to-xy graph/last-mouse-pos
			goft: as-pair xy/1 xy/2
			c/26/x: goft/x
			c/27/x: goft/x
			c/29/y: goft/y
			c/30/y: goft/y
		]
	]
]

this/on-mouse-away: func [
	oft
][
	if graph/cross-hair? [
		graph/last-mouse-pos: -1x-1
		update-cross-hair
		this/regenerate-on-redraw: false
		show this
	]
]

this/on-mouse-move: func [
	oft
	/local tmp show-it? goft xy
][
	if graph/empty-graph? [exit]

	graph/last-mouse-pos: oft

	if graph/cross-hair? [
		xy: graph/screen-to-xy oft
		goft: as-pair xy/1 xy/2
		graph/cross-hair/26/x: goft/x
		graph/cross-hair/27/x: goft/x
		graph/cross-hair/29/y: goft/y
		graph/cross-hair/30/y: goft/y
		show-it?: true
	]
	
	if all [
		graph/hilite-points?
		tmp: match-points/hilite/single any [xy graph/screen-to-xy oft]
	][
		tmp: first tmp
		if graph/last-hilite <> tmp [
			graph/last-hilite: tmp
			show-it?: true
		]
	]
	
	if show-it? [
		this/regenerate-on-redraw: false
		show this
	]
]

this/on-mouse-down: func [
	e
][
	if e/shift [update-mouse-pos e/offset]
]

this/on-mouse-drag: func [
	e dpos sc
][
	if graph/empty-graph? [exit]
	graph/last-mouse-pos: e/offset
	either all [graph/zoom? e/shift] [
		set-main-scale dpos/y / 100
		update-zoom-slider
		this/regenerate-on-redraw: false
		show this
		graph/zoom-action?: true
	][

		update-mouse-pos e/offset

		pan-graph dpos
		graph/pan-action?: true

	]
]

this/on-mouse-scroll: func [
	e
][
	if all [not graph/empty-graph? graph/zoom?] [
		either get in graph 'mouse-wheel-action [
			this/graph/mouse-wheel-action e
		][
			update-mouse-pos graph/last-mouse-pos
			set-main-scale negate (e/offset/y / (abs e/offset/y) / 3)
			update-zoom-slider
			this/regenerate-on-redraw: false
			show this
		]
		graph/zoom-action true
	]
]

this/on-mouse-up: func [
	e
	/local
		p oft
][
	if graph/empty-graph? [exit]

	oft: graph/screen-to-xy e/offset
	
	if all [
		p: match-points/single oft
		not empty? p/1
	][
		graph/point-action as-pair oft/1 oft/2 p/1 p/2
	]

	if graph/zoom-action? [
		graph/zoom-action?: false
		graph/zoom-action false
	]
	
	if graph/pan-action? [
		graph/pan-action?: false
		graph/pan-action
	]
]

; reverse conversions

screen-to-xy: func [point [pair!]] [
	reduce [
		(point/x * this/viewport/vscale-inv - this/viewport/x-trans - this/viewport/x-center / this/viewport/x-scale + this/viewport/x-center)
		(point/y * this/viewport/vscale-inv - this/viewport/y-trans - this/viewport/y-center / this/viewport/y-scale + this/viewport/y-center)
	]
]

screen-to-xy-precise: func [px [number!] py [number!]] [
	reduce [
		(px * this/viewport/vscale-inv - this/viewport/x-trans - this/viewport/x-center / this/viewport/x-scale + this/viewport/x-center)
		(py * this/viewport/vscale-inv - this/viewport/y-trans - this/viewport/y-center / this/viewport/y-scale + this/viewport/y-center)
	]
]


xy-to-graph: func [point [pair!] /local x y p r] [
	p: convert* vp-box/1 vp-box/2
	r: convert* vp-box/3 vp-box/4
	
	either any [
		point/x < p/1
		point/y > p/2
		point/x > r/1
		point/y < r/2
	][
		false
	][
		x: point/x - offset-value/x
		y: offset-value/y + size-value/y - point/y
		reduce [
			strip-zero this/trim-decimal/no-round (x / x-ratio) + x-min-value graph/dec-nums-x
			strip-zero this/trim-decimal/no-round (y / y-ratio) + y-min-value graph/dec-nums-y
		]
	]
]

point-shapes: reduce ['dot none 'cross none 'circle none 'triangle none 'square none 'diamond none]

get-point-shape: func [
	point-shape [word!]
	center-point [pair!]
	size [integer!]
	color [tuple!]
][
	return compose/deep switch point-shape [
		;'square | 'circle | 'diamond | 'cross | 'triangle
		dot [
			[
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
;						fill-pen radial 3x3 0 (size + 2) 0 1 1 128.128.128 128.128.128.64 164.164.164.128 192.192.192.255
						fill-pen 128.128.128.192
						
						pen none
;						circle 3x3 (size + 2) (size + 2)
						circle (2.5 * this/viewport/vscale-inv * 1x1) (size)
					]
				]
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
						pen none
						fill-pen (color)
						circle 0x0 (size) (size)
					]
				]
			]
		]
		cross [
			[
				[]
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
						line-width 1
						line (as-pair negate size 0)
							(as-pair size 0)
						line (as-pair 0 negate size)
							(as-pair 0 size)
					]
				]
			]
		]
		circle [
			[
				[]
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
						line-width 1
						circle 0x0 (size) (size)
					]
				]
			]
		]
		triangle [
			[
				[]
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
						line-width 1
						triangle
							(as-pair 0 negate size)
							(0x0 + size)
							(as-pair negate size 0 + size)
					]
				]
			]
		]
		square [
			[
				[]
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
						line-width 1
						box
							(0x0 - size)
							(0x0 + size)
					]
				]
			]
		]
		diamond [
			[
				[]
				[
					push [
						translate (center-point/x) (center-point/y)
						scale this/viewport/x-scale-inv this/viewport/y-scale-inv
						line-width 1
						polygon
							(as-pair 0 negate size)
							(as-pair size 0)
							(as-pair 0 size)
							(as-pair negate size 0)
					]
				]
			]
		]
	]
]

get-selection-shape: func [
	point-shape [word!]
	center-point [pair!]
	size [integer!]
][
	return compose/deep switch point-shape [
		;'square | 'circle | 'diamond | 'cross | 'triangle
		dot [
			[
				push [
					translate (center-point/x) (center-point/y)
					scale this/viewport/x-scale-inv this/viewport/y-scale-inv
					line-width (this/viewport/vscale-inv * 2)
					circle 0x0 (size) (size)
				]
			]
		]
		cross [
			[
				push [
					translate (center-point/x) (center-point/y)
					scale this/viewport/x-scale-inv this/viewport/y-scale-inv
					line-width (this/viewport/vscale-inv * 2)
					line (as-pair negate size 0)
						(as-pair size 0)
					line (as-pair 0 negate size)
						(as-pair 0 size)
				]
			]
		]
		circle [
			[
				push [
					translate (center-point/x) (center-point/y)
					scale this/viewport/x-scale-inv this/viewport/y-scale-inv
					line-width (this/viewport/vscale-inv * 2)
					circle 0x0 (size) (size)
				]
			]
		]
		triangle [
			[
				push [
					translate (center-point/x) (center-point/y)
					scale this/viewport/x-scale-inv this/viewport/y-scale-inv
					line-width (this/viewport/vscale-inv * 2)
					triangle
						(as-pair 0 negate size)
						(0x0 + size)
						(as-pair negate size 0 + size)
				]
			]
		]
		square [
			[
				push [
					translate (center-point/x) (center-point/y)
					scale this/viewport/x-scale-inv this/viewport/y-scale-inv
					line-width (this/viewport/vscale-inv * 2)
					box
						(0x0 - size)
						(0x0 + size)
				]
			]
		]
		diamond [
			[
				push [
					translate (center-point/x) (center-point/y)
					scale this/viewport/x-scale-inv this/viewport/y-scale-inv
					line-width (this/viewport/vscale-inv * 2)
					polygon
						(as-pair 0 negate size)
						(as-pair size 0)
						(as-pair 0 size)
						(as-pair negate size 0)
				]
			]
		]
	]
]


;--------------init code starts here

;do some cleanup in case of refresh
;x-scale-ticks: y-scale-ticks:
x-grid-values: y-grid-values:
x-data-min-value: x-data-min-value:
x-data-max-value: y-data-max-value: none
x-min-value: viewport/x-min-value
x-max-value: viewport/x-max-value
y-min-value: viewport/y-min-value
y-max-value: viewport/y-max-value

point-shape: any [point-shape 'dot]

offset-value: 0x0
data-length: 0

; set the default font, pen and fill-pen
layer1: reduce [
;	'font default-font
	'pen none
	'fill-pen default-pen
]

shadows-layer: copy []

grad-img: make image! 1x100
grad-img/rgb: 255.255.255.255
;draw grad-img [pen none fill-pen linear 0x0 0 255 90 1 1 128.128.128 128.128.128.64 164.164.164.128 192.192.192.255 box 0x0 1x100]
draw grad-img [pen none fill-pen linear 0x0 0 255 90 1 1 0.0.0.64 0.0.0.128 0.0.0.255 box 0x0 1x100]

legend-colors: make block! 0
legend-pen: none

description: copy skip description 2 ;remove [graph spider]..

;quadratic size needs to be checked for first
use [pos min-size][
	if found? pos: find description 'quadratic-ratio [
		min-size: min graph-size/x graph-size/y
		graph-size/x: graph-size/y: min-size
		remove pos
	]
]
size-value: graph-size

graph-controls: [
	at 6x0
	zoom-slider: slider 5x30 data 1 edge [size: 1x1 color: 77.97.133][
		either find face/options 'no-update [
			face/options: copy []
		][
			if zoom? [
				set-main-scale/abs-scale (1 - face/data) * (this/viewport/scale-max - 1) + 1
				this/regenerate-on-redraw: false
				show this
			]
		]
	][
		graph/zoom-action false
	]
	at 6x32
	arrow data 'up [
		center-mouse-pos
		pan-graph 0x20
		graph/pan-action
	]
	at 0x38
	arrow data 'left [
		center-mouse-pos
		pan-graph 20x0
		graph/pan-action
	]
	at 12x38
	arrow data 'right [
		center-mouse-pos
		pan-graph -20x0
		graph/pan-action
	]
	at 6x44
	arrow data 'down [
		center-mouse-pos
		pan-graph 0x-20
		graph/pan-action
	]
	do [
		insert zoom-slider/effect [merge alphamul 127]
		zoom-slider/color: 236.233.216
	]
]

tool-tip-handler: [
	"" [
		use [p result xy][
			result: false
			if function? get in graph 'tool-tip-action [
				xy: graph/screen-to-xy event/offset - win-offset? face
				if p: match-points/single xy [
					set/any 'result graph/tool-tip-action p/1 p/2
					if unset? get/any 'result [result: false]
				]
			]
			if graph/tool-tip-coords [
				result: any [result all [
					xy: graph/screen-to-xy event/offset - win-offset? face
					result: graph/xy-to-graph as-pair xy/1 xy/2
					form result
					]
				]
			]
			face/tool-tip/1: result
		]
	]
]

; collect data
description: build/with description  [
	; all functions return a block,
	; that will be inserted into the second pass block
	plot: func [
		{limits the plot to a part of the whole drawing}
		offset [pair!]
		size [pair!]
	][
		offset-value: offset
		size-value: size
		[]
	]

	graph-pan: func [
	][
		pan?: true
		[]
	]

	shadows: func [
	][
		[]
	]
	
	point-shape: func [
		'shape [word!]
	][
		[]
	]

	cross-hair-color: func [
		color [word! tuple!]
	][
		[]
	]
	
	graph-controls: cross-hair: hilite-points: func [
	][
		[]
	]
	
	graph-max-zoom: func [
		max-scale [number!]
	][
		[]
	]

	graph-zoom: func [
	][
		zoom?: true
		[]
	]

	pen: func [
		{set the current pen}
		color [tuple!]
	][
		current-pen: color
		reduce ['pen color]
	]
	point-action: func [
		action [block!]
	][
		this/graph/point-action: func [mouse-pos [pair!] matched-point [block!] adjacent-points [block!]] action
		[]
	]

	pan-action: func [
		action [block!]
	][
		this/graph/pan-action: func [] action
		[]
	]

	zoom-action: func [
		action [block!]
	][
		this/graph/zoom-action: func [scroll-wheel [logic!]] action
		[]
	]

	mouse-wheel-action: func [
		action [block!]
	][
		this/graph/mouse-wheel-action: func [event [event!]] action
		[]
	]
	
	point-over-color: func [
		color [word! tuple!]
	][
		if word? color [color: get color]
		point-colors/1: color
		[]
	]

	point-select-color: func [
		color [word! tuple!]
	][
		if word? color [color: get color]
		point-colors/2: color
		[]
	]
	
	fill-pen: func [
		{set the current fill-pen}
		color [tuple! none!]
	][
		current-fill-pen: color
		reduce ['fill-pen color]
	]
	transparency: func [
		"set transparency"
		value [integer!]
	][
		alpha: value
		[]
	]
	legend: func [
		{draws the legend}
		offset [pair!]
		names [block!]
	][
		legend-pen: current-pen
		reduce [
			'legend offset names
			'fill-pen current-fill-pen
		]
	]
	back-color: func [
		"set the current fill-pen"
		color [tuple! none!]
	][
		back-color: color
		[]
	]
	
	x-label: func [
		text [string!]
	][
		[]
	]

	y-label: func [
		text [string!]
	][
		[]
	]

	y-label-horiz: func [
		text [string!]
	][
		[]
	]
	
	graph: func [
		'type [word!]
	][
		[]
	]
	
	x-color: func [
		{draw a column}
		start [number!]
		end [number!]
		color [tuple! none!]
		/local var
	][
		; color none means "transparent"
		unless color [color: 0.0.0.255]

		; make sure start is minimum and end is maximum
		var: max start end
		start: min start end
		end: var

		either x-min-value [
			x-min-value: min x-min-value start
			x-max-value: max x-max-value end
		][
			x-min-value: start
			x-max-value: end
		]
		reduce [
			'x-color start end color
			'pen current-pen
			'fill-pen current-fill-pen
		]
	]

	x-precision: func [
		{set the x-precision value}
		x-precision [number!]
	][
		x-precision-value: x-precision
		[]
	]

	y-precision: func [
		{set the y-precision value}
		y-precision [number!]
	][
		y-precision-value: y-precision
		[]
	]

	font: func [
		{set the current font}
		fnt [object!]
	][
		current-font: fnt
		reduce ['font fnt]
	]

	x-min: func [
		{set the x-min-value}
		value [number!]
	][
		x-min-value: value
		[]
	]

	x-max: func [
		{set the x-max-value}
		value [number!]
	][
		x-max-value: value
		[]
	]

	y-min: func [
		{set the y-min-value}
		value [number!]
	][
		y-min-value: value
		[]
	]

	y-max: func [
		{set the y-max-value}
		value [number!]
	][
		y-max-value: value
		[]
	]

	x-scale: func [ticks [integer! block!]][
		init-x-scale-font
		x-scale-ticks: ticks
		log-x: false
		[]
	]

	log-x-scale: func [ticks [integer! block!]][
		init-x-scale-font
		x-scale-ticks: ticks
		log-x: true
		[]
	]

	y-scale: func [ticks [integer! block!]][
		init-y-scale-font
		y-scale-ticks: ticks
		log-y: false
		[]
	]

	log-y-scale: func [ticks [integer! block!]][
		init-y-scale-font
		y-scale-ticks: ticks
		log-y: true
		[]
	]
	scale: func [ticks [pair!]][
		init-x-scale-font
		x-scale-ticks: ticks/x
		init-y-scale-font
		y-scale-ticks: ticks/y
		log-x: false
		[]
	]


	data: func [
		data-block [block!]
		/local out id idx x-value y-value type size color data col i
	][
		this/graph/point-size: 0
		this/graph/empty-graph?: false
		out: make block! 0
		point-count: 0
		clear shadow-widths
		parse data-block [
			some [
				set type word! set size number! set color [word! | tuple!] set data [block! | word!] (
				if word? data [data: get data]
				if all [block? data not empty? data][
					if word? color [color: get color]
					append legend-colors current-pen
					parse data [
						some [
							set id opt [string! | block!]
							idx:
							set x-value number!
							set y-value number!
							(
								data-length: data-length + 1
								x-data-min-value: any [
									all [
										x-data-min-value
										min x-data-min-value x-value
									]
									x-value
								]
								x-data-max-value: any [
									all [
										x-data-max-value
										max x-data-max-value x-value
									]
									x-value
								]
								y-data-min-value: any [
									all [
										y-data-min-value
										min y-data-min-value y-value
									]
									y-value
								]
								y-data-max-value: any [
									all [
										y-data-max-value
										max y-data-max-value y-value
									]
									y-value
								]
							)
							| skip
						]
					]
					switch type [
						line [
							all [
								color/4 <> 255
								append out compose/deep/only [
									line-width (size)
									pen (color)
									data (data)
								]
							]
						]
						point [
							all [
								color/4 <> 255
								this/graph/point-size: max
									this/graph/point-size
									size
								append out compose/deep/only [
									pen (color) fill-pen none
									point (size) (data) (color)
								]
							]
						]
					]
				]
				)
				| 'visible-points set data block! (
					if none? visible-points [
						visible-points: make hash! data
						repeat n length? visible-points [
							if block? data: visible-points/:n [
								poke visible-points n to issue! checksum mold data
							]
						]
					]
				)
				| 'points-colors set data block! (
					points-colors: reduce [make hash! 100 make block! 100]
					parse/all reduce data [
						some [
							set i integer! set col tuple! (
								insert tail points-colors/1 i
								insert tail points-colors/2 col
							)
							| set i integer! set col block! (
								foreach c reduce col [
									insert tail points-colors/1 i
									insert tail points-colors/2 c
									i: i + 1
								]
							)
							| set col [tuple! | none!] set i block! (
								foreach idx i [
									insert tail points-colors/1 idx
									insert tail points-colors/2 col
								]
							)
						]
					]
				)
			]
		]
		if empty? out [
			this/graph/empty-graph?: true
		]
		out
	]

	point: func [size [integer!] data [block!]][
		all [
			none? x-data-max-value
			pick data 1
			pick data 2
			x-data-min-value:
			x-data-max-value: first data
			y-data-min-value:
			y-data-max-value: second data
		]
		
		foreach [x-value y-value] data [
			x-data-min-value: min x-data-min-value x-value
			x-data-max-value: max x-data-max-value x-value
			y-data-min-value: min y-data-min-value y-value
			y-data-max-value: max y-data-max-value y-value
		]
		reduce ['point size data]
	]
	font-size: func [
		{set font size}
		size [integer!]
	][
		current-font/size: size
		[]
	]

	grid-color: func [
		pen [word! tuple!]
	][
		grid-pen: pen + 0.0.0.0
		reduce [
			'x-grid none
			'y-grid none
		]
	]
	
	grid: func [
		{set the grid}
		grid [pair!]
		pen [word! tuple!]
	][
		init-x-scale-font
		init-y-scale-font
		x-scale-ticks: grid/x
		y-scale-ticks: grid/y
		grid-pen: pen + 0.0.0.0
		reduce [
			'x-grid grid/x
			'y-grid grid/y
		]
	]

	limit: func [
		{set the grid limit}
		xlimit [pair!]
		ylimit [pair!]
	][
		if not equal? xlimit -1x-1 [
			x-min-value: xlimit/1
			x-max-value: xlimit/2
		]
		if not equal? ylimit -1x-1 [
			y-min-value: ylimit/1
			y-max-value: ylimit/2
		]
		[]
	]

	color-ranges: func [
		ranges
		/local out var
	][
		out: make block! []
		foreach [start end color] ranges [

			; color none means "transparent"

			unless color [color: 0.0.0.255]

			; make sure start is minimum and end is maximum
			var: max start end
			start: min start end
			end: var

			either x-min-value [
				x-min-value: min x-min-value start
				x-max-value: max x-max-value end
			][
				x-min-value: start
				x-max-value: end
			]
			repend out [
				'x-color start end color
				'pen current-pen
				'fill-pen current-fill-pen
			]
		]
		out
	]
	
	tool-tip-delay: func [delay [time!]][
		this/tool-tip-delay: delay
		[]
	]
	
	tool-tip-action: func [
		action [block!]
	][
		unless this/tool-tip [this/tool-tip: tool-tip-handler]
		this/graph/tool-tip-action: func [
			matched-point [block!]
			adjacent-points [block!]
		] action
		[]
	]

	tool-tip-coords: func [
	][
		unless this/tool-tip [this/tool-tip: tool-tip-handler]
		this/graph/tool-tip-coords: true
		[]
	]
]

if empty-graph? [return none]

; process data
; compute x-data-min-value, etc.
x-data-min-value: any [
	x-data-min-value
	x-min-value
	all [log-x 1.0]
	0.0
]
x-data-max-value: any [
	x-data-max-value
	x-max-value
	all [log-x 10.0]
	1.0
]
y-data-min-value: any [
	y-data-min-value
	y-min-value
	all [log-y 1.0]
	0.0
]
y-data-max-value: any [
	y-data-max-value
	y-max-value
	all [log-y 10.0]
	1.0
]

; compute x-min-value etc.
;unless x-min-value [
	x-min-value: min
		x-data-min-value
		any [this/viewport/x-min-value x-data-min-value]
;]
;unless x-max-value [
	x-max-value: max
		x-data-max-value
		any [this/viewport/x-max-value x-data-max-value]
;]
;unless y-min-value [
	y-min-value: min
		y-data-min-value
		any [this/viewport/y-min-value y-data-min-value]
;]
;unless y-max-value [
	y-max-value: max
		y-data-max-value
		any [this/viewport/y-max-value y-data-max-value]
;]

; take care of spread
if x-min-value = x-max-value [
	either log-x [
		x-min-value: x-min-value / 10.0
		x-max-value: x-max-value * 10.0
	][
		x-min-value: x-min-value - 1
		x-max-value: x-max-value + 1
	]
]
if y-min-value = y-max-value [
	either log-y [
		y-min-value: y-min-value / 10.0
		y-max-value: y-max-value * 10.0
	][
		y-min-value: y-min-value - 1
		y-max-value: y-max-value + 1
	]
]

; round
unless x-precision-value [
	; limit the "slack space" to 15%
	x-precision-value: auto-precision x-min-value x-max-value 0.15
]
unless y-precision-value [
	; limit the "slack space" to 15%
	y-precision-value: auto-precision y-min-value y-max-value 0.15
]
; ATT! may be problematic for log-scale (if rounded to zero)
this/viewport/x-min-value: x-min-value: to-decimal any [
	this/viewport/x-min-value round/floor/to x-min-value x-precision-value
]
this/viewport/x-max-value: x-max-value: to-decimal any [
	this/viewport/x-max-value round/ceiling/to x-max-value x-precision-value
]
this/viewport/y-min-value: y-min-value: to-decimal any [
	this/viewport/y-min-value round/floor/to y-min-value y-precision-value
]
this/viewport/y-max-value: y-max-value: to-decimal any [
	this/viewport/y-max-value round/ceiling/to y-max-value y-precision-value
]

init-x-scale-font
init-y-scale-font

if all [integer? x-scale-ticks x-scale-ticks < 1][
	size-text-face/font: x-scale-font
	size-text-face/text: form x-max-value
	f: size-text size-text-face
	x-scale-ticks: max 1 to integer! min 
		(graph-size/x / (f/x + 6) - 1)
		(data-length - 1)
]

;check font size
if integer? x-scale-ticks [
	l-size: graph-size/x / x-scale-ticks * viewport/vscale
	size-text-face/font: x-scale-font
	size-text-face/text: form x-max-value
	f: size-text size-text-face
	alternate-labels: false
	if l-size < (5 * length? size-text-face/text)[
		l-size: 5 * length? size-text-face/text
		alternate-labels: true
	]
	while [l-size < (f/x + 4)][
		x-scale-font/size: x-scale-font/size - 1
		if x-scale-font/size < 2 [break]
		f: size-text size-text-face
	]
	y-scale-font/size: x-scale-font/size: x-scale-font/size * viewport/vscale-inv
]

if all [integer? y-scale-ticks y-scale-ticks < 1][
	y-scale-ticks:
		to integer! max 1 min
		(graph-size/y / (y-scale-font/size + 10) - 1)
		(data-length - 1)
]

x-scale-ticks: compute-scale
	x-scale-ticks 'x-min-value 'x-max-value; log-x x-precision-value
y-scale-ticks: compute-scale
	y-scale-ticks 'y-min-value 'y-max-value; log-y y-precision-value

; compute space around the plot
size-text-face: make system/words/face [size: 1000000x1000000]
size-text-face/font: x-scale-font
f: form x-min-value
size-text-face/text: f
f: size-text size-text-face
below-plot: x-scale-font/size * (
	either alternate-labels [2][1]
) + f/y + 6 ;BB - some space (about 6px) needs to be added otherwise the text is truncated
lh-plot: round/ceiling f/x / 2

f: form x-max-value
size-text-face/text: f
f: size-text size-text-face
below-plot: max below-plot x-scale-font/size * 2 + f/y
rh-plot: (round/ceiling f/x / 2) + 10 ;BB - some space needs to be added to prevent truncation

size-text-face/font: y-scale-font
f: form y-min-value
size-text-face/text: y-min-value
f: size-text size-text-face
below-plot: max below-plot round/ceiling f/y / 2

foreach y-coordinate y-scale-ticks [
	y-coordinate: form y-coordinate
	size-text-face/text: y-coordinate
	f: size-text size-text-face
	lh-plot: max lh-plot y-scale-font/size + f/x
]

f: form y-max-value
size-text-face/text: y-max-value
f: size-text size-text-face
above-plot: round/ceiling f/y / 2

; size adjustments

;print ["L:" lh-plot "R:" rh-plot]
;print ["Be:" below-plot "Ab:" above-plot]
if any [
	lh-plot + rh-plot >= size-value/x
	below-plot + above-plot >= size-value/y
][
	throw make error! "plot size too small"
]
offset-value/x: offset-value/x + lh-plot
offset-value/y: offset-value/y + above-plot
size-value/x: size-value/x - lh-plot - rh-plot
size-value/y: size-value/y - below-plot - above-plot

x-spread-value: either log-x [log-e x-max-value / x-min-value][
	x-max-value - x-min-value
]

y-spread-value: either log-y [log-e y-max-value / y-min-value][
	y-max-value - y-min-value
]


x-ratio: size-value/x / x-spread-value
y-ratio: size-value/y / y-spread-value

comment [
build/with build/with [
	reduce [
		round/to cvtx x-precision-value'
		round/to cvty y-precision-value'
	]
][
	cvtx: either log-x [
		[(exp point/x - (first offset-value') / x-ratio') * x-min-value']
	][
		[add point/x - (first offset-value') / x-ratio' x-min-value']
	]
	cvty: either log-y [
		[(exp (second offset-value') + (second size-value') - point/y / y-ratio') * y-min-value']
	][
		[add (second offset-value') + (second size-value') - point/y / y-ratio' y-min-value']
	]
][
	x-precision-value': x-precision-value
	y-precision-value': y-precision-value
	offset-value': offset-value
	x-ratio': x-ratio
	x-min-value': x-min-value
	y-ratio': y-ratio
	y-min-value': y-min-value
	size-value': size-value
]
]

description: build/with description [
	legend: lfunc [
		offset [pair!]
		names [block!]
	][][
		drawing: make block! 0

		; compute text size
		legend-text-size: 0x0
		foreach name names [
			size-text-face/text: name
			legend-text-size: max legend-text-size size-text size-text-face
		]

		repeat i min length? names length? legend-colors [
			append drawing compose [
				pen (legend-colors/:i)
				fill-pen (legend-colors/:i)
				box
					(offset)
					(1x1 * legend-text-size/y + offset)
				pen (legend-pen)
				text vectorial (names/:i) (1.5 * legend-text-size/y * 1x0 + offset)
			]
			offset: 1.5 * legend-text-size/y * 0x1 + offset
		]

		drawing
	]

	x-color: lfunc [
		start [number!]
		end [number!]
		color [tuple!]
	][][
		compose [
			pen (color)
			fill-pen (color)
			box (convert* start y-max-value) (convert* end y-min-value)
		]
	]

	x-grid: lfunc [values [number! block! none!]][][
		graph/x-grid-values: values
		[]
	]

	y-grid: lfunc [values [integer! block! none!]][][
		graph/y-grid-values: values
		[]
	]

	x-axis: lfunc [][][
		start-point: as-pair offset-value/x size-value/y + offset-value/y
		end-point: as-pair size-value/x + offset-value/x start-point/y
		reduce ['line start-point end-point]
	]

	y-axis: lfunc [][][
		start-point: as-pair offset-value/x size-value/y + offset-value/y
		end-point: as-pair start-point/x offset-value/y
		reduce ['line start-point end-point]
	]

	data: lfunc [data [block!]][][
		tmp: tmp2: ln: none
		clip: reduce ['clip 1x0 + (viewport/vscale * convert* x-max-value y-max-value) 0x1 + (viewport/vscale * convert* x-min-value y-min-value)]
		chart: make block! round/ceiling (length? data) / 2 + 1
		append chart clip
		append chart [line-width line-widths/1 line]
		foreach [x y] data [
			append chart convert* x y
		]
		data: skip data 2
		append shadows-layer clip
		forskip data 2 [
			tmp: convert* first back back data first back data
			tmp2: convert* data/1 data/2
			insert tail shadow-widths reduce [
				tmp2
				tmp2 + max 1 (this/viewport/vscale-inv * 4 * this/viewport/x-scale-inv)
				tmp
				tmp + max 1 (this/viewport/vscale-inv * 4 * this/viewport/x-scale-inv)
			]
			ln: length? shadow-widths
;			insert tail shadows-layer compose [image grad-img (tmp) (tmp2) (tmp2 + 4) (tmp + 4)]
			insert tail shadows-layer compose [
				image
				grad-img
				(tmp)
				(tmp2)
				(to-path reduce ['shadow-widths ln - 2])
				(to-path reduce ['shadow-widths ln])
			]
		]
		chart
	]

	point: func [
		size [integer!]
		data [block!]
		color [tuple!]
		/local id idx x y chart center-point tmp c clip
	][
		clip: compose [clip graph/bl-padding graph/tr-padding]
		all-points: chart: make block! 3 * length? data
		append chart clip
		append chart [line-width line-widths/1]
		center-point: none
		graph/points-array: reduce [size]
		append shadows-layer clip
		parse data [
			some [
				set id opt [string! | block!] idx: set x number! set y number! (
					point-count: point-count + 1

					center-point: convert* x y
					insert tail graph/points-array reduce [
						center-point idx either block? id [id: to issue! checksum mold id][id]
					]

					if any [
						none? visible-points
						find visible-points point-count
						find visible-points id
					][
						tmp: get-point-shape point-shape center-point to integer! this/viewport/vscale-inv * size any [
							all [points-colors c: find points-colors/1 point-count pick points-colors/2 index? c]
							color
						]
;						insert tail shadows-layer tmp/1
						insert tail chart reduce [x y tmp/1 tmp/2]
					]
				)
				| skip
			]
		]
		chart
		[]
	]

	convert: :convert*
	]
{
use [tmp][
	parse graph/visible-points [
		some [
			p: string! | block! (
				if tmp: find/only graph/points-array p/1 [
					change at graph/visible-points index? p/1 (index? tmp) - 1 / 3
				]
			)
		]
	]
]
}

layer1: head insert tail reduce [
	'clip 1x0 + (this/viewport/vscale * convert* x-max-value y-max-value) 0x1 + (this/viewport/vscale * convert* x-min-value y-min-value)
] layer1

update-widths
update-grid

if shadows? [append layer1 shadows-layer]

append layer1 description 

labels-layer: copy []
if all [not y-label-horiz y-label][
	use [tmp oft ts][
		size-text-face/font: axis-label-font
		size-text-face/text: "M"
		tmp: size-text size-text-face
		f: 4x2 + as-pair offset-value/x * this/viewport/vscale offset-value/y * this/viewport/vscale
		foreach c y-label [
			size-text-face/text: c: to-string c
			ts: size-text size-text-face
			oft: as-pair tmp/x - ts/x * .5 + f/x f/y
			append labels-layer compose [
				pen 200.200.200
				font (axis-label-font)
				text anti-aliased (oft) (c)
				pen black
				text anti-aliased (oft - 2) (c)
			]
			f/y: f/y + ts/2 - either c = " " [ts/2 * .5][ts/2 * .2]
		]
	]
]
foreach w [x-label y-label-horiz][
;if f: any [x-label y-label-horiz] [
if f: get w [
	size-text-face/font: axis-label-font
	size-text-face/text: f
	f: either f = x-label [
		(as-pair offset-value/x + size-value/x * this/viewport/vscale offset-value/y + size-value/y * this/viewport/vscale)	- size-text size-text-face
	][
		4x2 + as-pair offset-value/x * this/viewport/vscale offset-value/y * this/viewport/vscale
	]
	append labels-layer compose [
		pen 200.200.200.127
		font (axis-label-font)
		text anti-aliased (f) (size-text-face/text)
		pen black
		text anti-aliased (f - 2) (size-text-face/text)
	]
]
]
layer1