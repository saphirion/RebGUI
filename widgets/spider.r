Rebol [
	Author: "Ladislav Mecir"
	Date: 25-Jul-2007/13:56:14+2:00
]

argument: func [
    {returns the angle of the given plane vector in degrees} 
    x [number!] 
    y [number!] 
    /radians "returns the angle in radians" 
    /local 
    half-circle
] [
    half-circle: either radians [pi] [180] 
    if x = 0 [
        if y = 0 [return 0] 
        return half-circle * either y < 0 [-0.5] [0.5]
    ] 
    y: either radians [arctangent/radians y / x] [arctangent y / x] 
    if x >= 0 [return y] 
    either y >= 0 [y - half-circle] [y + half-circle]
] 

;===BUILD

build: none

use [encl dtto spc] [
	; patch the IN function if needed
	spc: find/only third :in reduce [word!]
	if spc [change spc/1 any-word!]

	encl: func [
		{"a value in a block" function}
		value [any-type!]
	] [head insert/only copy [] get/any 'value]
	
	dtto: func [
		{a "pass the value over" function}
		value [any-type!]
	] [return get/any 'value]
	
	build: func [
		{
			Build a block comfortably.
			Using 'INS and 'ONLY "keywords" by default.
			INS inserts the following value (similar to INSERT)
			ONLY inserts a series as one item (similar to INSERT/ONLY)
		}
		block [block! paren! path! set-path! lit-path!]
		/with {use the "keywords" given below}
		keywords [block!] 
		/local context inner
	] [
		keywords: any [keywords [only: :encl ins: :dtto]]
		context: make object! keywords
		inner: func [block /local item item' pos result] [
			result: make :block length? :block
			parse :block [
				any [
					pos: set item word! (
						either all [item': in context item item <> 'self] [
							change pos item'
							set/any [item pos] do/next pos
							insert tail :result get/any 'item
						] [insert tail :result item pos: next pos]
					) :pos | set item get-word! (
						either all [item': in context item item <> 'self] [
							insert/only tail :result get/any item'
						] [insert tail :result item]
					) | set item [
						block! | paren! | path! | set-path! | lit-path!
					] (
						insert/only tail :result inner :item
					) | set item skip (insert/only tail :result get/any 'item)
				]
			]
			:result
		]
		inner :block
	]
]

;===

;===DEFAULT

default: func [
	{Execute code. If error occurs, execute fault.}
	[throw]
	code [block!] {Code to execute}
	fault [block!] {Error handler}
] [
	either error? set/any 'code try code [
		fault: make function! [[throw] error [error!]] fault
		fault code
	] [get/any 'code]
]

get-e: func [
	{get an error attribute}
	error [error!]
	attribute [word!]
] [
	get in disarm error attribute
]

set-e: func [
	{set an error attribute}
	error [error!]
	attribute [word!]
	value
] [
	set in disarm error attribute value
] 

;===

;===TFUNC

tfunc: func [
	{
		Create a function, which:
		- is transparent for return, exit, throw
		- can return any value using return'
		- can exit using exit'
		- can handle errors using throw'
		- is transparent for "foreign" return', exit', throw'
	}
	; Note: "Needs Core 2.6 or higher"
	[catch]
	spec [block!] {Help string (opt) followed by arg words (and opt type and string)}
	body [block!] {The body block of the function}
] [
	; Preserve the original spec block
	spec: copy spec
	; Make sure spec contains a documentation string
	unless string? pick spec 1 [insert spec "(undocumented)"]
	; Make sure spec contains "attribute"
	unless any [
		block? pick spec 2
		string? pick spec 2
	] [insert/only next spec "tfunc"]
	use [f spc] [
		use [return' exit' throw'] [
			return':  make function! [[throw] value [any-type!]] [
				; let f know, that this is the proper return'
				spc/2: "tfunc"
				return get/any 'value
			]
			exit': make function! [[throw]] [
				; let f know, that this is the proper exit'
				spc/2: "tfunc"
				exit
			]
			throw': make function! [error [error!]] [
				; let f know, that this is the proper throw'
				spc/2: [catch]
				throw error
			]
			; let the body use the above 'return', 'exit' and 'throw'
			body: bind/copy body 'return'
			f: default [make function! spec compose [1 2 (body)]] [throw error]
			spc: third :f
			change second :f [spc/2: [throw]]
			:f
		]
	]
]

