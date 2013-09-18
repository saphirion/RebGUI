chart: make rebface [

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

	graph: none
	graph-specs: [
		order-mode: none
		order-blk: none
		values-mode: 'absolute
		hide-zeros?: false
		full-scaling?: false
		type:
		subtype: none
		title-color: white
		back-color: white
		grid-color: black
		line-width: 1
		point-color:
		point-size:
		point-shape: none
		font: make face/font [
			size: 18
		]
		font-size: none
		title: none
		x-label:
		y-label:
		min-value:
		max-value:
		min-gap:
		max-gap:
		alpha: 0
		data: none
	]

	trim-decimal: func [
		num [decimal! string!]
		rng [integer!]
		/local blk ln rn tmp tmp2
	][
		blk: parse/all form num ".E"
		either (length? blk) < 3 [
			if (length? blk/2) > rng [
				ln: to-integer to-string pick blk/2 rng
				rn: to-integer to-string pick blk/2 rng + 1
				if rn > 5 [
					tmp: to-integer copy/part blk/2 rng
					tmp2: ln + 1
					if tmp2 = 10 [tmp2: tmp2 - ln]
					blk/2: form tmp + tmp2
				]
			]
			rejoin [blk/1 "." copy/part blk/2 rng]
		][
			insert/dup blk/1 "0" absolute 1 + to-integer blk/3
			insert blk/1 "0."
			trim-decimal join blk/1 blk/2 rng
		]
	]

	size-text-face: make face [
		size: 1000000x1000000
	]

	draw-graph: func [
		graph [object!]
		graph-size [pair!]
		/local result graph-data
	][
		if any [
			not graph/type
			not graph/data
			empty? graph/data
		][
			return none
		]

		graph-data: copy/deep graph/data
		result: copy []

		if graph/font-size [
			graph/font/size: to-integer graph/font-size / (graph-size/y / 480)
		]

		switch graph/type [
			pie [
				use [tmp tmp2 img siz idx data-labels pos arc-360? tmp-v tmp-draw][
					switch graph/order-mode [
						size-up [
							sort/skip/compare graph-data 3 3
						]
						size-down [
							sort/reverse/skip/compare graph-data 3 3
						]
						id [
							idx: 0
							foreach i graph/order-blk [
								idx: idx + 1
								change/part at graph-data idx * 3 - 2 copy/part at graph/data i * 3 - 2 3 3
							]
						]
					]

					tmp: 0
					foreach [l c v] graph-data [
						tmp: tmp + v
					]
					if tmp = 0 [return result]
					tmp2: 360 / tmp
					arc-360?: false
					while [not tail? graph-data][
						graph-data/3: graph-data/3 * tmp2
						if graph-data/3 = 360 [
							;360 degree arc workaround
							graph-data/3: 180
							insert tail graph-data reduce [graph-data/1 graph-data/2 graph-data/3]
							arc-360?: true
							break
						]
						graph-data: skip graph-data 3
					]
					graph-data: head graph-data

					if graph/hide-zeros? [
						while [not tail? graph-data][
							either graph-data/3 = 0 [
								remove/part graph-data 3
							][
								graph-data: skip graph-data 3
							]
						]
					]
					graph-data: head graph-data

					either graph/subtype = 'torus [
						tmp: 270
						foreach [l c v] graph-data [
							insert tail result compose/deep [
								pen none
								fill-pen radial 235x275 80 180 0 1 1 0.0.0.255 black 0.0.0.255
								shape [
									move (as-pair 235 + (180 * cosine tmp) 275 + (180 * sine tmp))
									arc (as-pair 235 + (180 * cosine (tmp + v)) 275 + (180 * sine (tmp + v))) 180 180 0 false (either v > 180 [true][false])
									line (as-pair 235 + (80 * cosine (tmp + v)) 275 + (80 * sine (tmp + v)))
									arc (as-pair 235 + (80 * cosine tmp) 275 + (80 * sine tmp)) 80 80 0 true (either v > 180 [true][false])
								]
							]
							tmp: tmp + v
						]
					][
						insert tail result [
							pen none
							fill-pen radial 235x275 0 180 0 1 1 black black black black 0.0.0.255
							circle 235x275 180
						]
					]

					data-labels: copy []

					tmp: 270
					idx: 0
					tmp-draw: copy []
					foreach [l c v] graph-data [
						idx: idx + 2

						size-text-face/text: either graph/values-mode = 'percentage [
							either arc-360?
								["100.0%"]
								[rejoin [trim-decimal to-decimal (v / 360 * 100) 2 "%"]]
						][
							form-number trim-decimal to-decimal (v / tmp2) 2
						]
						size-text-face/font: graph/font
						siz: (size-text size-text-face) / 2
						tmp-v: either arc-360? [
							360
						][
							v
						]
						pos: as-pair 220 - siz/x + (195 + siz/x * cosine (tmp + (tmp-v / 2)))  260 - siz/y + (195 + siz/y * sine (tmp + (tmp-v / 2)))
						foreach [t s p c] data-labels [
							if all [
						        p/x < (pos/x + siz/x)
						        p/y < (pos/y + siz/y)
						        (p/x + s/x) > pos/x
						        (p/y + s/y) > pos/y
						    ][
								pos/y: p/y - siz/y - 6
							]
							pos: confine pos siz 0x0 640x480
						]
						insert tail data-labels reduce [
							size-text-face/text
							siz
							pos
							c
						]

						insert tail tmp-draw compose [
							(
								either graph/subtype = 'torus [
									;eliminate anti-aliased 'edges' first
									insert tail result compose/deep [
										line-width 8
										pen (c)
										line (as-pair 220 + (180 * cosine tmp) 260 + (180 * sine tmp)) (as-pair 220 + (80 * cosine tmp) 260 + (80 * sine tmp))
									]
									compose/deep [
										line-width 1
										pen none
										fill-pen (c)
										shape [
											move (as-pair 220 + (180 * cosine tmp) 260 + (180 * sine tmp))
											arc (as-pair 220 + (180 * cosine (tmp + v)) 260 + (180 * sine (tmp + v))) 180 180 0 false (either v > 180 [true][false])
											line (as-pair 220 + (80 * cosine (tmp + v)) 260 + (80 * sine (tmp + v)))
											arc (as-pair 220 + (80 * cosine tmp) 260 + (80 * sine tmp)) 80 80 0 true (either v > 180 [true][false])
										]										
									]
								][
									compose [
										pen none
										fill-pen (c)
										arc 220x260 180x180 (tmp)(v) closed
									]
								]
							)
							(
								either all [arc-360? tmp > 270][
								][
									compose [
										;legend - color boxes + labels
										fill-pen black
										pen none
										fill-pen (c)
										box (as-pair 460 idx * 20 + 10) (as-pair 480 idx * 20 + 30)
										fill-pen black
										text vectorial (as-pair 490 idx * 20 + 10) (translate l)
									]
								]
							)
						]
						tmp: tmp + v
					]
					insert tail result tmp-draw
					;add pie labels
					foreach [t s p c] data-labels [
						insert tail result compose [
							fill-pen black ; (c)
							pen none ; gray
							text vectorial (p) (t)
						]
						if arc-360? [break]
					]
				]
			]
			bar [
				use [bars-per-group bar-groups bars][


				bars: 0

				forall graph-data [if (index? graph-data) // 3 = 0 [graph-data/1: to-block graph-data/1]]

				if all [graph/order-mode = 'id integer? graph/order-blk/1] [
					vals: copy graph-data
					idx: 0
					foreach i graph/order-blk [
						idx: idx + 1
						i: i * 3 - 2
						change/part at graph-data idx * 3 - 2 copy/part at vals i 3 3
					]
				]

				bars-per-group: length? graph-data/3
				bar-groups: (length? graph-data) / 3

				if graph/hide-zeros? [
					while [not tail? graph-data][
						either graph-data/3 = [0] [
							remove/part graph-data 3
							bars: bars + 1
						][
							while [not tail? graph-data/3][
								either graph-data/3/1 = 0 [
									remove graph-data/3
									bars: bars + 1
								][
									graph-data/3: next graph-data/3
								]
							]
							graph-data/3: head graph-data/3
							graph-data: skip graph-data 3
						]
					]
				]
				graph-data: head graph-data

				switch graph/subtype [
					vertical [
						use [tpos sums max-val min-val rng tick bar-width x zero beg-line pos tick-line tmp tmp2 vals idx order idx2 legend-width chart-width][
							max-val: min-val: graph-data/3/1
;							bars: 0
							idx2: 0
							sums: array/initial bars-per-group 0
							foreach [l c v] graph-data [
								idx2: idx2 + 1
								idx: 0
								foreach val v [
									idx: idx + 1
									poke sums idx sums/:idx + val
									max-val: max max-val val
									min-val: min min-val val
									bars: bars + 1
								]
								switch graph/order-mode [
									size-up [
										sort v
									]
									size-down [
										sort/reverse v
									]
									id [
										vals: copy v
										idx: 0
										order: either block? graph/order-blk/1 [
											pick graph/order-blk idx2
										][
											graph/order-blk
										]
										if (length? order) = (length? v) [
											foreach i order [
												idx: idx + 1
												poke v idx pick vals i
											]
										]
									]
								]
							]
							switch graph/order-mode [
								size-up [
									sort/skip/compare graph-data 3 3
								]
								size-down [
									sort/reverse/skip/compare graph-data 3 3
								]
							]

							rng: max 1E-62 max-val - min-val
;							tick-line: max 1 (to-integer rng / 6 / 10) * 10
							tick-line: max 1 to-integer (graph/font/size / (360 / rng)) + .9
							if positive? min-val [
								min-val: either graph/full-scaling? [
									0
								][
									(to-integer (either integer? min-val [min-val - 1][min-val]) / tick-line) * tick-line
								]
								rng: max 1 max-val - min-val
;								tick-line: max 1 (to-integer rng / 6 / 10) * 10
								tick-line: max 1 to-integer (graph/font/size / (360 / rng)) + .9 
							]
							if negative? max-val [
								max-val: either graph/full-scaling? [
									0
								][
									(to-integer max-val / tick-line) * tick-line
								]
								rng: max 1 max-val - min-val
;								tick-line: max 1 (to-integer rng / 6 / 10) * 10
								tick-line: max 1 to-integer (graph/font/size / (360 / rng)) + .9
							]
							size-text-face/font: graph/font
							legend-width: 0
							foreach [l c v] graph-data [
								size-text-face/text: translate l
								legend-width: max legend-width first size-text size-text-face
							]
							legend-width: (graph-size/x - 10 - (legend-width * (min graph-size/x / 640 graph-size/y / 480))) / (min graph-size/x / 640 graph-size/y / 480)
							chart-width: legend-width - 90

							tick: 360 / rng
							bar-width: chart-width - (10 * (bars-per-group)) / bars
							zero: 440 + (min-val * tick)
							space: chart-width - (bar-width * bars + ((bars-per-group - 1) * 10)) / 2
							beg-line: min-val // tick-line * tick
;print [min-val max-val rng tick-line tick zero beg-line]
							insert tail result compose [
								fill-pen none
								font (graph/font)
								pen (graph/grid-color)
								line (as-pair 40 + space - 5 zero - (max-val * tick)) (as-pair 40 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) zero - (max-val * tick))
								line (as-pair 40 + space - 5 zero - (min-val * tick)) (as-pair 40 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) zero - (min-val * tick))
							]

							repeat n to-integer rng / tick-line + .9 [
								pos: 440 + beg-line - (n - 1 * (tick * tick-line))
								if all [pos <= 440 pos >= (zero - (max-val * tick))] [
									insert tail result compose [
										pen (graph/grid-color)
										line (as-pair 35 pos) (as-pair 40 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) pos)
										fill-pen black
										pen none
										text vectorial (
											size-text-face/text: form-number ((tmp: min-val / tick-line) - (tmp // 1)) * tick-line +  (n - 1.0 * tick-line)
											size-text-face/font: graph/font
											siz: (size-text size-text-face) / 2
											as-pair 5 pos - siz/y
										) (size-text-face/text)
									]
								]
							]

							insert tail result [pen none]
							idx: 0
							pos: 0
							repeat n bars-per-group + 1 [
								insert tail result compose [
										pen (graph/grid-color)
										line (
											pos: 40 + space - 5 + (n - 1 * (bar-groups * bar-width + 10))
											as-pair pos 80
										) (as-pair pos 445)
								]
							]
							
							foreach [l c v] graph-data [
								x: 40 + space + (idx * bar-width)
								idx2: 0
								foreach val v [
									idx2: idx2 + 1
									insert tail result compose [
										pen none
										fill-pen diamond (as-pair x + (bar-width / 2) + 5 zero + 5 - (val * tick / 2)) 0 (bar-width / 2) 0 1 (absolute val * tick / (bar-width - 2)) 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.255
										box (tmp: 5 + as-pair x max zero - (max-val * tick) min 440 zero) (tmp2: 5 + as-pair x + bar-width zero - (val * tick))
										fill-pen (c)
										box (tmp - 5) (tmp2 - 5)
										fill-pen black
										pen none
(
											size-text-face/text: either graph/values-mode = 'percentage [
												rejoin [trim-decimal either val = 0 [0.0][to-decimal (val * (100 / sums/:idx2))] 1 "%"]
											][
												form-number trim-decimal to-decimal form val 2
											]
											size-text-face/font: graph/font
											siz: (size-text size-text-face)
											tpos: as-pair x + (bar-width / 2) - (siz/x / 2) zero - (val * tick) - either negative? val [0][siz/y]
											compose/deep either siz/x > bar-width [
												[
													push [
														translate (tpos/x + (siz/x / 2)) (tpos/y + either negative? val [siz/x / 2][siz/y - (siz/x / 2)])
														rotate 90
														translate (- (tpos/x + (siz/x / 2))) (- (tpos/y + (siz/y / 2)))
														text vectorial (tpos) (size-text-face/text)
													]													
												]
											][
												[text vectorial (tpos) (size-text-face/text)]
											]
)
									]
									x: x + (bar-groups * bar-width + 10)
								]
								idx: idx + 1
								insert tail result compose [
									fill-pen (c)
									box (as-pair legend-width - 30 idx * 2 * 20 + 10) (as-pair legend-width - 10 idx * 2 * 20 + 30)
									fill-pen black
									pen none
									text vectorial (as-pair legend-width idx * 2 * 20 + 10) (translate l)
								]
							]
						]
					]
					horizontal [
						use [sums max-val min-val rng tick bar-width x zero beg-line pos tick-line tmp tmp2 cnt idx idx2 legend-width chart-width][
							max-val: min-val: graph-data/3/1
;							bars: 0
							idx2: 0
							sums: array/initial bars-per-group 0
							foreach [l c v] graph-data [
								idx2: idx2 + 1
								idx: 0
								foreach val v [
									idx: idx + 1
									poke sums idx sums/:idx + val
									max-val: max max-val val
									min-val: min min-val val
									bars: bars + 1
								]
								switch graph/order-mode [
									size-up [
										sort v
									]
									size-down [
										sort/reverse v
									]
									id [
										vals: copy v
										idx: 0
										order: either block? graph/order-blk/1 [
											pick graph/order-blk idx2
										][
											graph/order-blk
										]
										if (length? order) = (length? v) [
											foreach i order [
												idx: idx + 1
												poke v idx pick vals i
											]
										]
comment {
										idx: 0
										foreach i graph/order-blk [
											idx: idx + 1
											change/part at graph-data idx * 3 - 2 copy/part at graph/data i * 3 - 2 3 3
										]
}
									]
								]
							]

							switch graph/order-mode [
								size-up [
									sort/skip/compare graph-data 3 3
								]
								size-down [
									sort/reverse/skip/compare graph-data 3 3
								]
							]

;						print [bars bars-per-group bar-groups]
							rng: max 1E-62 max-val - min-val
							tick-line: max 1 (to-integer rng / 6 / 10) * 10
							if positive? min-val [
								min-val: either graph/full-scaling? [
									0
								][
									(to-integer min-val / tick-line) * tick-line
								]
								rng: max 1 max-val - min-val
								tick-line: max 1 (to-integer rng / 6 / 10) * 10
							]
							if negative? max-val [
								max-val: either graph/full-scaling? [
									0
								][
									(to-integer max-val / tick-line) * tick-line
								]
								rng: max 1 max-val - min-val
								tick-line: max 1 (to-integer rng / 6 / 10) * 10
							]

							size-text-face/font: graph/font
							legend-width: 0
							foreach [l c v] graph-data [
								size-text-face/text: translate l
								legend-width: max legend-width first size-text size-text-face
							]
							legend-width: (graph-size/x - 10 - (legend-width * (min graph-size/x / 640 graph-size/y / 480))) / (min graph-size/x / 640 graph-size/y / 480)
							chart-width: legend-width - 140

							tick: chart-width / rng
							bar-width: 360 - (10 * (bars-per-group)) / bars
							zero: 40 - (min-val * tick)
							space: 360 - (bar-width * bars + ((bars-per-group - 1) * 10)) / 2
							beg-line: min-val // tick-line * tick

							insert tail result compose [
								fill-pen none
								font (graph/font)
								pen (graph/grid-color)
								line (reverse as-pair 80 + space - 5 zero + (max-val * tick)) (reverse as-pair 80 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) zero + (max-val * tick))
								line (reverse as-pair 80 + space - 5 zero + (min-val * tick)) (reverse as-pair 80 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) zero + (min-val * tick))
							]

							repeat n cnt: to-integer rng / tick-line + .9 [
								pos: pos: 40 - beg-line + (n - 1 * (tick * tick-line))
								if all [pos <= (zero + (max-val * tick)) pos >= 40] [
									insert tail result compose [
										pen (graph/grid-color)
										line (reverse as-pair 80 pos) (reverse as-pair 80 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) pos)
										;(reverse as-pair 445 - space + 5 pos)
										fill-pen black
										pen none
										text vectorial (
											size-text-face/text: form-number ((tmp: min-val / tick-line) - (tmp // 1)) * tick-line - (cnt - (to-decimal n) * tick-line)
											size-text-face/font: graph/font
											siz: (size-text size-text-face) * .3
											reverse as-pair 450 pos - siz/y - (either find size-text-face/text #"-" [10][4]) + either size-text-face/text = "0" [4][0]
										) (size-text-face/text)
									]
								]
							]

							insert tail result [pen none]
							idx: 0
							pos: 0
							repeat n bars-per-group + 1 [
								insert tail result compose [
										pen (graph/grid-color)
										line (
											pos: 80 + space - 5 + (n - 1 * (bar-groups * bar-width + 10))
											reverse as-pair pos 35
										) (reverse as-pair pos chart-width + 40)
								]
							]

							foreach [l c v] graph-data [
								x: 80 + space + (idx * bar-width)
								idx2: 0
								foreach val v [
									idx2: idx2 + 1
									insert tail result compose [
										pen none
										fill-pen diamond (reverse as-pair x + (bar-width / 2) + 5 zero + 5 + (val * tick / 2)) 0 (bar-width / 2) 0 (absolute val * tick / (bar-width - 2)) 1 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.128 0.0.0.255
										box (reverse tmp: 5 + as-pair x min zero + (max-val * tick) max 40 zero) (reverse tmp2: 5 + as-pair x + bar-width zero + (val * tick))
										fill-pen (c)
										box (reverse tmp - 5) (reverse tmp2 - 5)
										fill-pen black
										pen none
										text vectorial (
											size-text-face/text: either graph/values-mode = 'percentage [
												rejoin [trim-decimal to-decimal (val * (100 / sums/:idx2)) 1 "%"]
											][
												form-number trim-decimal to-decimal form val 2
											]
											size-text-face/font: graph/font
											siz: (size-text size-text-face)
											if positive? val [siz/x: -8]
											reverse as-pair x + (bar-width / 2) - (siz/y / 2) zero + (val * tick) - siz/x
										) (size-text-face/text)
									]
									x: x + (bar-groups * bar-width + 10)
								]
								idx: idx + 1
								insert tail result compose [
									fill-pen (c)
									box (as-pair legend-width - 30 idx * 2 * 20 + 10) (as-pair legend-width - 10 idx * 2 * 20 + 30)
									fill-pen black
									pen none
									text vectorial (as-pair legend-width idx * 2 * 20 + 10) (translate l)
								]
							]
						]

					]
				]
			]
			]
		]

		if graph/title [
			insert result compose [
;				pen none
;				pen 0.128.0.128
;				box
(
					size-text-face/text: translate graph/title
					size-text-face/font: graph/font
					siz: size-text size-text-face
;					as-pair 320 - (siz/x / 2) - 5 10
				)
;				(as-pair 320 + (siz/x / 2) 10 + siz/y + graph/font/size)
							fill-pen (graph/title-color)
							pen none
				text vectorial (
					as-pair 320 - (siz/x / 2) graph/font/size
				)(translate graph/title)
			]
		]

		insert result compose [
			scale (min graph-size/x / 640 graph-size/y / 480) (min graph-size/x / 640 graph-size/y / 480)
			font (graph/font)
			line-width graph/line-width

		]

		img: make image! graph-size
		either none? graph/back-color [
			img/rgb: 0.0.0.255
		][
			img/rgb: graph/back-color
		]
		draw img result
		all [graph/back-color img/alpha: graph/alpha]
		img
	]
	parse-specs: func [
		[catch]
		gdata [block!]
		/local
			result graph-types var var2 mark
	][
		result: make object! graph-specs
		graph-types: [
			'pie set var2 opt 'torus
		 	| 'bar set var2 ['horizontal | 'vertical | 'stacked]
		]
		parse gdata [
			some [
				(var: var2: none)
				'graph set var graph-types (result/type: var result/subtype: var2)
				| 'back-color set var [tuple! | word!](result/back-color: get var)
				| 'grid-color set var [tuple! | word!] (result/grid-color: get var)
				| 'line-width set var number! (result/line-width: var)
				| 'point-color set var [tuple! | word!] (result/point-color: get var)
				| 'point-size set var number! (result/point-size: var)
				| 'point-shape set var ['square | 'circle | 'diamond | 'plus | 'triangle] (result/point-shape: var)
				| 'graph-font set var object! (result/font: var)
				| 'font-size set var integer! (result/font-size: var)
				| 'title opt [set var [tuple! | word!] (result/title-color: get var)] set var [string! | word!] (result/title: get 'var)
				| 'x-label set var [string! | word!] (result/x-label: get 'var)
				| 'y-label set var [string! | word!] (result/y-label: get 'var)
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
			image: draw-graph graph size
			show self
		]
	]

	redraw: has [/no-show] [
		graph: parse-specs data
		image: draw-graph graph size
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

	feel: make default-feel [
		redraw: func [fac act pos][
			if act = 'show [
				fac/redraw/no-show
			]
		]
	]

	init:	make function! [] [
		either block? data [
		redraw/no-show
	][
			throw make error! "chart widget: no data block supplied"
		]

	]
]
