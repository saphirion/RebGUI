REBOL [
	Title:		"RebGUI edit feel"
	Owner:		"Ashley G. Trüter"
	Version:	0.4.1
	Date:		26-Mar-2006
	Purpose:	"Edit support for RebGUI widgets."
	Acknowledgements: {
		Edit functionality based on the work of Carl Sassenrath (%view-edit.r SDK source)
		Undo / Redo based on the work of Romano Paolo Tenca http://www.rebol.it/~romano/edit-text-undo.txt
		Soundex function derived from Allen Kamp's http://www.rebol.org/library/scripts-download/soundex.r
		Dictionaries sourced from AbiWord http://www.abisource.com/downloads/dictionaries/Windows/
	}
	History: {
		0.3.0	Merged into ctx-rebgui
				Added spellcheck functionality
		0.3.1	Spellcheck ignores single-char words
				Ignore Ctrl+S if %dictionary not present
		0.3.2	Changed /popup refinement to /dialog
				Added process-keystroke function to handle global focus
		0.3.3	-
		0.3.4	Added scroll reset to focus function
				Added edit-list to tab widgets
				Fixed tab crash when no other widgets exist to tab to
		0.3.5	Added ESC hide-popup
		0.3.6	Added description to focus function
		0.3.7	-
		0.3.8	Area cursor down fixes (http://polly.rebol.it/ - author unknown)
				Added key-scroll? to support area widget
				Added unfocus-action and focus-action handlers
		0.3.9	-

		0.4.0	Reworked scrolling (mainly in edit-text)
		0.4.1	Replaced context with make object!
				Replaced func/function/does/has with make function!
				ESC now falls through if no popup to hide
	}
]

make object! [

	;
	;	--- Spellcheck ---
	;

	soundex: make function! [
		"Phonetic representation of a string."
		string [string!]
		/local code val
	][
		string: unique uppercase form trim string
		if empty? string [return none]
		code: make string! 4
		insert code copy/part string 1
		;	convert chars 2-4
		foreach char next string [
			parse form char [
				[
					  [["B" | "F" | "P" | "V"]							(val: "1")]
					| [["C" | "G" | "J" | "K" | "Q" | "S" | "X" | "Z"]	(val: "2")]
					| [["D" | "T"]										(val: "3")]
					| [["L"]											(val: "4")]
					| [["M" | "N"]										(val: "5")]
					| [["R"]											(val: "6")]
				]
				(insert tail code val)
			]
			if 3 = length? code [break]	; stop after reaching 3rd char
		]
		to word! code
	]

	letter: charset [#"A" - #"Z" #"a" - #"z" #"'"]
	capital: charset [#"A" - #"Z"]
	other: negate letter
	ignore: copy []
	new: copy []
	check?: false
	last-offset: 0x0
	siblings: none

	lookup-word: make function! [word [string!] /local new-word code search blk] [
		blk: compose [(word)]
		if all [
			code: soundex word
			search: find locale*/dict code 
		][
			foreach [s w] search [
				if s <> code [break]
				;	ensure capitalization is same
				either find capital last word [uppercase w] [
					if find capital first word [uppercase/part w 1]
				]
				insert tail blk w
			]
		]
		display/dialog rejoin ["Spellcheck (" locale*/language ")"] compose/only [
			label 25 "Original"
			text 75 (copy word)
			return
			label 25 "Word"
			new-word: field 75 (copy word)
			return
			label 25 "Suggestions"
			text-list 75x50 data (blk) [show-text new-word pick face/data first face/picked]
			return
			bar
			reverse
			button "Close"		[check?: false last-offset: face/parent-face/offset hide-popup]
			button "Add"		[insert tail new new-word/text check?: new-word/text last-offset: face/parent-face/offset hide-popup]
			button "Replace"	[check?: new-word/text last-offset: face/parent-face/offset hide-popup]
			button "All"		[insert tail ignore word last-offset: face/parent-face/offset hide-popup]
			button "Ignore"		[last-offset: face/parent-face/offset hide-popup]
			do [face/offset: last-offset]
		]
	]

	spellcheck: make function! [face [object!] /local word start end] [
		unlight-text
		show face
		check?: true
		clear ignore
		clear new
		;	find start of first word
		start: head face/text
		unless find letter first start [
			while [all [not tail? start: next start find other first start]] []
		]
		;	find end of first word
		end: start
		while [all [not tail? end: next end find letter first end]] []
		;	check remaining words
		while [all [check? start <> end]] [
			word: copy/part start end
			unless any [
				1 = length? word
				find ignore word
				find new word
				find locale*/dict word
			][
				hilight-text start end
				show face
				lookup-word word
				focus face
				view*/caret: start
				if string? check? [
					change/part start check? end
					end: skip start length? check?
					check?: true
				]
				hilight-text start end
				show face
			]
			start: end
			while [all [not tail? start: next start find other first start]] []
			end: start
			while [all [not tail? end: next end find letter first end]] []
		]
		;	add new words to dictionary
		unless empty? new [
			foreach word new [
				insert tail locale*/dict reduce [soundex word word]
			]
			save locale*/dictionary sort/skip/all locale*/dict 2
		]
		;	confirmation
		alert "Spellcheck complete."
	]

	;
	;	--- Edit ---
	;

	insert?: true

	keymap: [
		#"^H" back-char
		#"^~" del-char
		#"^M" enter
		#"^A" all-text
		#"^C" copy-text
		#"^X" cut-text
		#"^V" paste-text
		#"^T" clear-tail
		#"^Z" undo
		#"^Y" redo
		#"^[" undo-all
		#"^S" spellcheck
	]

	;	Text highlight functions (but, do not reshow the face)

	hilight-text: make function! [start end][
		view*/highlight-start: start
		view*/highlight-end: end
	]

	hilight-all: make function! [face] [
		either empty? face/text [unlight-text] [
			view*/highlight-start: head face/text
			view*/highlight-end: tail face/text
		]
	]

	unlight-text: make function! [] [
		view*/highlight-start: view*/highlight-end: none
	]

	hilight?: make function! [] [
		all [
			object? view*/focal-face
			string? view*/highlight-start
			string? view*/highlight-end
			not zero? offset? view*/highlight-end view*/highlight-start
		]
	]

	hilight-range?: make function! [/local start end] [
		start: view*/highlight-start
		end: view*/highlight-end
		if negative? offset? start end [start: end end: view*/highlight-start]
		reduce [start end]
	]

	;	Text focus functions

	tabbed: [area field number-field edit-list password button drop-list drop-tree grid table]
    tabbed?: make function! [
		face [object!]
	] [
		all [
			find tabbed face/type
			;BEG fixed by Cyphre, sponsored by Robert
			;this addition takes in account face/editable? face (if exists) when making tabbed? decission
			;face/editable? can be used in widgets where the tabbed state is not always permanent (eg. drop-list) 
			any [
				not in face 'editable?
				face/editable?
			] 
			;END fixed by Cyphre, sponsored by Robert
			face
		]
	] ; [che] Returns TRUE if a face itself (not one of it's pane's subfaces) is tabbable (NONE otherwise).
    
    cyclic: [tab-panel]                                                         ; [che]
    cyclic?: make function! [face [object!]] [all [find cyclic face/type face]] ; [che] Returns TRUE if a face sets up it's own closed tab cycle.

	;added AREA too according to Robert's request -Cyphre    
	hilight-on-focus: [area field number-field edit-list]

	caret-on-focus: [area field number-field edit-list password drop-list grid]

	action-on-enter: [field number-field edit-list password drop-list]

	unfocus: make function! [
		/force
		/local face
	][
		if all [face: view*/focal-face function? get in face 'unfocus-action] [ ; protect against faces not made with rebface
			if all [
				not face/unfocus-action face
				not force
			][
				return false
			]
		]
		view*/focal-face: view*/caret: none
		unlight-text
		if face [show face]
		true
	]

	focus: make function! [
		"Focuses key events on a specific face."
		face [object!]
		/force
		/no-hilight
	][
		unless unfocus [return]
		if face/show? [
			if get in face 'focus-action [	; protect against faces not made with rebface
				if all [
					not face/focus-action face
					not force
				][
					return false
				]
			]
			view*/focal-face: face
			if find caret-on-focus face/type [
				view*/caret: tail face/text
				if face/para [face/para/scroll: 0x0]
			]
			if all [not no-hilight find hilight-on-focus face/type] [hilight-all face]
			if in face 'esc [face/esc: copy face/text]
			show face
		]
	]

	;	Copy and delete functions
	
	copy-selected-text: make function! [/local start end][
		if hilight? [
			set [start end] hilight-range?
			write clipboard:// copy/part start end
			true
		] ; else return false
	]

	delete-selected-text: make function! [/local start end] [
		if hilight? [
			set [start end] hilight-range?
			unless same? head start head end [end: at start index? end] 
			remove/part start end
			view*/caret: start
			view*/focal-face/line-list: none
			unlight-text
			true
		] ; else return false
	]

	cut-text: make function! [] [
		undo-add face
		copy-selected-text face
		delete-selected-text
	]

	paste-text: make function! [] [
		undo-add face
		delete-selected-text
		face/line-list: none
		view*/caret: insert view*/caret read clipboard://
	]

	;	Undo / Redo functions

	undo-max: 20	; max number of undo levels, none = unlimited

	undo-add: make function! [face] [
		if in face 'undo [
			insert clear face/undo at copy face/text index? view*/caret
			if all [undo-max undo-max < length? head face/undo] [remove head face/undo]
			face/undo: tail face/undo
		]
	]

	undo-get: make function! [face] [
		face/text: head view*/caret: first face/undo
		face/line-list: none
		remove face/undo
	]

	;	Cursor movement functions

	word-limits: make function! [/local cs] [
		cs: charset join " ^-^m/[](){}^"" newline	; required for merge
		reduce [cs complement cs]
	]

	current-word: make function! [str /local s ns] [
		set [s] word-limits
		s: any [all [s: find/reverse str s next s] head str]
		set [ns] word-limits
		ns: any [find str ns tail str]
		;	hilight word
		hilight-text s ns
		show view*/focal-face
	]

	next-word: make function! [str /local s ns] [
		set [s ns] word-limits
		any [all [s: find str s find s ns] tail str]
	]

	back-word: make function! [str /local s ns] [
		set [s ns] word-limits
		any [all [ns: find/reverse str ns ns: find/reverse ns s next ns] head str]
	]

	end-of-line: make function! [str] [
		any [find str newline tail str]
	]

	beg-of-line: make function! [str /local nstr] [
		either nstr: find/reverse str newline [next nstr] [head str]
	]

	next-field: make function! [face /wrap] [                   ; [che] 
        unless face/parent-face [return none]                                   ; [che]
        unless find [object! block!] type?/word get in face/parent-face 'pane [ ; [che] -- An iterated face may of course be tabbable, too.
            return none                                                         ; [che]    I don't handle this case for now, though.
        ]                                                                       ; [che] 
                                                                                ; [che]
        siblings: compose [(face/parent-face/pane)]                             ; [che]
                                                                                ; [che]
        unless wrap [siblings: find/tail siblings face]                         ; [che]
                                                                                ; [che]
        foreach sibling siblings [                                              ; [che] -- Return younger siblings, nieces and nephews.
            if target: any [                                                    ; [che]
                tabbed? sibling                                                 ; [che]
                into-widget/forwards sibling                                    ; [che]
            ][                                                                  ; [che]
                return target                                                   ; [che]
            ]                                                                   ; [che]
        ]                                                                       ; [che]
                                                                                ; [che]
        all [                                                                   ; [che] -- Return aunts, uncles and cousins.
			not cyclic? face/parent-face                                        ; [che]
            target: next-field face/parent-face                                 ; [che]
            return target                                                       ; [che]
        ]                                                                       ; [che]
                                                                                ; [che]
        all [                                                                   ; [che] -- Return older siblings. 
            target: next-field/wrap face                                        ; [che]
            return target                                                       ; [che]
        ]                                                                       ; [che]
    ]                                                                           ; [che]
    
    back-field: make function! [face /wrap] [                                   ; [che]
        unless face/parent-face [return none]                                   ; [che]
        unless find [object! block!] type?/word get in face/parent-face 'pane [ ; [che] -- An iterated faces may of course be tabbable, too.
            return none                                                         ; [che]    I don't handle this case for now, though.
        ]                                                                       ; [che] 
                                                                                ; [che]
        siblings: reverse compose [(face/parent-face/pane)]                     ; [che]
                                                                                ; [che]
        unless wrap [siblings: find/tail siblings face]                         ; [che]
                                                                                ; [che]
        foreach sibling siblings [                                              ; [che] -- Return younger siblings, nieces and nephews.
            if target: any [                                                    ; [che]
                tabbed? sibling                                                 ; [che]
                into-widget/backwards sibling                                   ; [che]
            ][                                                                  ; [che]
                return target                                                   ; [che]
            ]                                                                   ; [che]
        ]                                                                       ; [che]
                                                                                ; [che]
        all [                                                                   ; [che] -- Return aunts, uncles and cousins.
            not cyclic? face/parent-face                                        ; [che]
            target: back-field face/parent-face                                 ; [che]
            return target                                                       ; [che]
        ]                                                                       ; [che]
                                                                                ; [che]
        all [                                                                   ; [che] -- Return older siblings. 
            target: back-field/wrap face                                        ; [che]
            return target                                                       ; [che]
        ]                                                                       ; [che]
    ]                                                                           ; [che] 
    
    into-widget: make function! [                                               ; [che]
        "Recursivly returns the first tabbable face in parent's face pane tree."; [che] 
        face [object!]                                                          ; [che]
    /forwards                                                                   ; [che]
    /backwards                                                                  ; [che]
    /local                                                                      ; [che]
        target children                                                         ; [che]
    ][                                                                          ; [che]
        unless find [object! block!] type?/word get in face 'pane [             ; [che] -- An iterated faces may of course be tabbable, too. I don't handle this case for now, though.  
            return none                                                         ; [che]
        ]                                                                       ; [che]
                                                                                ; [che]
        children: compose [(face/pane)]                                         ; [che]
                                                                                ; [che]
        catch [                                                                 ; [che]
            foreach child either backwards [reverse children] [children] [      ; [che]
                if target: any [                                                ; [che]
                    tabbed? child                                               ; [che] -- The successing face is tabbable, so just return it. 
                    either backwards [                                          ; [che]
                        into-widget/backwards child                             ; [che]
                    ][                                                          ; [che]
                        into-widget child                                       ; [che]
                    ]                                                           ; [che]
                ][                                                              ; [che]
                    throw target                                                ; [che]
                ]                                                               ; [che]
            ]                                                                   ; [che]
        ]                                                                       ; [che]
    ]                                                                           ; [che]
    
	process-keystroke: make function! [face event /local f res r c idx pf] [
		switch/default event/key [
			#"^-" [
				if all [
					view*/focal-face
					viewed? view*/focal-face
					not find view*/focal-face/options 'grid-item 	;grid edit mode support - Cyphre 
				][
					;	deflag button?
					if view*/focal-face/type = 'button [
						view*/focal-face/feel/over view*/focal-face false none
					]
					;BEG added by Cyphre, sponsored by Robert
					if all [
						find view*/focal-face/options 'input-grid-item
						get in view*/focal-face/parent-face 'cell-action
					][
						pf: view*/focal-face/parent-face
						idx: index? find pf/pane view*/focal-face
						r: to-integer idx / (pf/cols + 1)
						c: idx - (r * (pf/cols + 1)) - 1
						unless any [
							pf/do-action view*/focal-face pick pf/row-actions r
							pf/do-action view*/focal-face pick pf/col-actions c
							pf/do-action view*/focal-face get in pf 'cell-action
						][
							exit
						]
					]
					either all [
						find view*/focal-face/options 'input-grid-item
						view*/focal-face/parent-face/tabbing-mode = 'top-bottom
					][
						f: view*/focal-face/parent-face/on-tab event/shift
					][
						;END added by Cyphre, sponsored by Robert
						;	find previous / next tabbable field
						f: either event/shift [
							back-field view*/focal-face
						][
							next-field view*/focal-face
						]
					]
					if :f [
						focus f											; focus
						if f/type = 'button [f/feel/over f true none]	; flag button
					]
					exit											; terminate function for current face
				]
			]
			#" " [
				;	do button action on SPC
				if all [view*/focal-face view*/focal-face/type = 'button][
					view*/focal-face/action view*/focal-face
				]
			]
		][
;BEG grid edit mode support - Cyphre
			if all [
				view*/focal-face
				find view*/focal-face/options 'grid-item
				event/key = #"^["
				view*/focal-face <> f: view*/focal-face/parent-face/parent-face
			][
				focus f
				exit
			]
;END grid edit mode support - Cyphre	
			either all [
				event/key = #"^["
				find view*/pop-list view*/pop-face
			][
				hide-popup
			][
				;	if key is assigned to an action do it
				if any [
					not view*/focal-face
					find [button] view*/focal-face/type
				][
					if f: select face/keycodes event/key [f/action f exit]
				]
			]
			;convert control chars 
			if all [
				char? key: event/key
				32 > to integer! event/key
			][
				key: to char! key + 64
			] 
			if f: find/skip key-shortcuts reduce [event/control event/shift to issue! key] 4 [
				do func [action-type [word!]] first skip f 3 'key
			]
		]
	]

	keys-to-insert: make bitset! #{01000000FFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}

	insert-char: make function! [face char] [
		delete-selected-text
		unless insert? [remove view*/caret]
		insert view*/caret char
		view*/caret: next view*/caret
	]

	move: make function! [event ctrl plain] [
		either event/shift [
			any [view*/highlight-start view*/highlight-start: view*/caret]
		] [unlight-text]
		view*/caret: either event/control ctrl plain
		if event/shift [
			either view*/caret = view*/highlight-start [unlight-text] [view*/highlight-end: view*/caret]
		]
	]

	move-y: make function! [face delta /local pos tmp tmp2] [
		tmp: offset-to-caret face 0x2 + delta + pos: caret-to-offset face view*/caret
		tmp2: caret-to-offset face tmp
		either tmp2/y <> pos/y [tmp] [view*/caret]
	]

	edit-text: make function! [
		face event
		/local key edge para caret scroll page-up page-down face-size orig-text
	][
		orig-text: copy face/text
		face-size: face/size - either face/edge [2 * face/edge/size] [0]
		key: event/key
		if char? key [
			either find keys-to-insert key [
				undo-add face
				insert-char face key
			] [key: select keymap key]
		]
		if word? key [
			page-up:	[move-y face face-size - sizes/font-height - sizes/font-height * 0x-1]
			page-down:	[move-y face face-size - sizes/font-height * 0x1]
			do select [
				left		[move event [back-word view*/caret] [back view*/caret]]
				right		[move event [next-word view*/caret] [next view*/caret]]
				up			[move event page-up [move-y face sizes/font-height * 0x-1]]
				down		[move event page-down [move-y face sizes/font-height * 0x1]]
				page-up		[move event [head view*/caret] page-up]
				page-down	[move event [tail view*/caret] page-down]
				home		[move event [head view*/caret] [beg-of-line view*/caret]]
				end			[move event [tail view*/caret] [end-of-line view*/caret]]
				insert		[either event/shift [paste-text] [insert?: complement insert?]]
				back-char [
					undo-add face
					any [
						delete-selected-text
						head? view*/caret
						either event/control [
							tmp: view*/caret
							remove/part view*/caret: back-word tmp tmp
						] [remove view*/caret: back view*/caret]
					]
				]
				del-char [
					undo-add face
					either event/shift [unless face/type = 'password [cut-text]] [	;	shift+Del cut
						any [
							delete-selected-text
							tail? view*/caret
							either event/control [
								remove/part view*/caret back next-word view*/caret
								if tail? next view*/caret [remove back tail view*/caret]
							] [remove view*/caret]
						]
					]
				]
				enter [
					either find action-on-enter face/type [
						face/action face
					][
						undo-add face
						insert-char face newline
					]
				]
				all-text	[hilight-all face]
				copy-text	[unless face/type = 'password [copy-selected-text face unlight-text]]
				cut-text	[unless face/type = 'password [cut-text]]
				paste-text	[paste-text]
				clear-tail [
					undo-add face
					remove/part view*/caret end-of-line view*/caret
				]
				undo [
					if all [in face 'undo not head? face/undo] [
						insert face/undo at copy face/text index? view*/caret
						face/undo: back face/undo
						undo-get face
					]
				]
				redo [
					if all [in face 'undo not tail? face/undo] [
						face/undo: insert face/undo at copy face/text index? view*/caret
						undo-get face
					]
				]
				undo-all [
					if in face 'esc [
						clear face/text
						if in face 'undo [clear face/undo]
						if string? face/esc [insert face/text face/esc]
						view*/caret: tail face/text
					]
				]
				spellcheck [
					if all [not empty? face/text exists? %dictionary] [
						spellcheck face
					]
				]
			] key
		]
		;	scroll to keep caret visible
		edge: face/edge
		para: face/para
		scroll: face/para/scroll

		;BEG fixed by Cyphre, sponsored by Robert		
		if all [view*/caret caret: caret-to-offset face view*/caret] [
			if caret/y < (edge/size/y + para/origin/y + para/indent/y) [ ; above top visible row ?
				scroll/y: round/to scroll/y - caret/y sizes/font-height ; scroll to make caret visible
			]
	
			if caret/y > (face-size/y - sizes/font-height) [ ; below bottom visible row ? (face-size takes edge into account)
				scroll/y: round/to (scroll/y + ((face-size/y - sizes/font-height) - caret/y)) sizes/font-height
			]
	
			if not para/wrap? [
				if caret/x < (edge/size/x + para/origin/x + para/indent/x) [
					scroll/x: scroll/x - caret/x + (edge/size/x + para/origin/x + para/indent/x)
				]
				if caret/x > (face-size/x - para/margin/x) [
					scroll/x: scroll/x + (face-size/x - para/margin/x - caret/x)
				]
			]
		]
		;END fixed by Cyphre, sponsored by Robert
		
		if scroll <> face/para/scroll [
			face/para/scroll: scroll
			if face/type = 'area [face/key-scroll?: true]
		]

		;on-dirty handling (field only)
		if all [
			face/type = 'field function?
			get in face 'dirty-action
			face/text <> orig-text
		][
			face/dirty-action face
		]
		show face
	]

	feel: make object! [
		
		redraw: detect: over: none

		engage: func [face action event /local start end total visible] [
			if all [in face 'selectable? not face/selectable?][exit]
			switch action [
				key [
					if all [in face 'editable? not face/editable?][exit]
					edit-text face event
				]
				down [
					either event/double-click [
						all [view*/caret not empty? view*/caret current-word view*/caret] ;fixed by Cyphre, sponsored by Robert
					][
						either face <> view*/focal-face [
							if all [
							 	view*/focal-face
								find view*/focal-face/options 'input-grid-item
								get in view*/focal-face/parent-face 'cell-action
							][
								view*/focal-face/parent-face/do-action view*/focal-face get in view*/focal-face/parent-face 'cell-action
							]					
							focus face
						] [unlight-text]
						view*/caret: offset-to-caret face event/offset
						show face
					]
				]
				over [
					unless equal? view*/caret offset-to-caret face event/offset [
						unless view*/highlight-start [view*/highlight-start: view*/caret]
						view*/highlight-end: view*/caret: offset-to-caret face event/offset
						show face
					]
				]
				scroll-line [
					do bind [
						;total: face/text-y ; use the stored text height
						total: second size-text face ; calculate text height now 
						visible: size/y - (edge/size/y * 2) - para/origin/y - para/indent/y

						para/scroll/y: min max para/scroll/y - (event/offset/y * sizes/font-height) (visible - total) 0

						; Update slider dragger position to reflect para/scroll/y
						; para/scroll is relative to  edge/size + para/origin + (para/indent * 0x1)
						all [pane pane/data: - para/scroll/y / (total - visible)] ;fixed by Cyphre, sponsored by Robert
						

					] face
					show face
				]
				scroll-page [
					do bind [
						total: second size-text face ; calculate text height now 
						visible: size/y - (edge/size/y * 2) - para/origin/y - para/indent/y

						para/scroll/y: min max para/scroll/y - (visible * sign? event/offset/y) (visible - total) 0

						; Update slider dragger position to reflect para/scroll/y
						; para/scroll is relative to  edge/size + para/origin + (para/indent * 0x1)

						all [pane pane/data: - para/scroll/y / (total - visible)] ;fixed by Cyphre, sponsored by Robert

					] face
					show face
				]
			]
		]
	]
]
