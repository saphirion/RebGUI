REBOL [
	Title:		"RebGUI requestor functions"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.1
	Date:		26-Mar-2006
	Purpose:	"Common requestor functions."
	Acknowledgements: {
		request-date based on the work of Carl Sassenrath's VID function of the same name
		request-file based on the work of Carl Sassenrath's VID function of the same name
	}
	History: {
		0.3.0	Merged into ctx-rebgui
		0.3.1	Fixed request-file to return fully qualified filenames
				Added proto-type request-dir function
		0.3.2	Changed display/popup to display/dialog
		0.3.3	Updated request-date
		0.3.4	Added alert & question requestors
				Updated request-dir to use new text-list
		0.3.5	Added /title refinement to request-date
				Made alert & question title args into refinements
		0.3.6	-
		0.3.7	Added no-hide refinement to alert & question
		0.3.8	Wrapped request-dir read-dir in an attempt block (Graham)
				Added early prototype bubble-menu
		0.3.9	Added request-password requestor

		0.4.0	Replaced attempt with try (Oldes)
		0.4.1	Replaced func/function/does/has with make function!
	}
]

make object! [

	result: none

	;
	;	--- alert ---
	;

	set 'alert make function! [
		"Prompts to acknowledge a message."
		message [string! block! object!] "Message text, layout or face"
		/title text [string!] "Title text"
	][
		switch type?/word message [
			string! [
				message: compose [
					text 50x-1 (translate message)
				]
			]
			object! [
				lay: layout compose [
					panel #HW (message/size / sizes/cell) data []
					return
					bar #WY
					reverse
					button #XY "OK" [hide-popup]
				]
				
				lay/pane/1/pane: message
				
				display/dialog/no-hide any [text "Alert"] lay
				exit
			]
		]
		display/dialog/no-hide any [text "Alert"] compose/only [
			panel #HW data (message)
			return
			bar #WY
			reverse
			button #XY "OK" [hide-popup]
		]		
	]

	;
	; --- request ---
	;
	set 'request func [
	    "Requests an answer to a simple question."
	    str [string! block! object! none!]
	    /offset xy
	    /ok
	    /only
	    /confirm
	    /type icon [word!] {Valid values are: alert, help (default), info, stop}
	    /timeout time
	    /local lay result msg y n c width f img rtn y-key n-key
	] bind [
	    rtn: func [value] [result: value hide-popup]
	    icon: any [icon all [none? icon any [ok timeout] 'info] 'help]
	    lay: either all [object? str in str 'type str/type = 'face] [str] [
	        if none? str [str: "What is your choice?"]
	        set [y n c] ["Yes" "No" "Cancel"]
	        if confirm [c: none]
	        if ok [y: "OK" n: c: none]
	        if only [y: n: c: none]
	        if block? str [
	            str: reduce str
	            set [str y n c] str
	            foreach n [str y n c] [
	                if all [found? get n not string? get n] [set n form get n]
	            ]
	        ]
	        str: translate str
	        width: any [all [200 >= length? str 280] to-integer (length? str) - 200 / 50 * 20 + 280]
	        layout [f: text bold to-pair reduce [width 1000] str]
	        img: switch/default :icon [
	            info [info.gif]
	            alert [exclamation.gif]
	            stop [stop.gif]
	        ] [help.gif]
	        result: copy [
	            across
	            at 0x0
	            origin 15x10
	            image img
	            pad 0x12
	            guide
	            msg: text bold black copy str to-pair reduce [width -1] return
	            pad 4x12
	        ]
	        y-key: pick "^My" found? ok
	        n-key: pick "^[n" found? confirm
	        append result pick [
	            [key #"o" [rtn yes] key #" " [rtn yes]]
	            [key #"n" [rtn no] key #"c" [rtn none]]
	        ] found? ok
	        if y [append result [btn-enter 60 translate y y-key [rtn yes]]]
	        if n [append result [btn 60 silver translate n n-key [rtn no]]]
	        if c [append result [btn-cancel 60 translate c escape [rtn none]]]
	        layout result
	    ]
	    result: none
	    either offset [inform/offset/timeout lay xy time] [inform/timeout lay time]
	    result
	] in system/words 'self

	;
	;	--- question ---
	;

	set 'question make function! [
		"Requests a Yes / No answer to a question."
		message [string! block! object!] "Message text, layout or face"
		/title text [string!] "Title text"
		/local lay
	][
		result: none
		switch type?/word message [
			string! [
				message: compose [
					text 40x-1 (translate message)
				]
			]
			object! [
				lay: layout compose [
					panel #HW (message/size / sizes/cell) data []
					return
					bar #WY
					reverse
					button #XY "No" [result: false hide-popup]
					button #XY "Yes" [result: true hide-popup]
				]
				
				lay/pane/1/pane: message
				
				display/dialog/no-hide any [text "Question"] lay
				return result
			]
		]
		display/dialog/no-hide any [text "Question"] compose/only [
			panel #HW data (message)
			return
			bar #WY
			reverse
			button #XY "No" [result: false hide-popup]
			button #XY "Yes" [result: true hide-popup]
		]
		result
	]

	;
	;	--- bubble-menu ---
	;

	;	pen 245.222.129 fill-pen wheat circle 40x40 39.5 pen 0.0.0 text 40x40 "One"

	set 'bubble-menu make function! [face [object!] data [block!] /local menu-size menu-draw item-pos data-items menu-origins] [
		menu-size: as-pair 20 * sizes/cell 10 * sizes/cell * length? data
		item-pos: .5 * as-pair menu-size/x menu-size/x
		data-items: to integer! .5 * length? data
		menu-draw: copy []
		menu-origins: copy []
		foreach [label action] data [
			insert tail menu-draw reduce ['pen wheat 'fill-pen wheat 'circle item-pos -1 + menu-size/x / 2 'pen black 'text item-pos label]
			insert tail menu-origins item-pos -1 + menu-size/x / 2
			item-pos/y: item-pos/y + menu-size/x
		]
		;	add face to parent
		insert tail face/parent-face/pane make ctx-rebgui/rebface [
			offset:	face/offset
			size:	menu-size
			items:	data-items
			origins:	menu-origins
			effect:	compose/deep [draw [(menu-draw)]]
			feel:	make ctx-rebgui/widgets/default-feel [
				detect: make function! [face event /local pos] [
					if event/type = 'move [
						repeat i face/items [
							poke face/effect/draw i - 1 * 12 + 2 wheat
							poke face/effect/draw i - 1 * 12 + 4 wheat
						]
						pos: none
						foreach origin face/origins [
							;	bug in detect event/offset - should not be relative to window!!!
							if (face/size/x / 2) > distance? origin event/offset - face/offset [
								pos: index? find face/origins origin
								break
							]
						]
						if pos [
							poke face/effect/draw pos * 12 - 10 tan
							poke face/effect/draw pos * 12 - 8 tan
						]
						show face
					]
					if event/type = 'down [
						pos: none
						foreach origin face/origins [
							;	bug in detect event/offset - should not be relative to window!!!
							if (face/size/x / 2) > distance? origin event/offset - face/offset [
								pos: index? find face/origins origin
								break
							]
						]
						print pos
						remove back tail face/parent-face/pane
						show face/parent-face
					]
				]
			]
		]
		show face/parent-face
	]

	;
	;	--- request-color ---
	;

	color-spec: copy [margin 2x2 space 1x1]

	result: 1

	foreach color locale*/colors [
		insert tail color-spec compose/deep [
			box 5x5 (color) [result: (color) hide-popup] edge [] feel [
				over: make function! [face act pos][
					if act [show-title face/parent-face (uppercase/part form color 1)]
				]
			]
		]
		if zero? result // 7 [insert tail color-spec 'return]
		result: result + 1
	]

	if 'return = last color-spec [remove back tail color-spec]

	insert tail color-spec [return pad 26 button "No color" [result: false hide-popup]]
	
	set 'request-color make function! [
		"Requests a color."
		/title text [string!] "Title text"
	][
		result: none
		display/dialog any [text "Color Palette"] color-spec
		result
	]

	;
	;	--- request-date ---
	;

	;	arrows & title
	date-spec: compose [
		tight
		button 10 "<<" [default-date/year: default-date/year - 1 show face/parent-face]
		button 10 "<" [default-date/month: default-date/month - 1 show face/parent-face]
		button 30 (reform [pick locale*/months now/month now/year]) feel [
			engage: make function! [face act event] [
				if act = 'down [
					default-date: starting-date show face/parent-face
				]
			]
			redraw: make function! [face action pos /local date month] [
				if action = 'show [
					date: default-date
					month: date/month
					date/day: 1
					date: date - date/weekday + 1
					foreach sub-face skip face/parent-face/pane 12 [
						sub-face/edge/size: 0x0
						sub-face/text: either date/month = month [
							if date = starting-date [sub-face/edge/size: 1x1]
							form date/day
						][none]
						date: date + 1
					]
					face/parent-face/pane/3/text: reform [pick locale*/months default-date/month default-date/year]
				]
			]
		]
		button 10 ">" [default-date/month: default-date/month + 1 show face/parent-face]
		button 10 ">>" [default-date/year: default-date/year + 1 show face/parent-face]
		return
	]

	;	day labels
	foreach day locale*/days [
		insert tail date-spec compose [
			label 10 (copy/part day 3) font [align: 'center]
		]
	]

	;	7x6 day slots
	loop 6 [
		insert tail date-spec 'return
		loop 7 [
			insert tail date-spec [
				text 10 white font [align: 'center valign: 'middle] edge [size: 0x0 color: red] feel [
					over: make function! [face act pos] [
						either all [act face/text] [
							face/color: colors/menu
							face/font/color: white
							default-date/day: to integer! face/text
							show-title face/parent-face form default-date
						][
							face/color: white
							face/font/color: black
						]
						show face
					]
					engage: make function! [face act event] [
						if all [act = 'down face/text] [
							default-date/day: to integer! face/text
							result: default-date
							hide-popup
						]
					]
				]
			]
		]
	]

	starting-date: default-date: none

	set 'request-date make function! [
		"Requests a date."
		/title text [string!] "Title text"
		/date new-date [date!] "Initial date to show"
	][
		result: none
		starting-date: default-date: any [new-date now/date]
		display/dialog any [text "Calender"] date-spec
		result
	]

	;
	;	--- request-dir ---
	;

	read-dir: make function! [path /local blk] [
		blk: copy []
		unless path = %/ [insert blk %..]
		foreach f remove-each file read path [#"/" <> last file] [
			insert tail blk head remove back tail f
		]
		return sort blk
	]

	set 'request-dir make function! [
		"Requests a directory using a popup list."
		/title "Change heading on request."
		text "Title line of request"
		/dir path "Set starting directory"
		/make-new directory "Preset directory to create"
		/local txt lst new gui
	][
		text: any [text "Select a Directory:"]

		either any [none? path not exists? path]
			[path: clean-path %.]
			[path: dirize path]

		result: none

		display/dialog text compose/deep [
			txt: text 100 (form to-local-file path)
			return
			label 30 "New Directory"
			new: field 51 (either make-new [directory][])
			button "Create" [
				unless empty? trim new/text [
					either error? try [make-dir join path new/text] [
						alert "Warning" "Could not create directory"
					][
						show-text txt to-local-file join path new/text
						insert clear lst/data read-dir dirize join path new/text
						lst/redraw
					]
				]
			]
			return
			lst: text-list 100x50 data [(read-dir path)] [
				error? try [
					path: dirize clean-path join path pick face/data first face/picked
					show-text txt to-local-file path
					insert clear face/data read-dir path
					face/redraw
				]
			]
			return
			bar
			reverse
			button "Select" [result: dirize to-rebol-file txt/text hide-popup]
			button "Root" [
				path: %/
				show-text txt to-local-file path
				insert clear lst/data read-dir path
				lst/redraw
			]
		]

		result
	]

	;
	;	--- request-file ---
	;

	if all [3 = fourth system/version value? 'local-request-file] [
		set 'request-file make function! [
			"Requests a file using a popup list of files and directories."
			/title "Change heading on request."
			text "Title line of request"
			/file path "Default file name or block of file names"
			/filter name mask "Filter name and mask"
			/only "Return only a single file, not a block."
			/save "Request file for saving, otherwise loading."
			/local blk
		][
			text: any [text either save ["Save"]["Open"]]
			if file [
				set [path file] split-path clean-path path
			]
			;	set valid path and file values
			if any [none? path not exists? path] [path: clean-path %.]
			file: either any [none? file not exists? path/:file] [copy []] [compose [(file)]]
			;	call OS file-requestor
			if local-request-file result: reduce [
				any [select locale*/words text text]
				""
				path
				file
				compose [(any [select locale*/words name name select locale*/words "All" "All"])]
				compose/deep [[(any [mask "*"])]]
				logic? only
				logic? save
			][
				either only [join result/3 first result/4] [
					blk: copy []
					foreach file result/4 [insert tail blk join result/3 file]
					blk
				]
			]
		]
	]

	;
	;	--- request-password ---
	;

	set 'request-password make function! [
		"Requests a username and password."
		/title text [string!] "Title text"
		/user username [string!] "Default username"
		/pass password [string!] "Default password"
		/min-length min-chars [integer!] "Minimum password length (defaults to 0)"
		/max-length max-chars [integer!] "Maximum password length (defaults to 32)"
		/only "Password only"
		/verify "Verify password"
		/local blk u p v	; user, password, verify
	][
		blk: copy []
		unless only [
			insert blk compose [text 20 "Username:" u: field (any [username ""]) return]
		]
		insert tail blk compose [text 20 "Password:" p: password (any [password ""]) return]
		if verify [insert tail blk copy [text 20 "Verify:" v: password return]]

		unless min-length [min-chars: 0]
		unless max-length [max-chars: 32]

		result: none
		display/dialog any [text "Password"] compose [
			(blk)
			bar
			reverse
			button "OK" [
				either all [not only u/text = ""] [
					alert "Username must be provided"
				][
					either any [min-chars > length? p/text max-chars < length? p/text][
						alert reform ["Password must be between" min-chars "and" max-chars "characters in length."]
					][
						either all [verify p/text <> v/text] [
							alert "Please try again"
						][
							result: either only [copy p/text] [reduce [u/text p/text]]
							hide-popup
						]
					]
				]
			]
			do [edit/focus face/pane/2]
		]
		result
	]
]