tbody: func [
	{the body of a Tfunc}
	f [function!]
] [
	skip second :f 2
]    

; A call of the following functions outside of a tfunc is an error
system/error/throw: make system/error/throw [
	no-tfunc: "Return', exit' or throw' not in a tfunc"
]
return': func [[catch]] [throw make error! [throw no-tfunc]]
exit': func [[catch]] [throw make error! [throw no-tfunc]]
throw': func [[catch]] [throw make error! [throw no-tfunc]]

catch': func [
	{Catches a throw' from a block and returns its value.}
	block [block!] "Block to evaluate"
	/local result1 result2 result1?
] [
	; create a "fresh block"
	set [throw' block] use [throw'] reduce ['throw' copy/deep block]
	set throw' func [value [any-type!]] [
		error? set/any 'result1 get/any 'value
		result1?: true
		make error! ""
	]
	either error? set/any 'result2 try block [
		either result1? [return get/any 'result1] [result2]
	] [return get/any 'result2]
]

;===

;===SET-WORDS

set-words: function [
	{Get all set-words from a block}
	block [block!]
] [elem words] [
	words: make block! length? block
	parse block [
		any [
			set elem set-word! (
				insert tail words to word! :elem
			) | skip
		]
	]
	words
] 

;===

;===LOCALS

locals?: func [
	{Get all locals from a spec block.}
	spec [block!]
	/args {get only arguments}
	/local locals item item-rule
] [
	locals: make block! length? spec
	item-rule: either args [
		[
			refinement! to end (item-rule: [end skip]) |
			set item any-word! (insert tail locals to word! :item) | skip
		]
	] [
		[
			set item any-word! (insert tail locals to word! :item) | skip
		]
	]
	parse spec [any item-rule]
	locals
] 

;===

;===LFUNC

