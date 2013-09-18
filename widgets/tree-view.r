REBOL [
	title: "tree-view"
	author: rsmolak@gmail.com
	version: 0.0.5
]

tree-images: reduce [

'node-open load to-binary decompress 64#{
eJyV0/0z2wccwPHP9xsV1EPiIbZISXO0RSyXiWgeKsxDpFe0RbOSLoyRRCQxdKth
4ehtKaYtEjSkylU2ruPww7azsCt5EBqbedjW6abXrvul5263rivfxZ+w171/+Hx+
+Pz4EYoyTnKKAyEQ/gbA3F59j/05ge30Ytst2MNubOsGttmIrX+MrV/B1hqxtXps
rQ57oMJWVNiyEnPKMYcMc5RhdhlmL8fs7uE9zF66v9Wxv9G2v3p53yHfd8j2Nq7t
ORR7dvmevXzPJntlV/y7VPXyp4GXDvULm+aFVf3XStvu75O7D8d2Hdrnv44/nW94
OtfwZO6jJ5banRnJb7P1v0xrfh4/v/WdftOcu2k+uzksWL9XsX5H8IPp1OpQhmus
wnXnjGso22VKdQ0muQb4D0wZK1PNK0bBipG/fOuU05jiNCY7+/nOPu7SFzVLvYkO
A9vey7f38uwGvs3Asxm4Nj3HapJYDTyrnmvVn7T2cBe/HVwcUS0akhe7Excm2xf0
/IXuhPtd7Ps3WbPDH862M7/Ri79uY850ZMx0pM9cjZ1upU9N9EyN3ZxqZU6OdU/o
0u51Kca71GZ93aiueLRZYDJ9NtgkNjbm39JE9jXm99Zy9DWcnvr8LuWJa1XZuuo8
XdW5T1Xpn1RmactE2lKuVhrZoBJfURV9kBd1WcKuvRhZc4Fa/XaCpup9jTRTXXZW
XZylkgor3ZSKSqW8UlGqLMmpUCoVF3lyWZlMJisvLy/LZpQUpBWnRxVlp1ySSiVn
eJLMOImQXlhQUCggF6QmiIXMXGG8SJT+FoOcIuAmvcng0am82ChOTATnOCXxeDib
Hc+OYyRQSazoIyxqaDydzggLiqaRoqmUaOrrJ0jEqGPHaBERtBBCOIUcFuAXigMS
DkJwEOwOhWAEgnAQhECgl3cgCkQ8nogDIgABhxBwQECBABCAQgACAQD+AH4o+AH4
oqgvCr4Ah1E4DOAD4A3ghaJeAHgPDzyAJ4J4InDIHYAHAA4B1B0gKADiBgcsFgv8
H0f/8XAfPgf6wXLwE8lez+CRd4v47jljkxfxR1ezJQUJUVKP0nKHrXpa3nLeaYMm
K4VTnSd6F6d2kpv6P2fdnr8h9I2QytrM1Z0mShKDzO3chowhNt//epp1gdBOYgVM
ylldRRDX7j/iff7649AYaafHXI2mnYIGzu9SmNs5g7rOvhhlpNAT9Ssk/IGMkML7
U9/xHdgxfOl6LeZS/c5orqiDxGE9ajotseEdi7GFPkPm1hZtwtXgEVcTscQhwIeZ
NzikVB3X8FURvTqT2s9NI+se24aDO2i3n71RGRs2R+XXKXano+8e8smpK2Uemb2w
atEC7z8YC5PbDQQAAA==
}

