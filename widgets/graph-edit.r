graph-edit: make rebface [
	size:	50x5
	text:	""
	effect: copy [draw none]
	speed: 12
	gravity: 96
	rforce-max: 512
	throttle: 0.005

	default-color: leaf * 1.5
	box-size: 90x50
	node-radius: box-size / 2
	edge-length: 1.3 * max box-size/x box-size/y

	origin-mass: 1
	origin-pos: none

	selected-node: none
	origin-edges: []

	dx:
	dy:
	d2:
	d: none

	picked: none

	mouse-pos: none
	mouse-down?: false

	calc-distance: func [src dst][
		dx: src/x - dst/x
		dy: src/y - dst/y
		d2: (dx * dx) + (dy * dy)
		d: square-root d2
	]

	clear-edges: does [
		foreach f pane [
			f/edges: none
			f/neighbours: 0
		]
		update/force
	]

	clear-nodes: does [
		clear pane
		update/force
	]

	add-node: func [
		idx [integer!]
		col [tuple! none!]
		label [string!]
		oft [pair!]
		/origin
			origin-weight
		/local fnt
	][
		fnt: self/font
		insert tail pane make rebface [
			id: idx
			font: fnt
			text: label
			offset: oft
			pos: reduce ['x oft/x 'y oft/y]
			mass: 2
			neighbours: 0
			force: copy [x 0 y 0]
			edges: none
			size: to-pair node-radius * 2
			color: any [col default-color]
			effect: [merge alphamul 128]
			edge: make default-edge [
				size: 2x2
			]
			feel: make default-feel [
				engage: func [f a e][
					switch a [
						down [
							mouse-pos: e/offset
							selected-node: f/id
							mouse-down?: true
						]
						alt-up [
							either picked [
								either e/control [
									rem-edge picked f
								][
									add-edge picked f edge-length
								]
								picked/edge/color: default-edge/color
								picked: none

							][
								f/edge/color: white
								picked: f
							]
							f/parent-face/update/force
						]
					]

					if all [mouse-down? find [over away] a][
						f/offset: confine f/offset + e/offset - mouse-pos f/size 0x0 f/parent-face/size
						f/pos/x: f/offset/x
						f/pos/y: f/offset/y
						if all [e/control f/edges] [
							origin-pos: confine origin-pos + e/offset - mouse-pos f/size 0x0 f/parent-face/size
						]
					]
					if e/type = 'up [
						selected-node: none
						mouse-down?: false
					]
				]
			]
		]
		if origin [
			insert tail origin-edges reduce [idx origin-weight]
		]
		last pane
	]

	add-edge: func [
		node-1
		node-2
		weight
	][
		if node-1 = node-2 [exit]
		unless node-1/edges [node-1/edges: copy []]
		unless node-2/edges [node-2/edges: copy []]
		if any [
			find/skip node-1/edges node-2/id 2
			find/skip node-2/edges node-1/id 2
		][
			exit
		]
		insert tail node-1/edges reduce [node-2/id weight]
		node-1/neighbours: node-1/neighbours + 1
		node-2/neighbours: node-2/neighbours + 1
	]

	rem-edge: func [
		node-1
		node-2
		/local tmp
	][
		if node-1 = node-2 [exit]
		either all [node-1/edges tmp: find/skip node-1/edges node-2/id 2] [
			remove/part tmp 2
		][
			if all [node-2/edges tmp: find/skip node-2/edges node-1/id 2][
				remove/part tmp 2
			]
		]
		if tmp [
			if all [node-1/edges empty? node-1/edges] [node-1/edges: none]
			if all [node-2/edges empty? node-2/edges] [node-2/edges: none]
			node-1/neighbours: node-1/neighbours - 1
			node-2/neighbours: node-2/neighbours - 1
		]
	]

	origin-force: func [
		node
		/local
			weight
			a-force
			r-force
	][
		either select/skip origin-edges node/id 2 [
			if node/id <> selected-node [
				weight: first select/skip origin-edges node/id 2
				a-force: (d - weight) / weight
				if d <> 0 [
					node/force/x: node/force/x + (a-force * (dx / d))
					node/force/y: node/force/y + (a-force * (dy / d))
				]
			]
		][
			if all [node/id <> selected-node d2 <> 0] [
				r-force: gravity * node/mass * (origin-mass / d2)
				df: rforce-max - d
				if df > 0 [
					r-force: r-force * (log-e df)
				]

				if all [d <> 0 r-force < 1024][
					node/force/x: node/force/x - (r-force * (dx / d))
					node/force/y: node/force/y - (r-force * (dy / d))
				]
			]
		]
	]

	a-force: func [
		node-1
		node-2
		/local
			weight
			a-force
	][
		weight: first select/skip node-1/edges node-2/id 2
		weight: weight + (3 * (node-1/neighbours + node-2/neighbours))

		if weight [
			a-force: (d - weight) / weight

			if d <> 0 [
				if node-1/id <> selected-node [
					node-1/force/x: node-1/force/x - (a-force * (dx / d))
					node-1/force/y: node-1/force/y - (a-force * (dy / d))
				]
				if node-2/id <> selected-node [
					node-2/force/x: node-2/force/x + (a-force * (dx / d))
					node-2/force/y: node-2/force/y + (a-force * (dy / d))
				]
			]
		]
	]

	r-force: func [
		node-1
		node-2
		/local r-force df
	][
		if d2 <> 0 [
			r-force: gravity * node-1/mass * (node-2/mass / d2)
			df: rforce-max - d
			if df > 0 [
				r-force: r-force * (log-e df)
			]
			if all [d <> 0 r-force < 1024][
				node-1/force/x: node-1/force/x + (r-force * (dx / d))
				node-1/force/y: node-1/force/y + (r-force * (dy / d))
			]
		]
	]

	update: has [
		node-i node-j refresh?
		/force
	][
		refresh?: false
		effect/draw: copy [pen black line-width 3 arrow 1x2]
		repeat i length? pane [
			node-i: pane/:i
			repeat j length? pane [
				if i <> j [
					node-j: pane/:j

					calc-distance node-i/pos node-j/pos

					if all [
						node-i/edges
						not empty? node-i/edges
						select/skip node-i/edges node-j/id 2
					][
						a-force node-i node-j
						insert tail effect/draw compose [
							line (node-i/offset + node-radius) (node-j/offset + node-radius)
						]
					]

					if i <> selected-node [
						r-force node-i node-j
					]
				]
			]
			if block? node-i/edges [
				calc-distance origin-pos node-i/pos
				origin-force node-i
				if any [
					node-i/force/x > throttle
					node-i/force/y > throttle
				][
					refresh?: true
				]

				node-i/force/x:	node-i/force/x * speed
				node-i/force/y:	node-i/force/y * speed

				node-i/pos/x: node-i/pos/x + node-i/force/x
				node-i/pos/y: node-i/pos/y + node-i/force/y
				node-i/force/x: 0
				node-i/force/y: 0
				node-i/offset: as-pair node-i/pos/x node-i/pos/y

				node-i/offset: confine node-i/offset node-i/size 0x0 size
			]
		]
		if any [force selected-node refresh?][
			show self
		]
	]

	get-graph-data: has [
		result tmp rslt
	][
		result: copy []
		foreach node pane [
			either all [node/edges not empty? node/edges] [
				if not find/skip result node/id 2 [
					insert tail result copy/deep reduce [node/id [[][]]]
				]
				foreach [id w] node/edges [
					foreach n pane [
						if n/id = id [
							rslt: select/skip result node/id 2
							insert tail second last rslt reduce n/id
							either tmp: select/skip result n/id 2 [
								insert tail tmp/1/1 reduce node/id
							][
								insert tail result compose/deep [(n/id) [[(node/id)] []]]
							]
							break
						]
					]
				]
			][
				unless node/edges [
					if not find/skip result node/id 2 [
						insert tail result copy/deep reduce [node/id [[][]]]
					]
				]
			]
		]
		result
	]

	set-graph-data: func [
		blk [block!]
	][
		clear-edges
		foreach [id nodes] blk [
			foreach node pane [
				if node/id = id [
					foreach id2 nodes/2 [
						foreach n2 pane [
							if n2/id = id2 [
								add-edge node n2 edge-length
								break
							]
						]
					]
				]
			]
		]
		update/force
	]

	;-- Studd added by Robert / Ladislav
	vertex-number?: func [
		{find the vertex number for the given vertex}
		vertex
		graph [block!]
	] [
		(index? find/skip graph vertex 2) + 1 / 2
	]

	cyclic?: func [
		{
			Returns FALSE or the vertex number where cycle was found.

			Recursive implementation, not suitable for big graphs (> 6000 vertices)
			due to the stack limitation.

			Using depth-first search
		}
		/cycle {return a cycle}
		/local graph outbound-count eliminate-leaf order visited
	] [
		graph: get-graph-data

		order: (length? graph) / 2

		; for every vertex store the vertex's outbound count
		outbound-count: make block! order
		foreach [vertex adjacent] graph [
			append outbound-count length? second adjacent
		]

		eliminate-leaf: func [vertex-number [integer!]] [
			if outbound-count/:vertex-number > 0 [exit]
			foreach inbound-vertex first pick graph 2 * vertex-number [
				inbound-vertex: vertex-number? inbound-vertex graph
				poke outbound-count inbound-vertex outbound-count/:inbound-vertex - 1
				eliminate-leaf inbound-vertex
			]
		]

		; traverse the whole graph
		foreach [vertex adjacent] graph [
			if empty? second adjacent [eliminate-leaf vertex-number? vertex graph]
		]

		repeat i order [
			if outbound-count/:i > 0 [
				return either cycle [
					; find a cycle
					cycle: make block! 0
					visited: head insert/dup copy [] false order
					while [
						insert tail cycle pick graph 2 * i - 1
						not visited/:i
					] [
						poke visited i true
						i: foreach outbound-vertex second pick graph 2 * i [
							outbound-vertex: vertex-number? outbound-vertex
							if outbound-count/:outbound-vertex > 0 [
								break/return outbound-vertex
							]
						]
					]
					find cycle last cycle
				] [i]
			]
		]

		false
	]

	component: func [
	    {
			Identify all vertices of a component containing the given VERTEX.

			Recursive implementation, not suitable for big graphs (> 6000 vertices).
		}
	    vertex
	    component-id 				{component id all vertices of the component shall have}
	    components [block!] {block containing component ids assigned to graph vertices}
	    /local graph
	] [
		graph: get-graph-data

		vertex: vertex-number? vertex graph
	    if component-id = components/:vertex [return components]
	  	; unidentified vertex found
	    poke components vertex component-id
	    foreach inbound-vertex first pick graph 2 * vertex [
	        component inbound-vertex component-id components graph
	    ]
	    foreach outbound-vertex second pick graph 2 * vertex [
	    	component outbound-vertex component-id components graph
	    ]
	    components
	]

	connected?: func [
		{Returns TRUE if the given graph is connected, returns FALSE otherwise}
		/local graph components order
	] [
		graph: get-graph-data

		if empty? graph [return true]
		order: (length? graph) / 2
		components: head insert/dup make block! 0 none order
		component graph/1 1 components graph
		none? find components none
	]

	topological-sort: func [
		{
			Returns a topological sort for acyclic graph;
			or none if a cycle was found. Vertices on the same level or enclosed in a block.
		}
		/local graph inbound-count order result level level' unordered new-degree
	] [
		graph: get-graph-data

		order: (length? graph) / 2
		unordered: order

		; for every vertex store the vertex's inbound count
		inbound-count: make block! order
		foreach [vertex adjacent] graph [
			append inbound-count length? first adjacent
		]

		result: make block! 0

		; the initial level
		level: make block! 0
		repeat vertex order [
			if inbound-count/:vertex = 0 [append level vertex]
		]

		while [not empty? level] [
			; emit vertices
			level': make block! 0
			foreach vertex level [append level' pick graph 2 * vertex - 1]
			append/only result level'

			; eliminate vertices
			unordered: unordered - length? level

			; eliminate edges and collect the new level
			level': make block! 0
			foreach vertex level [
				foreach outbound-vertex second pick graph 2 * vertex [
					outbound-vertex: vertex-number? outbound-vertex graph
					new-degree: inbound-count/:outbound-vertex - 1
					poke inbound-count outbound-vertex new-degree
					if new-degree = 0 [append level' outbound-vertex]
				]
			]
			level: level'
		]

		if unordered = 0 [result]
	]

	tree?: func [/upward /local graph tree][
		; check if graph is a tree, returns positive ID for root/leafe or the negative node ID violating the property
		; downward = 1 root, several leafs
		; upward	 = serveral roots, 1 leaf

		graph: get-graph-data
		tree: false
		either upward
			[
				; check for 1 leaf
				foreach [id edges] graph [
					; check outbound edges
					if empty? edges/2 [
						either tree
							[return -1 * id]
							[tree: id]
					]
				]
			]
			[
				; check for 1 root
				foreach [id edges] graph [
					; check outbound edges
					if empty? edges/1 [
						either tree
							[return -1 * id]
							[tree: id]
					]
				]
			]

		return tree
	]

	get-ids: does [extract get-graph-data 2]

	feel: make default-feel [
		engage: func [f a e][
			if a = 'time [
				f/update
			]
		]
	]

	set-nodes: make function! [
		data [block!]
		/no-show
		/local
			pos mode label spc idx col mark
	][
		pos: 0x0
		spc: 10x10
		mode: 'across
		parse data [
			some [
				set idx integer! set label string! mark: (
					parse copy mark [set col [word! | tuple!] (set/any 'col get/any :col)]
					either any [not value? 'col not tuple? :col][col: none][mark: next mark]
					add-node/origin idx col label pos edge-length
					col: none
					either mode = 'across [
						pos/x: pos/x + box-size/x + spc/x
					][
						pos/y: pos/y + box-size/y + spc/y
					]
				) :mark
				| 'space set spc pair!
				| 'across (mode: 'across)
				| 'below (mode: 'below)
				| 'return (
					either mode = 'across [
						pos/x: 0
						pos/y: pos/y + box-size/y + spc/y
					][
						pos/y: 0
						pos/x: pos/x + box-size/x + spc/x
					]
				)
				| 'at set pos pair!
			]
		]
		unless no-show [show self]
	]

	init:	make function! [][
		pane: copy []
		font: make default-font [
			align: 'center
			color: white
		]
		if block? data [
			set-nodes/no-show data
		]
		unless empty? pane [
			size: second span? pane
		]
		origin-pos: size / 2
		rate: 50
	]
]
