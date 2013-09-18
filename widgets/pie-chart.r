pie-chart: make rebface [
	feel:	make default-feel [
		redraw: make function! [face act pos /local plot total angle pie-size label-offset label-distance label-size] [
			if act = 'show [
				clear plot: skip last face/effect 4
				total: face/degrees
				pie-size: face/size / 2 - 1x1 - as-pair face/explode face/explode
				label-distance: pie-size * .75
				foreach [label color val] face/data [
					angle: 360 * val / face/sum
					insert plot reduce [
						'fill-pen color
						'arc face/size / 2 + as-pair face/explode * (cosine (total + (angle / 2))) - 1 face/explode * (sine (total + (angle / 2))) - 1 pie-size total angle
						'closed
					]
					;	insert text label at tail so it appears on top of pie slices
					unless face/no-label? [
						label-size: size-text make rebface [text: label font: default-font]
						label-offset: as-pair label-distance/x * (cosine (total + (angle / 2))) face/explode + label-distance/y * (sine (total + (angle / 2)))
						;	adjust text offset
						label-offset/x: label-offset/x - (label-size/x / 2)
						label-offset/y: label-offset/y - (label-size/y / 2)
						insert tail plot reduce ['text 'anti-aliased form label face/size / 2 + label-offset]
					]
					total: total + angle
					if total >= 360 [total: total - 360]
				]
			]
		]
	]
	effect:		[draw [pen black font default-font]]
	sum:		0		;	sum of values
	explode:	0		;	explode distance
	degrees:	270		;	default start angle (note that 0 is horizontal)
	no-label?:	false	;	show labels?
	init: make function! [] [
		explode: any [select options 'explode 0]
		no-label?: find options [no-label]
		if select options 'start [
			degrees: 270 + select options 'start
			if degrees >= 360 [degrees: degrees - 360]
			if degrees < 0 [degrees: degrees + 360]
		]
		foreach [label color val] data [sum: sum + val]
	]
]