'node-closed load to-binary decompress 64#{
eJx90/lP03cYB/Dn25YeCFgo4jhXsyrHZoDCCrSI1AoIA5SwzYJliByt0ELLIRNL
hw0kgK4IxAwKugwYFJXEyIa6oJYz0AJylDkEjxWZbGZMGY0o0M/KP7BXnrzzfpLn
1ycqOjI4JM0BHOAtANpmRmgLmSbRy2ZkVKOn36AnSvS4Ds2Wo1kFmi1FhmI0U4Cm
5Wi6GE1J0WQuGhejMRHSZyO9JbOQToR0QqSzlEykyzDP15h/u2B+VG0eyzHrs816
0ZY+e2tUtLnxblOXvbGx/n5M9l4vXTdq1kfy3o5KTZOqNZNpdfX1m/n2f552rjxu
Wxkq+POvV0v3ZUt3pS9eLBqNxmfPnj/pkSzclS/0FCx08ed78ue7Eufm5h/dKvm1
O3/WMDN7M8/QozS08ma6iqZbIqdu5DzsVk5MjE+MT06MTYw3hY4O9Y1qvx9t5I02
cEaGR0YGtEODwwMP7vVr5H0P+rSthb21nJ6mvJ/Vhd2d1Tfbq65/m369gnOtQ3Ot
MqqzraK94ki7POjHqtS28mMtLa1X5byrUr8rjWVNMra6Ua0u4jbKjzecib58ll93
oabunKC2tv5SUXRNfqxKdUlVKrkojaqWJVSeV1RKeJXi+DJZkuJMQWlG2LmshLNF
suLCnMKiwsJEv3ypSJqfL81IysvNyTspyJVk5sb6SnIlEvFpSeoJcU6GOFWQIxZn
C9Oz41mnRVkikUgoFGYmxmVG+ZxKCPsqjp2SmpoSwUzheqdwXAWHAwUHGQK284nk
ZD7H48ugD784wkzghR71t4nfT4j1J8UEecX4W0ezA7nebuGswAOB/hw/T3Ywi/0x
I4ThEsxwD/L0YLE+Zfm4s7wYTIYrk+7EpDv6f+Tqt8fF19l+v4u9D93Z28tzn6uT
q53tbjzsxoGTBQ52WQYDRxw4WhKAhgMaBg5ksgMO7IkkewzsAagWeIyKAyoGVICd
GOwEsLMAsLWgWNtiYAtgg+FsMLAB2IHBDgBrAIoVgYLHUwDIACQSkQRAJOCJGEYE
sAIgAOAAMNim1Wrhf+15R7BcmuCT7WX7J8LJCF5RbpCGHzb74Gl2zel7zxMI/nfI
6hlcWcTejvvkX1r80i4HKAa/nsuixO6qV/gk9xrJBheXUPU6tPxxURtQ8pyaRucq
rSjMlbLfDaSx8IMxa5oS3mBMcwjB1OCoEWppEWIxfyFmyWEfM2Iy3GpxqKyi+8Bx
alliRJVnWCTHuHaLh+Hd2zO81cm+qisBxXeW02i3W7VcpwrGqoFI/i6spE4zlT4z
7fZZ8m2cxjiS6OIVV93QGOBJUTqeIsz1/eCsdfs8qTd8dqDl5RzN46TmDT5c18lU
EJRT+PKOoz9xNzdfH9ZI79UrVpaPUfv6seCYxQ+c+JkqD182edm236Sr+ffvgk36
Ib4vHTj/AWSrv6MwBAAA
}

'bar load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M7AwNACAv9HwSgYkUDxJwsjMBcw6IAIUJ5g4NBjYOSQ4VBg
ONjMIaxlk1Gw8HA7i7TTnBUBSke7mXWT9qwofHykT06+iWdngcrJBgYGawBY6g6k
UQMAAA==
}

