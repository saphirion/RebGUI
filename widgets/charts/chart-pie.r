REBOL[]

use [tmp tmp2 img siz idx data-labels pos arc-360? tmp-v tmp-draw result][
	result: copy []
	
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
			strip-zero trim-decimal to-decimal (v / tmp2) 2
		]
		size-text-face/font: graph/font
		siz: (size-text size-text-face) / 2
		tmp-v: either arc-360? [
			360
		][
			v
		]
		pos: as-pair 220 - siz/x + (195 + siz/x * cosine (tmp + (tmp-v / 2))) 260 - siz/y + (195 + siz/y * sine (tmp + (tmp-v / 2)))
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
						arc 220x260 180x180 (tmp) (v) closed
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
			fill-pen black
			pen none
			text vectorial (p) (t)
		]
		if arc-360? [break]
	]
	result
]
