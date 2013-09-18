REBOL[
	Title: "Graph: spider"
]

size-data: 640x480
description: build/with description [
	; all functions return a block,
	; that will be inserted into the second pass block
	plot: func [
		{limits the plot to a part of the whole drawing}
		offset [pair!]
		size [pair!]
	][
		offset-data: offset
		size-data: size
		[]
	]

	auto-scaling: func [
		{sets up the auto-scaling}
	][
		auto-scaling?: true
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

	precision: func [
		{set up the precision factor}
		factor [number!]
	][
		precision-data: factor
		[]
	]

	pen: func [
		{set the current pen}
		color [tuple!]
	][
		current-pen: color
		reduce ['pen color]
	]

	font: func [
		{set the current font}
		fnt [object!]
	][
		current-font: fnt
		reduce ['font fnt]
	]

	font-size: func [
		{set the current font size}
		size [integer!]
	][
;		current-font: fnt
;		reduce ['font fnt]
		[]
	]

	grid-color: func [
		{set the current pen}
		color [tuple! word!]
	][
		grid-pen: color
	;	current-pen: color
		reduce ['pen color]
	]

	back-color: func [
		{set the current fill-pen}
		color [tuple! none!]
	][
;		current-fill-pen: color
;		reduce ['pen none 'fill-pen color 'box 0x0 size-data / 2 'fill-pen none ]
		back-color: color
		[]
	]

	scale: func [
		{set the scale}
		scale [block! integer!]
	][
		scale-data: scale
		if block? scale [data-max: max data-max first maximum-of scale]
		scale-font: graph/font ;current-font
		'scale
	]

	grid: func [
		{set the grid}
		grid [pair!]
	][
		;BB:scale functionality
		scale-data: grid/x
		reduce [
			'grid grid
			'scale grid/x
		]
	]
	
	circle: func[][[]]

	graph-transparency: func [
		{set transparency}
		value [integer!]
	][
		graph/fill-alpha: value
		[]
	]
	transparency: func [
		"set transparency"
		value [integer!]
	][
		alpha: value
		[]
	]

	data: func [
		{draw the the data series}
		data [block!]
		/local position result legend-text-size offset idx
	][
		offset: 0x0
		idx: 0
		result: make block! 0
		legend-text-size: 0x0
		;compute text size
		size-text-face/font: graph/font
		foreach [l c v] data [
			size-text-face/text: l
			legend-text-size: max legend-text-size size-text size-text-face
		]
		foreach [label color values] data [
			color: 0.0.0.0 + any [all [word? color get color] color] ;translate color from word to tuple!
			idx: idx + 2
			append result compose [
				pen (color)
				fill-pen (color)
				box
				(as-pair 460 idx * 20 + 10)
				(as-pair 480 idx * 20 + 30)
				pen none
				fill-pen (legend-pen)
				text vectorial
				(label)
				(as-pair 490 idx * 20 + 10)
				fill-pen (
					either zero? graph/fill-alpha [
						none
					][
						color/4: graph/fill-alpha
						color
					]
				)
			]
			offset: 1.5 * legend-text-size/y * 0x1 + offset

			;nezpracovava LABEL zatim
			color/4: 0 ; remove alpha for the edge
			append legend-colors color
			repend result ['pen color]
			parse values [any [position: none! (change position 0) | skip]]
			insert/only tail data-data values
			repend result ['data values]
		]
		result

;		append legend-colors current-pen
;		parse data [any [position: none! (change position 0) | skip]] ;meni NONE na 0 (nevim proc... :)
;		insert/only tail data-data data
;		reduce ['data data]
	]
	categories: func [
		{describe categories}
		cat [block!]
	][
		categories-data: cat
		category-font: current-font
		'categories
	]

	title: func [
		{sets up the title}
	][
		[]
	]

]

; compute the data count
data-count: any [
	all [categories-data length? categories-data]
	all [not empty? data-data length? data-data/1]
	0
]

; check data count consistence
foreach series data-data [
	if data-count <> length? series [
		throw make error! "Data series inconsistence"
	]
]

; auxiliary variables
f: none
angle: none
direction: none
position-x: none
position-y: none

; auto-scaling
either all [
	auto-scaling?
	not empty? data-data
][
	; compute scales for directions
	scales: head insert/dup copy [] 0.0 data-count
	foreach data data-data [
		repeat i data-count [poke scales i max scales/:i data/:i]
	]

	; adjust data-max to nonzero
	data-max: max data-max scales/1
	if zero? data-max [
		data-max: first maximum-of scales
		if zero? data-max [data-max: 100]
	]

	; adjust scales to nonzero
	;???
	;original commented line
	;repeat i data-count [if zero? scales/:i poke scales i data-max]
	repeat i data-count [if zero? scales/:i [poke scales i data-max]]
	scales
][
	; adjust data-max
	foreach data data-data [
		data-max: max data-max first maximum-of data
	]
	if zero? data-max [data-max: 100]

	; set the scales to be equal
	scales: head insert/dup copy [] data-max data-count
]

; set the default font, pen and fill-pen
layer1: reduce [
;	'font default-font
;	'pen 0.0.0 ;default-pen
;	'fill-pen none
	'pen none 'fill-pen graph/back-color 'box 0x0 size-data / 2 'fill-pen none
]

; compute the chart centre
chart-centre: as-pair
round size-data/x / 2 + offset-data/x
round size-data/y / 2 + offset-data/y
spider-radius: round/floor min size-data/x / 3 size-data/y / 3
;BB:by changing factor from 2 to 3, graphs are smaller so there's space for legend

; default category space is zero
category-horiz: 0
category-vert: 0

; initialize direction block
direction-block: make block! data-count
repeat i data-count [
	angle: 360 / data-count * (i - 1)
	direction: reduce [sine angle cosine angle]
	insert/only tail direction-block direction
]
if categories-data [
	size-text-face/font: category-font
	repeat i data-count [
		direction: direction-block/:i
		; compute size of the category text
		size-text-face/text: categories-data/:i
		f: size-text size-text-face
		insert tail direction f
		; compute category space
		case [
			direction/1 > 0.0 [
				position-x: direction/1 * spider-radius
					- spider-radius + f/x
				position-y: 0
			]
			direction/1 < 0.0 [
				position-x: - direction/1 * spider-radius
					- spider-radius + f/x
				position-y: 0
			]
			true [
				position-x: f/x / 2
				position-y: f/y
			]
		]
		category-horiz: max category-horiz position-x
		category-vert: max category-vert position-y
	]
	category-horiz: category-font/size + category-horiz
	category-vert: category-font/size + category-vert
	spider-radius: round/floor min
		size-data/x / 2 - category-horiz
		size-data/y / 2 - category-vert
]

; compute the scale if needed
auto-scale-ticks: none
tick-distance: none
scale-max: none
if number? scale-data [
	; compute the distance between ticks
	tick-distance: round/floor/to either decimal? scale-data [
		scale-data
	][
		data-max / scale-data
	] precision-data
	if zero? tick-distance [tick-distance: precision-data]

	; adjust data-max if needed
	if integer? scale-data [
		data-max: max data-max scale-data * tick-distance
	]

	; compute the number of the ticks
	auto-scale-ticks: round/floor data-max / tick-distance

	scale-data: make block! 0
	append scale-data 0
	repeat i auto-scale-ticks [append scale-data tick-distance * i]
]

spider-ratio: spider-radius / data-max
repeat i data-count [poke scales i spider-radius / scales/:i]

comment {
face/screen-to-xy: func [
	point [pair!]
	/local arg i dirx diry
] compose [
	point: point - (chart-centre)
;			arg: 180 + argument point/y negate point/x
arg: 180 +
	i: 1 + round arg / 360 * (data-count)
	if i > (data-count) [i: 1]
	dirx: sine i - 1 * 360 / (data-count)
	diry: negate cosine i - 1 * 360 / (data-count)
	; distance limit
	if 10 < abs ([(dirx * point/y) - (diry * point/x)]) [return false]
	round/to divide ([(dirx * point/x) + (diry * point/y)])
		pick (reduce [scales]) i (precision-data)
]
}

compute-grid: lfunc [grid][][
	if block? grid [return grid]
	grid-count: grid
	grid-distance: none
	grid: make block! 0
	either decimal? grid-count [
		grid-distance: grid-count
		grid-count: round/floor data-max / grid-count
	][
		grid-distance: data-max / grid-count
	]
	repeat i grid-count [append grid grid-distance * i]
	grid
]

; build the draw block
description: copy skip description 2 ;remove [graph spider]..
;chart requires result to be in 'result
result: append layer1 build/with description [

	tool-tip: func [][
		face/tool-tip: [
			"" [
				tool-tip/text: face/screen-to-xy event/offset - win-offset? face
				if tool-tip/text [
					tool-tip/text: form tool-tip/text
					tool-tip/size: 4 + size-text tool-tip
				]
			]
		]
		[]
	]

	scale: lfunc [count color][][
		chart: make block! 0
		position-x: chart-centre/x - graph/font/size
		string: none
		size-text-face/font: graph/font
		insert tail chart reduce [
			'pen none
			'fill-pen graph/grid-color
		]
		foreach tick scale-data [
			string: form tick
			size-text-face/text: string
			f: size-text size-text-face
			position-y: as-pair round position-x - f/x ;- 100
				round chart-centre/y - (spider-ratio * tick) -
				(graph/font/size / 2)
			insert tail chart reduce [
		;		'fill-pen none
				'text 'vectorial position-y string
			]
		]
		chart
	]

	grid: lfunc [grid][][
		chart: make block! 0
		insert tail chart reduce ['pen graph/grid-color 'fill-pen none]
		either equal? graph/grid-type 'circle [
			foreach tick compute-grid grid/x [
				append chart reduce [
					'circle chart-centre spider-ratio * tick
				]
			]
		][
			foreach tick compute-grid grid/x [
				append chart 'polygon
				repeat i data-count [
					position-x: direction-block/:i/1 * spider-ratio * tick
					position-y: direction-block/:i/2 * spider-ratio * tick
					append chart as-pair
						round chart-centre/x + position-x
						round chart-centre/y - position-y
				]
			]
		]

		;--moved from 'directions
		;print "directions"
		;chart: make block! 3 * data-count
		if grid/y > 0 [
			repeat i data-count [
				direction: direction-block/:i
				position-x: direction/1 * spider-radius
				position-y: direction/2 * spider-radius
				position-x: as-pair round chart-centre/x + position-x
					round chart-centre/y - position-y
				insert tail chart reduce ['line chart-centre position-x]
			]
		]
		chart
	]

	data: lfunc [
		{Draw the data}
		data
	][][
		chart: make block! 1 + data-count
		;insert tail chart reduce ['pen current-pen]
		insert tail chart 'polygon
		repeat i data-count [
			position-x: direction-block/:i/1 * scales/:i * data/:i
			position-y: direction-block/:i/2 * scales/:i * data/:i
			insert tail chart as-pair
				round chart-centre/x + position-x
				round chart-centre/y - position-y
		]
		chart
	]

	categories: lfunc [][][
		chart: make block! 3 * data-count
		repeat i data-count [
			direction: direction-block/:i
			f: direction/3
			position-x: direction/1 * spider-radius
			position-y: direction/2 * spider-radius
			case [
				direction/1 > 0.0 [
					position-x: position-x + (category-font/size / 2)
					position-y: position-y + (f/y / 2)
				]
				all [direction/1 = 0.0 direction/2 > 0.0][
					position-x: position-x - (f/x / 2)
					position-y: position-y + (category-font/size / 2) +
						f/y
				]
				direction/1 < 0.0 [
					position-x: position-x - f/x -
						(category-font/size / 2)
					position-y: position-y + (f/y / 2)
				]
				true [
					position-x: position-x - (f/x / 2)
					position-y: position-y - (category-font/size / 2)
				]
			]
			position-x: as-pair round chart-centre/x + position-x
				round chart-centre/y - position-y
			insert tail chart reduce [
				'text position-x categories-data/:i
			]
		]
		chart
	]
]
result
