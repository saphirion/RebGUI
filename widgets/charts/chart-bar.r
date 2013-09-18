REBOL[]

use [bars-per-group bar-groups bars space siz result][
	result: copy []

	bars: 0

	forall graph-data [if (index? graph-data) // 3 = 0 [graph-data/1: to-block graph-data/1]]

	if all [graph/order-mode = 'id integer? graph/order-blk/1][
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
			either graph-data/3 = [0][
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
				tick-line: max 1 to-integer (graph/font/size / (360 / rng)) + 0.9
				if positive? min-val [
					min-val: either graph/full-scaling? [
						0
					][
						(to-integer (either integer? min-val [min-val - 1][min-val]) / tick-line) * tick-line
					]
					rng: max 1 max-val - min-val
					tick-line: max 1 to-integer (graph/font/size / (360 / rng)) + 0.9
				]
				if negative? max-val [
					max-val: either graph/full-scaling? [
						0
					][
						(to-integer max-val / tick-line) * tick-line
					]
					rng: max 1 max-val - min-val
					tick-line: max 1 to-integer (graph/font/size / (360 / rng)) + 0.9
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
				insert tail result compose [
					fill-pen none
					font (graph/font)
					pen (graph/grid-color)
					line (as-pair 40 + space - 5 zero - (max-val * tick)) (as-pair 40 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) zero - (max-val * tick))
					line (as-pair 40 + space - 5 zero - (min-val * tick)) (as-pair 40 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) zero - (min-val * tick))
				]
				repeat n to-integer rng / tick-line + 0.9 [
					pos: 440 + beg-line - (n - 1 * (tick * tick-line))
					if all [pos <= 440 pos >= (zero - (max-val * tick))][
						insert tail result compose [
							pen (graph/grid-color)
							line (as-pair 35 pos) (as-pair 40 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) pos)
							fill-pen black
							pen none
							text vectorial (
								size-text-face/text: form-number ((tmp: min-val / tick-line) - (tmp // 1)) * tick-line + (n - 1.0 * tick-line)
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
									strip-zero trim-decimal to-decimal form val 2
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
				repeat n cnt: to-integer rng / tick-line + 0.9 [
					pos: pos: 40 - beg-line + (n - 1 * (tick * tick-line))
					if all [pos <= (zero + (max-val * tick)) pos >= 40][
						insert tail result compose [
							pen (graph/grid-color)
							line (reverse as-pair 80 pos) (reverse as-pair 80 + space - 5 + (bars-per-group * (bar-groups * bar-width + 10)) pos)
							fill-pen black
							pen none
							text vectorial (
								size-text-face/text: form-number ((tmp: min-val / tick-line) - (tmp // 1)) * tick-line - (cnt - (to-decimal n) * tick-line)
								size-text-face/font: graph/font
								siz: (size-text size-text-face) * 0.3
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
									strip-zero trim-decimal to-decimal form val 2
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
	result
]
