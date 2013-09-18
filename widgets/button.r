button: make rebface [
	size:	15x5
	text:	""
	data:	reduce [
		#do [load %../images/button-up.png]
		#do [load %../images/button-down.png]
		#do [load %../images/button-hover.png]
	]
	;BEG by Cyphre, sponsored by Robert
	mask-spec: [
		;image: load 64#{
		;	iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAE3RFWHRTb2Z0d2Fy
		;	ZQBSRUJPTC9WaWV3j9kWeAAAABVJREFUeJxjYECA/wxYOP8xZDBUAACtlgX75tIw
		;	BAAAAABJRU5ErkJggg==
		;}
		color: edge: none
		effect: [tile]
	]
	;END by Cyphre, sponsored by Robert
;	image:	first data
	button-color: none
	fx:	[mix extend 3x7 1x1 0]
	active: true ;by Cyphre, sponsored by Robert
	click?: false ;by Cyphre, sponsored by Robert
	font:	make default-font [align: 'center]
	feel:	make default-feel [
		redraw: make function! [face act pos] [
			if act = 'show	[
				if face/color [
					face/button-color: face/color
					face/color: none
				] 
				if face/size <> face/old-size [face/fx/4: face/size - face/image/size]
				;BEG by Cyphre, sponsored by Robert
				either face/active [
					face/pane: none
				][
					face/pane: make system/standard/face mask-spec
					face/pane/parent-face: face
					face/pane/size: face/size
				]
				face/effect: compose bind face/fx in face 'self
				;END by Cyphre, sponsored by Robert
			]
		]
		over: make function! [face act pos] [
			face/image: either all [face/active act] [face/data/3] [face/data/1] ;by Cyphre, sponsored by Robert
			show face
		]
		engage: make function! [face act event] [
			if face/active [ ;by Cyphre, sponsored by Robert
				switch act [
					down	[face/click?: true face/image: face/data/2 show face]	;by Cyphre, sponsored by Robert
					alt-down	[face/image: face/data/2 show face face/alt-action face]	; AGT 12-May-2006
					up		[face/image: face/data/1 show face if face/click? [face/action face] face/click?: false] ;by Cyphre, sponsored by Robert - action should be called on mouse-up
					alt-up		[face/image: face/data/1 show face]							; AGT 12-May-2006
;BEG by Cyphre, sponsored by Robert
					away	[
						face/image: face/data/1 show face
						face/click?: false
					]
					over [
						face/image: face/data/2 show face
						face/click?: true
					]
;END by Cyphre, sponsored by Robert
				]
			]
		]
	]
	;	seemingly redundant, but needed where redraw is redefined (see request-date)
	init:	make function! [] [
		image: first data
		fx/4: size - image/size
		self/effect: compose bind self/fx self
	]
]
