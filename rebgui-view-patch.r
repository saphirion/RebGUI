REBOL [
	Title:		"RebGUI View Patches"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.1
	Date:		26-Mar-2006
	Purpose:	"Patches to View functions to cooperate better with RebGUI."
	History: {
		0.1.0	Initial patch on INFORM and VIEW
	}
]

view: func [
	"Displays a window face."
	view-face [object!]
	/new "Creates a new window and returns immediately"
	/offset xy [pair!] "Offset of window on screen"
	/options opts [block! word!] "Window options [no-title no-border resize]"
	/title text [string!] "Window bar title"
	/local scr-face
] bind [
	enable-show/force ; the window face must be displayed
	scr-face: system/view/screen-face  ; reduces path overhead
	if find scr-face/pane view-face [return view-face] ; should bring to top !!!
	either any [new empty? scr-face/pane][
		view-face/text: any [
			view-face/text
			all [system/script/header system/script/title]
			copy ""
		]
		new: all [not new empty? scr-face/pane]
		append scr-face/pane view-face
	][change scr-face/pane view-face]
	; Use window-feel, not default feel, unless the user
	; has set their own feel (keep user's feel)
	if all [
		system/view/vid
		view-face/feel = system/view/vid/vid-face/feel
	][
		view-face/feel: window-feel
	]
	if offset [view-face/offset: xy]
	if options [view-face/options: opts]
	if title [view-face/text: text]
	show scr-face
;	show view-face
	if new [do-events]
	view-face
] system/view

show-popup: func [face [object!] /window window-face [object!] /away /local no-btn feelname] bind [
	enable-show/force none ; the popup must be displayed
	if find pop-list face [exit]
	window: either window [feelname: copy "popface-feel-win" window-face][
		feelname: copy "popface-feel"
		if none? face/options [face/options: copy []]
		if not find face/options 'parent [
			repend face/options ['parent none]
		]
		system/view/screen-face
	]
	; do not overwrite if user has provided custom feel
	if any [face/feel = system/words/face/feel face/feel = window-feel] [
		no-btn: false
		if block? get in face 'pane [
			no-btn: foreach item face/pane [if get in item 'action [break/return false] true]
		]
		if away [append feelname "-away"]
		if no-btn [append feelname "-nobtn"]
		face/feel: get bind to word! feelname 'popface-feel
	]
	insert tail pop-list pop-face: face
	append window/pane face
	show window
] system/view

hide-popup: func [/timeout /only pop-face [object!] /local win-face blocks? f] bind [
	pop-face: any [pop-face system/view/pop-face]
	enable-show/force none
	if not f: find pop-list pop-face [exit]
	win-face: any [pop-face/parent-face system/view/screen-face]
	remove find win-face/pane pop-face
	remove f pop-face
	blocks?: either in pop-face 'blocking? [
		pop-face/blocking?
	][
		true
	]
	if timeout [pop-face: pick pop-list length? pop-list]
	show win-face
	unless blocks? [do-events]
] system/view

unview: func [
	"Closes window views, except main view."
	/all "Close all views, including main view"
	/only face [object!] "Close a single view"
	/local pane
] bind [
	enable-show/force none ; the window view must be closed
	pane: head system/view/screen-face/pane
	either only [remove find pane face][
		either all [clear pane][remove back tail pane]
	]
	show system/view/screen-face
] system/view