lfunc: tfunc [
	{Define a function with auto local and static variables.}
	spec [block!] {Help string (opt) followed by arg words with opt type and string}
	init [block!] {Set-words become static variables, subblocks not scanned}
	body [block!] {Set-words become local variables, subblocks not scanned}
	/handle {Handle errors using catch/default}
	/local svars lvars context result
] [
	; Preserve the original Spec, Init and Body
	spec: copy spec
	init: copy/deep init
	body: copy/deep body
	; Collect static variables
	unless empty? svars: unique set-words init [
		; create the static context and bind Init and Body to it
		use svars reduce [reduce [init body]]
	]
	do init
	; Collect local variables
	unless empty? lvars: exclude exclude set-words body locals? spec svars [
		insert any [find spec /local insert tail spec /local] lvars
	]
	either handle [
		; skip the help string
		if string? pick spec 1 [spec: next spec]
		either block? pick spec 1 [change/only spec union spec/1 [catch]] [
			insert/only spec copy [catch]
		]
		spec: head spec
		either context: find spec any-word! [
			result: default [
				func spec reduce [to word! first context]
			] [throw' error]
			bind body first second :result
			remove second :result
		] [
			result: default [func spec []] [throw' error]
		]
		insert second :result 'default
		insert/only tail second :result body
		insert/only tail second :result [throw error]
		:result
	] [
		default [func spec body] [throw' error]
	]
]

;===


spider: make rebface [
	tip: [{
		USAGE:
		series1: [450 450 450 450 450 450 450 450]
		series2: [250 250 250 250 250 250 250 250]
		display "spider-test" [
			button-size 30
			button "Change series1" [
				series1: copy []
				repeat i 8 [append series1 100 * random 8]
				s/redraw
				show s
			]
			button "Change series2" [
				series2: copy []
				repeat i 8 [append series2 100 * random 8]
				s/redraw
				show s
			]
			; spider chart with a white background
			s: spider white 100x100 data [
				line-width 2

				; scale etc.
				pen black
				scale 4
				grid 4
				categories [
					"Category 1" "Category 2" "Category 3" "Category 4"
					"Category 5" "Category 6" "Category 7" "Category 8"
				]
				directions
				tool-tip
				legend 0x0 ["series1" "series2"]	        
				
				; data plotting directives
				pen red
				fill-pen 255.0.0.128
				data series1
				pen green
				fill-pen 0.255.0.128
				data series2
			] #HW
		]
		do-events

		Keywords:
			keywords are functions evaluating their arguments
			
			scale - marks [number! block!]
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width

			categories - cat [block!] - specifies category names

			directions - - draws the directions

			data - [block!] - data series we want to plot,
				multiple series can be used
			
			precision - [number!] - sets up the precision factor

			font - [object!] - defines current font, patches the Draw command
			
			pen - [tuple!] - defines current pen, patches the Draw command
			
			fill-pen - [tuple! none!] - defines current fill-pen, patches the Draw command
			
			legend - offset [pair!] names [block!] - draws the legend
			
			plot - offset [pair!] size! [pair!] - does not draw,
				limits the plot size to a part of the whole drawing
			
			tool-tip - - turns the "default tool-tip" for the widget on
			
			grid - [number! block!] - draws a polygonal grid
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections
					decimal specifies section width
			
			circle-grid - [number! block!] - draws a circular grid
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width
			
			auto-scaling - - does not draw, turns on auto-scaling
			
			In addition to these, any Draw command can be used
			(see e.g. the Line-width command above)

		DESCRIPTION:
			A spider, also known as web chart.
	}]




;==after tip
	old-size: size: -1x-1
	effect: [merge]

	feel: make default-feel [
		redraw: func [face act pos] [
			if all [act <> 'hide face/old-size <> face/size] [
				face/old-size: face/size
				face/redraw
			]
		]
	]

	init: func [] [
		if negative? size/x [size/x: 200]
		if negative? size/y [size/y: 200]
		color: any [color system/words/face/color]
		old-size: size
		redraw
	]

	generate: lfunc [
		{generate the spider chart draw block}
		[catch]
		face [object!] {the face}
	] [] [

		; initialization
		description: face/data
		size-data: face/size
		offset-data: 0x0
		current-font: default-font: make ctx-rebgui/widgets/default-font []
		current-pen: default-pen: white
		current-fill-pen: none
		
		legend-colors: make block! 0
		legend-pen: none

		scale-data: none ; scale
		scale-font: none
		
		categories-data: none ; list of strings describing data
		category-font: current-font
		
		data-max: 0.0 ; maximal data value
		data-data: make block! 0 ; charted data

		precision-data: 1
		
		auto-scaling?: false
		scales: none

		; collect data
		description: build/with description  [
			; all functions return a block,
			; that will be inserted into the second pass block
			plot: func [
				{limits the plot to a part of the whole drawing}
				offset [pair!]
				size [pair!]
			] [
				offset-data: offset
				size-data: size
				[]
			]
			
			auto-scaling: func [
				{sets up the auto-scaling}
			] [
				auto-scaling?: true
				[]
			]
			
			legend: func [
				{draws the legend}
				offset [pair!]
				names [block!]
			] [
				legend-pen: current-pen
				reduce [
					'legend offset names
					'fill-pen current-fill-pen
				]
			]
			
			precision: func [
				{set up the precision factor}
				factor [number!]
			] [
				precision-data: factor
				[]
			]
			
			font: func [
				{set the current font}
				fnt [object!]
			] [
				current-font: fnt
				reduce ['font fnt]
			]
			
			pen: func [
				{set the current pen}
				color [tuple!]
			] [
				current-pen: color
				reduce ['pen color]
			]
			
			fill-pen: func [
				{set the current fill-pen}
				color [tuple! none!]
			] [
				current-fill-pen: color
				reduce ['fill-pen color]
			]

			scale: func [
				{set the scale}
				scale [block! integer!]
			] [
				scale-data: scale
				if block? scale [data-max: max data-max first maximum-of scale]
				scale-font: current-font
				'scale
			]

			grid: func [
				{set the grid}
				grid [block! integer!]
			] [
				if block? grid [data-max: max data-max first maximum-of grid]
				reduce ['grid grid]
			]

			circle-grid: func [
				{set the grid}
				grid [block! integer!]
			] [
				if block? grid [data-max: max data-max first maximum-of grid]
				reduce ['circle-grid grid]
			]

			data: func [
				{draw the the data series}
				data [block!]
				/local position
			] [
				append legend-colors current-pen
				parse data [any [position: none! (change position 0) | skip]]
				insert/only tail data-data data
				reduce ['data data]
			]

			categories: func [
				{describe categories}
				cat [block!]
			] [
				categories-data: cat
				category-font: current-font
				'categories
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
		text-face: make system/words/face [size: 1000000x1000000]
		f: none
		angle: none
		direction: none
		position-x: none
		position-y: none
		
		; auto-scaling
		either all [
			auto-scaling?
			not empty? data-data
		] [
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
			repeat i data-count [if zero? scales/:i poke scales i data-max]
		] [
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
			'font default-font
			'pen default-pen
			'fill-pen none
		]	

		; compute the chart centre
		chart-centre: as-pair round size-data/x / 2 + offset-data/x
			round size-data/y / 2 + offset-data/y
		spider-radius: round/floor min size-data/x / 2 size-data/y / 2
		
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
			text-face/font: category-font
			repeat i data-count [
				direction: direction-block/:i
				; compute size of the category text
				text-face/text: categories-data/:i
				f: size-text text-face
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
			] [
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
		
		face/screen-to-xy: func [
			point [pair!]
			/local arg i dirx diry 
		] compose [
			point: point - (chart-centre)
	    	arg: 180 + argument point/y negate point/x
 
			i: 1 + round arg / 360 * (data-count)
			if i > (data-count) [i: 1]
			dirx: sine i - 1 * 360 / (data-count)
			diry: negate cosine i - 1 * 360 / (data-count)
			; distance limit
			if 10 < abs ([(dirx * point/y) - (diry * point/x)]) [return false]
			round/to divide ([(dirx * point/x) + (diry * point/y)])
				pick (reduce [scales]) i (precision-data)
		]
		
		compute-grid: lfunc [grid] [] [
			if block? grid [return grid]
			grid-count: grid
			grid-distance: none
			grid: make block! 0
			either decimal? grid-count [
				grid-distance: grid-count
				grid-count: round/floor data-max / grid-count
			] [
				grid-distance: data-max / grid-count
			]
			repeat i grid-count [append grid grid-distance * i]
			grid
		]

		; build the draw block
		append layer1 build/with description [
			legend: func [
				offset [pair!]
				names [block!]
				/local drawing legend-text-size
			] [
				drawing: make block! 0
				
				; compute text size
				legend-text-size: 0x0
				foreach name names [
					text-face/text: name
					legend-text-size: max legend-text-size size-text text-face
				]
				
				repeat i min length? names length? legend-colors [
					append drawing compose [
						pen (legend-colors/:i)
						fill-pen (legend-colors/:i)
						box
							(offset)
							(1x1 * legend-text-size/y + offset)
						pen (legend-pen) 
						text (names/:i) (1.5 * legend-text-size/y * 1x0 + offset)
					]
					offset: 1.5 * legend-text-size/y * 0x1 + offset
				]
				
				drawing
			]
		
			tool-tip: func [] [
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
			
			scale: lfunc [] [] [
				chart: make block! 0
				position-x: chart-centre/x - scale-font/size
				string: none
				text-face/font: scale-font
				foreach tick scale-data [
					string: form tick
					text-face/text: string
					f: size-text text-face
					position-y: as-pair round position-x - f/x
						round chart-centre/y - (spider-ratio * tick) -
						(scale-font/size / 2)
					insert tail chart reduce ['text position-y string]
				]
				chart
			]

			grid: lfunc [grid] [] [
				chart: make block! 0
				foreach tick compute-grid grid [
					append chart 'polygon
					repeat i data-count [
						position-x: direction-block/:i/1 * spider-ratio * tick
						position-y: direction-block/:i/2 * spider-ratio * tick
						append chart as-pair
							round chart-centre/x + position-x
							round chart-centre/y - position-y
					]
				]
				chart
			]

			circle-grid: lfunc [grid] [] [
				chart: make block! 0
				foreach tick compute-grid grid [
					append chart reduce [
						'circle chart-centre spider-ratio * tick
					]
				]
				chart
			]

			data: lfunc [
				{Draw the data}
				data
			] [] [
				chart: make block! 1 + data-count
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

			directions: lfunc [] [] [
				chart: make block! 3 * data-count
				repeat i data-count [
					direction: direction-block/:i
					position-x: direction/1 * spider-radius
					position-y: direction/2 * spider-radius
					position-x: as-pair round chart-centre/x + position-x
						round chart-centre/y - position-y
					insert tail chart reduce ['line chart-centre position-x]
				]
				chart
			]

			categories: lfunc [] [] [
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
						all [direction/1 = 0.0 direction/2 > 0.0] [
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
	]



	redraw: func [] [
		image: make image! size
		image/rgb: color
		draw image generate self
	]

	; function to convert screen coordinates
	screen-to-xy: false
]

xyplot: make spider [
	tip: [{
		Usage:
		;xyplot with yellow background
		display "xyplot-test" [
			xyplot yellow 100x100 data [
				; draw axes etc.
				pen black
				x-min 24
				x-max 40
				y-min 2
				y-max 6
				x-grid 32
				y-grid 20
				x-axis
				x-scale 16
				y-axis
				y-scale 4
				x-color 27 28 none
				x-color 28 29 blue
				tool-tip

				; draw data
				pen red
				line-width 5
				line-cap round
				connect reduce [
					24 24 ** -0,39943 * 13,2276
					30 30 ** -0,39943 * 13,2276
				]
			] #HW
		]
		do-events

		Keywords:
			Keywords are functions evaluating their arguments.

			connect - series [block!] - defines/draws data series line,
				can be used multiple times
				every first number is the x coordinate,
				every second number is the y coordinate

			point - [integer!] "mark size" [block!] defines/draws point marks
				can be used multiple times
				every first number in the block is the x coordinate,
				every second number is the y coordinate

			convert - [number!] [number!] - converts XY coordinates to pairs

			log-x-scale - [number! block!] - draws a logarithmic scale
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width

			log-y-scale - [integer!] - draws a logarithmic scale
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width

			x-axis - - draws the x axis

			x-grid - grid [number! block!] - draws a grid
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width

			x-max - [number!] - maximal x value (default is the maximal x coordinate of data)

			x-min - [number!] - minimal x value (default is the minimal x coordinate of data)

			x-scale - marks [number! block!] - draws a linear scale
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width

			y-axis - - draw the y axis

			y-grid - [number! block!] - draws a linear scale
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width

			y-max - [number!] - maximal y value (default is the maximal y coordinate of data)

			y-min - [number!] - minimal y value (default is the minimal y coordinate of data)

			y-scale - [integer!] - draws a linear scale
				block can be used to specify positions,
				when a number is given, positions are evenly spaced
					integer specifies the number of sections,
					decimal specifies section width
			
			x-precision - [number!] - specifies precision scale factor
			
			y-precision - [number!] - specifies precision scale factor
			
			x-color - [number!] "start" [number!] "end" [tuple! none!] "color" - draw a column

			font - [object!] - defines current font, patches the Draw command

			tool-tip - - turns the "default tool-tip" for the widget on
			
			pen - [tuple!] - defines current pen, patches the Draw command
			
			fill-pen - [tuple! none!] - defines current fill-pen, patches the Draw command
			
			legend - offset [pair!] names [block!] - draws the legend
			
			plot - offset [pair!] size! [pair!] - does not draw,
				limits the plot size to a part of the whole drawing
			
			In addition to these, any Draw command can be used
			(see e.g. the Pen, Line-width and Line-cap commands above)

		DESCRIPTION:
			XY chart
	}]

generate: lfunc [
		{generate the xyplot draw block}
		[catch]
		face [object!] {the face}
	] [] [
		; initialization
		description: face/data
		size-value: face/size
		offset-value: 0x0

		current-font: default-font: make system/words/face/font []

		current-pen: default-pen: white
		current-fill-pen: none

		legend-colors: make block! 0
		legend-pen: none

		scale-font: current-font
		scale-max: none
		x-min-value: none
		x-max-value: none
		x-scale-ticks: none
		y-min-value: none
		y-max-value: none
		y-scale-ticks: none
		x-data-min-value: none
		x-data-max-value: none
		y-data-min-value: none
		y-data-max-value: none
		x-scale-font: none
		y-scale-font: none
		log-x: false
		log-y: false
		x-precision-value: 1
		y-precision-value: 1
		
		; set the default font, pen and fill-pen
		layer1: reduce [
			'font default-font
			'pen default-pen
			'fill-pen none
		]	

		legend-colors: make block! 0
		legend-pen: none

		; collect data
		description: build/with description  [
			; all functions return a block,
			; that will be inserted into the second pass block 
			plot: func [
				{limits the plot to a part of the whole drawing}
				offset [pair!]
				size [pair!]
			] [
				offset-value: offset
				size-value: size
				[]
			]
			
			pen: func [
				{set the current pen}
				color [tuple!]
			] [
				current-pen: color
				reduce ['pen color]
			]
			
			fill-pen: func [
				{set the current fill-pen}
				color [tuple! none!]
			] [
				current-fill-pen: color
				reduce ['fill-pen color]
			]

			legend: func [
				{draws the legend}
				offset [pair!]
				names [block!]
			] [
				legend-pen: current-pen
				reduce [
					'legend offset names
					'fill-pen current-fill-pen
				]
			]
			
			x-color: func [
				{draw a column}
				start [number!]
				end [number!]
				color [tuple! none!]
				/local var
			] [
				; color none means "transparent"
				unless color [color: 0.0.0.255]
				
				; make sure start is minimum and end is maximum
				var: max start end
				start: min start end
				end: var
				
				either x-min-value [
					x-min-value: min x-min-value start
					x-max-value: max x-max-value end
				] [
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
				x-precision [integer!]
			] [
				x-precision-value: x-precision
				[]
			]
			
			y-precision: func [
				{set the y-precision value}
				y-precision [integer!]
			] [
				y-precision-value: y-precision
				[]
			]
			
			font: func [
				{set the current font}
				fnt [object!]
			] [
				current-font: fnt
				reduce ['font fnt]
			]

			x-min: func [
				{set the x-min-value}
				value [number!]
			] [
				x-min-value: value
				[]
			]

			x-max: func [
				{set the x-max-value}
				value [number!]
			] [
				x-max-value: value
				[]
			]

			y-min: func [
				{set the y-min-value}
				value [number!]
			] [
				y-min-value: value
				[]
			]

			y-max: func [
				{set the y-max-value}
				value [number!]
			] [
				y-max-value: value
				[]
			]

			x-scale: func [ticks [integer! block!]] [
				x-scale-font: current-font
				x-scale-ticks: ticks
				log-x: false
				reduce ['x-scale]
			]

			log-x-scale: func [ticks [integer! block!]] [
				x-scale-font: current-font
				x-scale-ticks: ticks
				log-x: true
				reduce ['x-scale]
			]

			y-scale: func [ticks [integer! block!]] [
				y-scale-font: current-font
				y-scale-ticks: ticks
				log-y: false
				reduce ['y-scale]
			]

			log-y-scale: func [ticks [integer! block!]] [
				y-scale-font: current-font
				y-scale-ticks: ticks
				log-y: true
				reduce ['y-scale]
			]

			connect: func [data [block!]] [
				append legend-colors current-pen
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
				reduce ['connect data]
			]

			point: func [size [integer!] data [block!]] [
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
		]


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
		x-min-value: min any [x-min-value x-data-min-value] x-data-min-value
		x-max-value: max any [x-max-value x-data-max-value] x-data-max-value
		y-min-value: min any [y-min-value y-data-min-value] y-data-min-value
		y-max-value: max any [y-max-value y-data-max-value] y-data-max-value
		; take care of spread
		if x-min-value = x-max-value [
			either log-x [
				x-min-value: x-min-value / 10.0
				x-max-value: x-max-value * 10.0
			] [
				x-min-value: x-min-value - 1
				x-max-value: x-max-value + 1
			]
		]
		if y-min-value = y-max-value [
			either log-y [
				y-min-value: y-min-value / 10.0
				y-max-value: y-max-value * 10.0
			] [
				y-min-value: y-min-value - 1
				y-max-value: y-max-value + 1
			]
		]
		; round
		; ATT! may be problematic for log-scale (if rounded to zero)
		x-min-value: round/floor/to x-min-value x-precision-value
		x-max-value: round/ceiling/to x-max-value x-precision-value
		y-min-value: round/floor/to y-min-value y-precision-value
		y-max-value: round/ceiling/to y-max-value y-precision-value
		
		compute-scale: lfunc [
			scale-ticks [number! block!]
			scale-min [word!]
			scale-max [word!]
			log? [logic!]
			precision [number!]
		] [] [
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
				] [
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
			] [
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
		
		x-scale-ticks: compute-scale
			x-scale-ticks 'x-min-value 'x-max-value log-x x-precision-value
		y-scale-ticks: compute-scale
			y-scale-ticks 'y-min-value 'y-max-value log-y y-precision-value

		compute-grid: lfunc [grid scale-min scale-max] [] [
			if block? grid [return grid]

			grid-count: grid
			grid-distance: none

			grid: make block! 0
			append grid scale-min

			either decimal? grid-count [
				grid-distance: grid-count
				grid-count: round/floor scale-max - scale-min / grid-distance
			] [
				grid-distance: scale-max - scale-min / grid-count
			]
			
			repeat i grid-count [append grid grid-distance * i + scale-min]
			
			grid
		]

		; compute space around the plot
		text-face: make system/words/face [size: 1000000x1000000]
		text-face/font: x-scale-font
		f: form x-min-value
		text-face/text: f
		f: size-text text-face
		below-plot: x-scale-font/size + f/y
		lh-plot: round/ceiling f/x / 2

		f: form x-max-value
		text-face/text: f
		f: size-text text-face
		below-plot: max below-plot x-scale-font/size + f/y
		rh-plot: round/ceiling f/x / 2

		text-face/font: y-scale-font
		f: form y-min-value
		text-face/text: y-min-value
		f: size-text text-face
		below-plot: max below-plot round/ceiling f/y / 2

		foreach y-coordinate y-scale-ticks [
			y-coordinate: form y-coordinate
			text-face/text: y-coordinate
			f: size-text text-face
			lh-plot: max lh-plot y-scale-font/size + f/x
		]

		f: form y-max-value
		text-face/text: y-max-value
		f: size-text text-face
		above-plot: round/ceiling f/y / 2

		; size adjustments
		if any [
			lh-plot + rh-plot >= size-value/x
			below-plot + above-plot >= size-value/y
		] [
			throw make error! "plot size too small"
		]
		offset-value/x: offset-value/x + lh-plot
		offset-value/y: offset-value/y + above-plot
		size-value/x: size-value/x - lh-plot - rh-plot
		size-value/y: size-value/y - below-plot - above-plot
		x-spread: either log-x [log-e x-max-value / x-min-value] [
			x-max-value - x-min-value
		]
		y-spread: either log-y [log-e y-max-value / y-min-value] [
			y-max-value - y-min-value
		]
		x-ratio: size-value/x / x-spread
		y-ratio: size-value/y / y-spread

		; the conversion function
		convert*: func [x [number!] y [number!]] build/with [
			as-pair round cvtx round cvty
		] [
			cvtx: either log-x [
				[(log-e x / x-min-value) * x-ratio + offset-value/x]
			] [
				[x - x-min-value * x-ratio + offset-value/x]
			]
			cvty: either log-y [
				[size-value/y - (y-ratio * log-e y / y-min-value) + offset-value/y]
			] [
				[size-value/y - (y - y-min-value * y-ratio) + offset-value/y]
			]
		]
		; reverse conversion
		face/screen-to-xy: func [point [pair!]] build/with build/with [
			reduce [
				round/to cvtx x-precision-value'
				round/to cvty y-precision-value'
			]
		] [
			cvtx: either log-x [
				[(exp point/x - (first offset-value') / x-ratio') * x-min-value']
			] [
				[add point/x - (first offset-value') / x-ratio' x-min-value']
			]
			cvty: either log-y [
				[(exp (second offset-value') + (second size-value') - point/y / y-ratio') * y-min-value']
			] [
				[add (second offset-value') + (second size-value') - point/y / y-ratio' y-min-value']
			]
		] [
			x-precision-value': x-precision-value
			y-precision-value': y-precision-value
			offset-value': offset-value
			x-ratio': x-ratio
			x-min-value': x-min-value
			y-ratio': y-ratio
			y-min-value': y-min-value
			size-value': size-value
		]

		; draw plot
		description: build/with description [
			legend: func [
				offset [pair!]
				names [block!]
				/local drawing legend-text-size
			] [
				drawing: make block! 0
				
				; compute text size
				legend-text-size: 0x0
				foreach name names [
					text-face/text: name
					legend-text-size: max legend-text-size size-text text-face
				]
				
				repeat i min length? names length? legend-colors [
					append drawing compose [
						pen (legend-colors/:i)
						fill-pen (legend-colors/:i)
						box
							(offset)
							(1x1 * legend-text-size/y + offset)
						pen (legend-pen) 
						text (names/:i) (1.5 * legend-text-size/y * 1x0 + offset)
					]
					offset: 1.5 * legend-text-size/y * 0x1 + offset
				]
				
				drawing
			]
		
			tool-tip: func [] [
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

			x-color: lfunc [
				start [number!]
				end [number!]
				color [tuple!]
			] [] [
				compose [
					pen (color)
					fill-pen (color)
					box (convert* start y-max-value) (convert* end y-min-value)
				]
			]
			
			x-grid: lfunc [values [number! block!]] [] [
				values: compute-grid values x-min-value x-max-value 

				chart: make block! 0
				foreach value values [
					append chart reduce [
						'line convert* value y-min-value convert* value y-max-value
					]
				]
				chart
			]

			y-grid: lfunc [values [integer! block!]] [] [
				values: compute-grid values y-min-value y-max-value

				chart: make block! 0
				foreach value values [
					append chart reduce [
						'line convert* x-min-value value convert* x-max-value value
					]
				]
				chart
			]

			x-axis: lfunc [] [] [
				start-point: as-pair offset-value/x size-value/y + offset-value/y
				end-point: as-pair size-value/x + offset-value/x start-point/y
				reduce ['line start-point end-point]
			]

			y-axis: lfunc [] [] [
				start-point: as-pair offset-value/x size-value/y + offset-value/y
				end-point: as-pair start-point/x offset-value/y
				reduce ['line start-point end-point]
			]

			x-scale: lfunc [] [] [
				chart: make block! 6 * length? x-scale-ticks
				start-point: none
				end-point: none
				x-coordinate: none
				f: none
				text-face/font: x-scale-font
				foreach tick x-scale-ticks [
					; draw the tick
					start-point: convert* tick y-min-value
					end-point: as-pair start-point/x
						start-point/y + round x-scale-font/size / 2
					append chart reduce ['line start-point end-point]
					x-coordinate: form tick
					text-face/text: x-coordinate
					f: size-text text-face
					start-point: as-pair start-point/x - round f/x / 2
						start-point/y + x-scale-font/size
					append chart reduce ['text start-point x-coordinate]
				]
				chart
			]

			y-scale: lfunc [] [] [
				chart: make block! 6 * length? y-scale-ticks
				start-point: none
				end-point: none
				y-coordinate: none
				f: none
				text-face/font: y-scale-font
				foreach tick y-scale-ticks [
					; draw the tick
					start-point: convert* x-min-value tick
					end-point: as-pair start-point/x - round y-scale-font/size / 2
						start-point/y
					append chart reduce ['line start-point end-point]
					y-coordinate: form tick
					text-face/text: y-coordinate
					f: size-text text-face
					start-point: as-pair start-point/x - y-scale-font/size - f/x
						round start-point/y - (y-scale-font/size / 2)
					append chart reduce ['text start-point y-coordinate]
				]
				chart
			]

			connect: lfunc [data [block!]] [] [
				chart: make block! round/ceiling (length? data) / 2 + 1
				insert chart 'line
				foreach [x y] data [append chart convert* x y]
				chart
			]

			point: lfunc [size [integer!] data [block!]] [] [
				chart: make block! 3 * length? data
				center-point: none
				foreach [x y] data [
					center-point: convert* x y
					append chart reduce [
						'line as-pair center-point/x - size center-point/y
							as-pair center-point/x + size center-point/y
						'line as-pair center-point/x center-point/y - size
							as-pair center-point/x center-point/y + size
					]
				]
				chart
			]

			convert: :convert*
		]
		
		append layer1 description
	]
]