'item load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M7A8P///39///39+/cPEPz+8/vX71+/foLAj58/fvz49vXb
VyD48vXr56+fP33+/PHzp4+fPrz/8P7d+3dv3715/ebNqzevX71+9fLVqxevXjx7
8fzZ8+dPXzx/+vzZ02dPnzx9+vjpk0dPHj98/OjBo4dAdB+IHj4AontA9OA+EN19
cPf2vTu37t65eec2CN2+dQOIbt28CUQ3b16/dfP6zRvXbl6/euPalWtXL1+9cgmI
rly+eOXShUsXzl28cPbi+bPnz54+d+bk2dMnzpw4fvLQ/sM7t+/aunXrxg0b165Z
t2bNmtWrVi9csHDBvAXz5y+YPXv2tGnTJk2a1NvT297W0dba3trS1tzcXFtTW1NT
U1VZXVVZVV5WXlZWXlpaVlRUVAAE+YVZWVmZmZlpaWmpKWkpKSnJyclJSUkJCQlx
MXFRQBAZFRERER4eER4WHhYWFhISEhwcHBQUFBAQ6B/g7wcCvkDg4+Pj7e3t6enl
4eHh7u7u6urq4uLi7Ozs5OTk4OBgZ2dnbW1jbW1tYWlhbm5uZmampaWlqampoaGh
rqEOBGpqaqqqqvLy8nJycrJysjIyMtLS0lJSUhISEgICAry8vDw8PNzc3Ozs7Kys
rMzMzAwMDAcOHGAYBYSA4k8WRgaGeQw6IA4oTzhwHGGw5ZTx2PDggK6PicaFBY1H
utpNMu4ccGzmEm1mmi9zMOIDhwgng4gGg+bDE8JqbhxSE4tavebqujUwfJx4jHdK
L5ut1wQGVU+vZk+7vjsnJzzkEpI2MViY9IRLSdPCaElFx+Ksq9qeMx7IaLRyMsjk
HTN46PGhQ0Qj5bQXo+Slxf4LnMqFzgo4NruvVXuapvHqw0MuKc0FNo4rJiTe3y+k
GSXj0do/W9vl3ymWpsenRDXM2dfVNCV7z1Vy2eZxsyvwlLCW56Qlsb4GCgzWABQG
aC/nAwAA
}

'corner load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M7AwNACAv9HwSgYkUDxJwsjMBcw6IAIUJ5g4NBjYOSQ4VBg
ONjMIaxlk1Gw8HA7i7TTnBUBSke7mXmzdE5cVDrWr+DcJeO5acmBBgYGawBNgQ5F
UQMAAA==
}

'tee load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M7AwNACAv9HwSgYkUDxJwsjMBcw6IAIUJ5g4DBiYOSQ4VBg
ONjMIaxlk1Gw8HA7i7TTnBUBSke7mXmzdE5cVHJrk3eu4uEsVPFsV/Nn4uBgsAYA
b4gMtVUDAAA=
}


'corner-minus load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M4ABi0g8H8UjIKRBxR/sjAyMDAy6IAyAihPMHB4MzBzyEg4
MBxs5hDWsskoWHi4nUnJa8qOgAMN3RLsJj4Zho+P9nJYV7GcLGBomKxuKhazMzDF
bRJLbFKLZcCz413C6nZ3Tm5efn6+HTMTgzUApEwXJW4DAAA=
}

'corner-plus load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M4ABi0g8H8UjIKRBxR/sjAyMDAy6IAyAihPMHD4MzBzyEg4
MBxs5hDWsskoWHi4nUnJa8qOgAMN3RLsJj4ZH5UYeqQFy2Q+fEzyaFNhXPEnY0Pq
wUZl76w1HYHPPJuUje+1WBY+OjzfoZlLVstEgcEaADGTGYVyAwAA
}

'tee-minus load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M4ABi0g8H8UjIKRBxR/sjAyMDAy6IAyAihPMHD4MjBzyEg4
MBxs5hDWsskoWHi4nUnJa8qOgAMN3RLsJj4Zho+P9nJYV7GcLGBomKxuKhazMzDF
bRJLbFKLZcCz413C6nZ3Vk5QOz9fu/EdDweDNQDSCBfOcAMAAA==
}

'tee-plus load to-binary decompress 64#{
eJxz93SzsEwUYhBi+M4ABi0g8H8UjIKRBxR/sjAyMDAy6IAyAihPMHAEMTBzyEg4
MBxs5hDWsskoWHi4nUnJa8qOgAMN3RLsJj4ZH5UYeqQFy2Q+fEzyaFNhXPEnY0Pq
wUZl76w1HYHPPJuUje+1WBY+Ojyfq5xJ9tekF+cbGBisAY7hHIN1AwAA
}

]