if system/version/4 = 3 [ ;Windows only
context [

	user32-dll: load/library %user32.dll

	GCLP_HCURSOR: -12
	class-cursor: none
	result: none

	system-cursors: context [
		app-start: 32650
		hand: 32649
		help: 32651
		hourglass: 32650
		arrow: 32512
		cross: 32515
		i-shape: 32513
		no: 32648
		size-all: 32646
		size-nesw: 32643
		size-ns: 32645
		size-nwse: 32642
		size-we: 32644
		up-arrow: 32516
		wait: 32514
	]

	monitor-info: make struct! [
		cbSize [int]
		left [long]
		top [long]
		right [long]
		bottom [long]
		wleft [long]
		wtop [long]
		wright [long]
		wbottom [long]
		dwFlags [int]
	] none

	monitor-info/cbSize: length? third monitor-info

	pmonitor-info: to-integer reverse third make struct! [pmi [binary!]] reduce [third monitor-info]

	get-system-metrics: make routine! [
		nIndex [int]
		return: [integer!]
	] user32-dll "GetSystemMetrics"

	load-cursor: make routine! [
		hInstance [int]
		lpCursorName [int]
		return: [integer!]
	] user32-dll "LoadCursorA"

	set-cursor: make routine! [
		hCursor [int]
		return: [integer!]
	] user32-dll "SetCursor"

	set-class-long: make routine! [
		hWnd [int]
		nIndex [int]
		dwNewLong [int]
		return: [integer!]
	] user32-dll "SetClassLongA"

	find-window-class: make routine! [
		class [string!]
		name [int] 
		return: [int]
	] user32-dll "FindWindowA"

	find-window-name: make routine! [
		class [int]
		name [string!] 
		return: [int]
	] user32-dll "FindWindowA"


	get-monitor-info:  make routine! [
		hMonitor [int]
		lpmi [int]
	] user32-dll "GetMonitorInfoA"

	enum-display-monitors: make routine! [
		hdc [int]
		lprcClip [int]
		lpfnEnum [callback [int int int int return: [int]]]
		enumData [int]
		return: [integer!]
	] user32-dll "EnumDisplayMonitors"

	monitor-enum-proc: func [
		hMonitor [integer!]
		hdcMonitor [integer!]
		lprcMonitor [integer!]
		dwData [integer!]
		/local oft siz woft wsiz
	][
		get-monitor-info hMonitor pmonitor-info
		append result switch dwData [
			1 [ ;screen-origin
				as-pair monitor-info/left monitor-info/top
			]
			2 [ ;screen-size
				as-pair monitor-info/right - monitor-info/left monitor-info/bottom - monitor-info/top
			]
			3 [ ;work-origin
				as-pair monitor-info/wleft monitor-info/wtop
			]
			4 [ ;work-size
				as-pair monitor-info/wright - monitor-info/wleft monitor-info/wbottom - monitor-info/wtop
			]
		]
		return 1
	]
	
	get-result: func [
		id [integer!]
	][
		result: copy []
		enum-display-monitors 0 0 :monitor-enum-proc id
		;to be sure we are not async!
		while [empty? result][wait .01]
		result
	]

	set 'gui-metric func [
		"Returns specific gui related metric setting."
		keyword [word!] "Available keywords: MONITORS, VSCREEN-ORIGIN, VSCREEN-SIZE, SCREEN-ORIGIN, SCREEN-SIZE, WORK-ORIGIN, WORK-SIZE, BORDER-FIXED, BORDER-SIZE, TITLE-SIZE and WINDOW-MIN-SIZE."
		/local x y vals
	][

		switch keyword [
			monitors [
				return get-system-metrics 80
			]
			screen-origin [
				return get-result 1
			]
			screen-size [
				return get-result 2
			]
			work-origin [
				return get-result 3
			]
			work-size [
				return get-result 4
			]
		]

		unless vals: select [
			border-fixed [7 8]
			border-size [32 33]
			vscreen-size [78 79]
			vscreen-origin [76 77]
			title-size [none 4]
			window-min-size [28 29]
		] keyword [
			return none
		]
		
		set [x y] reduce vals
		
		set [x y] reduce [
			any [all [x get-system-metrics x] 0]
			any [all [y get-system-metrics y] 0]
		]
		
		as-pair x y
	]
	
	set 'cursor func [
		"Sets system mouse pointer shape."
		shape [word! none!]
		/local
			cursor
	][
		;print [now/time/precise "cursor:" shape]
		unless class-cursor [class-cursor: set-class-long find-window-class "REBOLWind" 0 GCLP_HCURSOR 0]
		cursor: 0
		switch type?/word shape [
			word! [
				cursor: load-cursor 0 any [
					all [
						in system-cursors shape
						system-cursors/:shape
					]
					system-cursors/arrow
				]
			]
;			image! []
		]
		set-cursor cursor
		true
	]
]
]