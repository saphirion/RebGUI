rebol []

;do %../../framework/libraries/rebgui.r
include %../rebgui-ctx.r 
print ""

set-fonts/size/name 11 "Arial"

; test of menu style
act: [print "SOME ACT"]

add-ctx-menu 'bx has [x] [compose [(rejoin ["random item #" random 100]) "Hello" [print "hello"] "world" <bar> "this" act "is" <checked> "context" "menu"]]

make-random-items: has [result] [
	result: clear []
	repeat i random 10 [
		append result rejoin ["random item #" random 100]
;		append result to-issue join "#" i
	]
	result
]

add-menu-shortcut "Copy" [<ctrl> #c]

sub-menu: does [
	[
		"Item 2.1" 
		"Item 2.2" 
		"Submenu 2.3" <sub> [
			"Item 3.1"
			"Item 3.2"
			"Item 3.3" [print "3.3"]
		]
		"Item 2.4" [print "2.4"]
	]
]

make-main-menu: does [
	compose [
		(rejoin ["dynamic menu #" random 100]) :make-random-items
		"File" [
			<checked> "New"
			"Submenu" <sub> [
				"Item 1.1"
				"Submenu 1.2" <sub> sub-menu
				"Item 1.3" [print "1.3"]
			]
			"Open" <ctrl> <shift> #c [print "Open action"]
			<bar>
			<ghosted> "Save" [probe 'save]
			"Save As..." [probe 'saving-as]
		]
		"Edit" [
			"Cut" <ctrl> #x [print "CUT action"]
			"Copy"
			<checked> <ghosted> "Paste"
			<bar>
			"Undo"
			"Redo"
		]
		"Selection" [
			<ghosted> "Query..." <ctrl> #g [probe 'querying]
			<bar>
			"All"
			<ghosted> "Disabled item"
		]
	]
]


lay: display "" [
	button 40 "Menu should use this font" [show-title lay "boo"]
	return
	menu data :make-main-menu
	bx: box #W red 20x40 ; maximizing with an open menu does not redraw the window properly
	return
	at 0x20
	ar: area
]

sm: [
			<checked> "New"
			"Submenu" <sub> [
				"Item 1.1"
				"Submenu 1.2" <sub> [
					"Item 2.1" 
					"Item 2.2" 
					"Submenu 2.3" <sub> [
						"Item 3.1"
						"Item 3.2"
						"Item 3.3" [print "3.3"]
					]
					"Item 2.4" [print "2.4"]
				]
				"Item 1.3" [print "1.3"]
			]
			"Open" <ctrl> <shift> #c [print "Open action"]
			<bar>
			<ghosted> "Save" [probe 'save]
			"Save As..." [probe 'saving-as]
		]

;["Undo" [print "hop"] "Redo" <bar> "Cut" "Copy" "Paste" <ctrl> #p [print "paste action"] "Delete" <bar> "Select all"]

add-ctx-menu ar sm

do-events

;this is for dynamic menu removal
remove-ctx-menu ar
remove-ctx-menu 'bx