tree-view: make rebface [

	tree-vslider-spec: [
		size: (as-pair 16 root-face/size/y) ; - (2 * root-face/edge/size)
		options: [arrows]
		action: does [
			tree-pane/scroll/y: to-integer rows * data
			show tree-pane
		]
	]
	
	tree-hslider-spec: [
		size: (as-pair root-face/size/x - 15 16)
		options: [arrows]
		action: func [face] [
			tree-pane/scroll/x: to-integer root-face/hslider - face/size/x + 2 * data
			show tree-pane
		]
	]

	tree-pane-spec: [
		type: 'tree-pane
		scroll: 0x0
		size: (as-pair root-face/size/x - root-face/tree-vslider/size/x  root-face/size/y) - (root-face/edge/size * 2)
		color: colors/edit
;		edge: default-edge
		feel: make default-feel [
			redraw: func [f a][
				if a = 'show [
					f/tmp-index: 0
				]
			]
	
			engage: func [f a e /local rows sld][
			    switch a [
		        	up [f/action f]
		        	scroll-line [
						rows: length? f/data
						sld: tree-vslider
						if any [
							f/scroll/y > 0
							rows > to-integer (f/size/y / f/tree-line/size/y + .5)
						][
							f/scroll/y: max 0 min rows f/scroll/y + (e/offset/y / (abs e/offset/y))
							sld/data: f/scroll/y / rows
							scroll?: true
							show [f sld]
							scroll?: false
						]
		        	]
		        ]
		    ]
		]
	
		focus-action: :on-focus
		unfocus-action: :on-unfocus
		
		ln: 0
		last-ln: 0
		over?: false
		
		x-mouse-pos: 0
		tree-ref: none
		exit-action: none
		tree-path: none


		action:	func [face /local act act1 act2 loc-act-result plus-minus-click] [
			if tree-ref [
				
	;				probe x-mouse-pos
	;				probe tree-ref/3/1
				
				ln: 0
				
				;global action
				root-face/action root-face
	
				loc-act-result: true
					
				plus-minus-click: all [x-mouse-pos > tree-ref/3/1 x-mouse-pos < (tree-ref/3/1 + 18)]
					
				unless plus-minus-click [
					;exit-action
					if exit-action [
						do bind exit-action in root-face 'self
						exit-action: none
					]
	
					;local action
					either act: select tree-ref/2 'action [
						if parse/all act [set act1 block! set act2 block!] [
							exit-action: act2
							act: act1
						]
	
						set/any 'loc-act-result do func [] bind act in root-face 'self
	
						if unset? get/any 'loc-act-result [
							loc-act-result: false
						]
					][
						;no action block - do only 'alt-action' block
						root-face/alt-action root-face
						exit
					]
				]
			]					
	
			either all [tree-ref tree-ref/1] [
				if any [loc-act-result plus-minus-click] [
					either tree-ref/1/2 = 'on [
						if plus-minus-click [
							remove at tree-ref/1 2
							remove at tree-ref/2 2
						] 
					][
						insert next tree-ref/1 'on
						insert next tree-ref/2 'on
					]
					
					unless plus-minus-click [
						picked-line: last-ln
						picked: tree-ref/2
					]
	
					data: parse-tree root-face/data
					check-sliders
					show face/parent-face
				]
			][
				if loc-act-result [
					picked-line: last-ln
					picked: tree-ref/2
					data: parse-tree root-face/data
				]
			]
		] ; END action
	
		parse-tree: func [
			data [block!]
			/level
				lvl [integer!]
			/local act? sc blk w n c gauge g-color lines stk x str tree-rule mark on? beg tsiz goft tmp tp? pck mark-stack l last-lines over-box idx act-rule cont
		][
			lines: copy []
			mark-stack: copy []
			stk: copy []
			x: 54
			tree-path: copy []
			pck: either picked [
				picked/1
			][
				none ;data/1
			]
			tp?: true
			l: 1
			idx: 0
			root-face/hslider: 0
	;			act?: false
			tree-rule: [
				some [
					beg: set str string! (
						idx: idx + 1
						c: w: gauge: sc: blk: none
						on?: false
						if same? pck str [
							picked-line: idx
							insert tail tree-path str
							tp?: false
						]
	
					) any [
						'image set w  [word! | image!]
						| opt 'gauge set n number! set c opt tuple! (gauge: n g-color: c)
						| 'on (on?: true)
						| 'action block! ; (act?: true)
						| 'shortcut set sc block!
						| set blk block! 
					] mark: (
						either all [
							level
							lvl >= l
						][
							if all [
								blk
								not find beg 'on
							][
								on?: true
								insert next beg 'on
								mark: next mark
							]
						][
							if all [level on? blk] [
								on?: false
								remove find beg 'on
								mark: back mark
							]
						]
						over-box: reduce [x 0]
						insert/only tail lines compose/deep [
							[
								(compose stk)
								image (as-pair x 0) (
									either all [blk not empty? blk] [
										either empty? mark [
											either on? [
												'tree-images/corner-minus
											][
												'tree-images/corner-plus
											]
										][	
											either on? [
												insert tail stk compose [image (to-paren (compose [as-pair (x) 0])) tree-images/bar]
												'tree-images/tee-minus
											][
												'tree-images/tee-plus
											]
										]
									][
										either empty? mark [
											'tree-images/corner
										][
											'tree-images/tee
										]
									]
								)
							][
								image (as-pair x + 18 0) (
									either w [
										to-lit-word w 
									][
										either blk [
											either on? [
												'tree-images/node-open
											][
												'tree-images/node-closed
											]
										][
											'tree-images/item
										]
									]
								)
								font default-font
								text aliased (as-pair x + 40 0) (str)
								(
									over-box/2: tsiz: x + 40 + first size-text make system/standard/face [font: default-font size: 10000x100 text: str]
									if tsiz > root-face/size/x [
										root-face/hslider: max root-face/hslider tsiz
									]
									either gauge [
										compose [
											pen black
											fill-pen none
											box (goft: 2x2) (goft + 51x10)
											pen none
											fill-pen (any [g-color sky])
											box (goft + 1) (goft + 1 + as-pair gauge * .5 9)
										]
									][
									]
								)
							] 
						]
						tmp: copy/part beg (index? mark) - (index? beg)
						insert/only last lines reduce either blk [
							act?: false
							cont: none
							parse blk act-rule: [
								some [
									cont [
									'action (act?: true cont: [end skip])
									| into act-rule
									| skip
									]
								]
							]
							[beg tmp over-box act?]
						][
							[none tmp over-box]
						]
						if all [on? blk not empty? blk] [
							x: x + 18
							
							if tp? [
								insert tail tree-path str
							]
	
							insert/only tail mark-stack reduce [mark first last lines]
							
							l: l + 1
	
							parse/all blk tree-rule
	
							l: l - 1
	
							mark: first last mark-stack
							last-lines: second last mark-stack
							remove back tail mark-stack
	;							insert tail last-lines act?
	;							act?: false
															
							if tp? [
								remove back tail tree-path
							]
						]
					) :mark
				] (
					x: x - 18
					remove/part skip tail stk -3 3
				)
			]
			parse/all data tree-rule
			rows: length? lines
		
	;			print ">>>PARSE TREE<<<"
	;			probe lines
			return lines
		]

		tree-line: make face [
			edge: none
			fx: [draw []]
			fx2: [alphamul 128 draw []]
		]
		
		tmp-index: 0
		
		pane: func [face index /local lh tx tpos tsiz idx txt-pen][
			lh: tree-line/size/y
			either integer? index [
				if all [index <= (face/size/y / lh + .5) pick data index + scroll/y] [
					if tmp-index < index [
						tmp-index: index
						tree-line/size: as-pair max face/size/x root-face/hslider 18
						tree-line/offset: as-pair - scroll/x index - 1 * lh
						tree-line/color: white
						tree-line/data: index
						index: index + scroll/y
						txt-pen: either any [find data/:index/1/2 'action data/:index/1/4][
							tree-line/effect: copy tree-line/fx
							black
						][
							tree-line/effect: copy tree-line/fx2
							gray
						]
	
						tree-line/effect/draw: first next data/:index
						insert tree-line/effect compose/deep [
							draw [
							(
								either picked = data/:index/1/2 [
									tx: find second next data/:index 'text
									tpos: first skip tx 2
									tsiz: size-text make system/standard/face [font: default-font size: 10000x100 text: first skip tx 3]
									
									compose [pen white fill-pen silver box (tpos - 2) (tpos + tsiz)]
								][
								]
							)
							pen (txt-pen)
							(
								either all [
									index = ln
									over?
								][
									tree-ref: first data/:ln
									
									tx: find second next data/:index 'text
									tpos: first skip tx 2
									tsiz: size-text make system/standard/face [font: default-font size: 10000x100 text: first skip tx 3]
									compose [pen white fill-pen blue box (tpos - 2) (tpos + tsiz)]
								][
	
								]
							)
							(second next data/:index)
							]	
						]
						 
					]
					tree-line
				]
			][
				if system/view/focal-face <> face [ctx-rebgui/edit/unfocus system/view/focal-face: face]			
				unless face/parent-face/scroll? [
					x-mouse-pos: first index + scroll/x
					ln: 1 + second index / lh + scroll/y
					either all [
						ln <= rows
	;						x-mouse-pos > data/:ln/1/3/1
	;						x-mouse-pos < data/:ln/1/3/2
					][
						if any [
							not over?
							ln <> last-ln 
						][
							last-ln: ln
							over?: true
							show self
						]
					][
						if over? [
							tree-ref: none
							over?: false
							show self
						]
					]
				]
			]
		] ;END pane
	]

	add-hslider: does [
		tree-pane/size/y: tree-vslider/size/y: size/y - tree-hslider/size/y - (2 * edge/size/y) + 3
		tree-hslider/offset: as-pair -1 size/y - tree-hslider/size/y - (2 * edge/size/y) + 1
		tree-hslider/show?: true
	]

	remove-hslider: does [
		tree-pane/size/y: tree-vslider/size/y: size/y - (2 * edge/size/y) + 2
		tree-hslider/show?: false
	]
	
	check-sliders: has [list-lines] [
		list-lines: to-integer (size/y / 18)
		tree-vslider/ratio: min 1 max 0.1 list-lines / (rows + list-lines)
		
		either root-face/hslider <> 0 [
			add-hslider
		][
			remove-hslider
		]
	]
	
	node: make object! [
		type: 'node
		text: ""
		gauge: none
		gauge-color: none
		action-enter: none
		action-exit: none
		image: none
		shortcut: none
		data-ref: none
	] 

	node-tail: func [
		node [object!]
		/local
			tree-rule fin
	][
		tree-rule: [
			string!
			any [
				'image [word! | image!]
				| opt 'gauge number! opt tuple!
				| 'on 
				| 'action block!
				| 'shortcut block!
				|  block!
			] fin:
		]
		
		parse/all node/data-ref tree-rule
		return fin
	]

	build-node: func [
		node [object!]
		'end [word! none!]
		/local
			blk act tree-rule fin
	][
		if node/data-ref [
			tree-rule: [
				string!
				any [
					'image [word! | image!]
					| opt 'gauge number! opt tuple!
					| 'on 
					| 'action block!
					| 'shortcut block!
					|  set blk block!
				] fin:
			]
			
			parse/all node/data-ref tree-rule

			set end fin
		]
		
		return compose [
			(copy node/text)
			(either all [node/type = 'item word? node/image value? node/image] [compose [image (node/image)]][])
			(either node/gauge [compose [gauge (node/gauge)]][])
			(either all [node/gauge node/gauge-color][node/gauge-color][])
			(either all [node/type = 'node node/open?] ['on][])
			(
				act: copy []
				insert/only tail act either block? node/action-enter [
					bind node/action-enter 'system
				][[]]
				insert/only tail act either block? node/action-exit [
					bind node/action-exit 'system
				][[]]
				either all [
					empty? act/1
					empty? act/2
				][][compose/deep [action [(act)]]]
			)
			(either node/type = 'node [reduce either blk [[blk]][[copy []]]][])
		]
	]

	;public API commands

	create-node: has [
		/item
	][
		return make node compose [
			if item [type: 'item]
			(unless item [[open?: false]])
		] 
	]
	
	get-node: func [
		path [string!]
		/local
			result act act1 act2 exit-action stack beg tree-rule str c sc w g blk on? main-rule l n tr
	][
		path: to-block form parse/all path "/"
		stack: copy [0]
		l: 0
		tree-rule: [
			beg: set str string! (
				l: l + 1
				c: w: g: act: blk: none
				change back tail stack (last stack) + 1
				on?: false
			) 
			any [
				'image set w [word! | image!]
				| opt 'gauge set n number! set c opt tuple! (g: n)
				| 'on (on?: true)
				| 'action set act block!
				| 'shortcut set sc block!
				| set blk block! 
			]
			(
				if stack = path [
					tree-rule: [skip to end]
					if all [act parse/all act [set act1 block! set act2 block!]][
						exit-action: act2
						act: act1
					] 
					result: make object! compose [
						type: either blk ['node]['item]
						text: copy str
						gauge: g
						gauge-color: any [c if g [sky]]
						action-enter: act 
						action-exit: exit-action
						image: :w
						shortcut: none
						(either blk [
							[open?: on?]
						][])
						data-ref: beg
						line: l
					] 
				]
				if blk [
					insert tail stack 0
					parse/all blk main-rule
					remove back tail stack
				]
			)
		]		
		parse/all data main-rule: [some [(tr: tree-rule) tr]]
		return result
	]

	set-node: func [
		node [object!]
		/local
			blk act tmp-node tree-rule fin
	][
		tmp-node: build-node node fin

		insert remove/part node/data-ref (index? fin) - (index? node/data-ref) tmp-node
		return true
	]


	select-node: func [
		node [object! string!]
	][
		if string? node [
			node: dt/get-node node
		]
		if node [
			picked: copy/part node/data-ref (index? node-tail node) - (index? node/data-ref)
			return true
		]
		picked: none
		return false
	]

	add-node: func [
		path [string!]
		node [object!]
		/local
			new-ref
	][
		insert new-ref: get in get-node path 'data-ref build-node node none
		node/data-ref: new-ref
		return true
	]

	remove-node: func [
		node [string! object!]
	][
		if string? node [
			node: get-node node
		]
		remove/part node/data-ref (index? node-tail node) - (index? node/data-ref)
	]

	load-tree: func [
		file [file!]
	][
		data: load file
	]
	
	save-tree: func [
		file [file!]
	][
		save/all file data
	]

	redraw: has [/update] [
		if update [tree-pane/data: tree-pane/parse-tree data]
		
		tree-pane/size/x: root-face/size/x - tree-vslider/size/x - (edge/size/x * 2)			
		tree-vslider/offset: as-pair size/x - tree-vslider/size/x - (2 * edge/size/x) + 1  -1

		if picked-line [
			tree-pane/scroll/y: max 0 picked-line - 2
			tree-vslider/data: tree-pane/scroll/y / rows
		]
		
		check-sliders
		show self
	]


	;end of API

	edge: default-edge
	
	rows: picked: picked-line: root-face: tree-pane: tree-hslider: tree-vslider: none
	hslider: 0
	scroll?: false
	size: 100x50
			 		
	feel: make default-feel [
		detect: func [f e][
			case [
				e/type = 'down [
					f/scroll?: true
				]
				e/type = 'up [
					f/scroll?: false
				]
			]
			e
		]
	]
	
	init: does [
		root-face: self
		tree-vslider: make slider tree-vslider-spec
		tree-hslider: make slider tree-hslider-spec
		tree-pane: make rebface tree-pane-spec
		tree-vslider-spec: tree-hslider-spec: tree-pane-spec: none
		pane: reduce [tree-pane tree-vslider tree-hslider]
		foreach face pane [
			face/init
		]
		if data [
			redraw/update
		]
	]
]
