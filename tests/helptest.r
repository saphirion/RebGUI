rebol [
	title: "Help system test"
	author: "Richard Smolak"
]

do %../../framework/libraries/rebgui.r
;include %../rebgui-ctx.r 
print ""

set-help-function func [
	help-mode [word!]
	help-face [object!]
][
	print ["Face with HELP:" mold help-face/help "clicked!" newline "HELP-MODE:" help-mode]
	show-data help-check none
]

set-help-face-function func [
	mouse-offset [pair!]
	help-face [object! none!]
][
	either help-face [
		print ["HELP face over called at mouse position:" mouse-offset newline "HELP-FACE/HELP:" mold help-face/help]
	][
		print ["Mouse moved away from the HELP face."]
	]
]

add-key-shortcut false false #f3 [
	set-help-mode unless word? get-help-mode ['help-3]
]

display "Help system test" [
	help-check: check "help mode state" [
		set-help-mode all [face/data 'help-3]
	]
	return
	button "test" [print "TEST button action called!"] help [help-1 help-2] tool-tip "hello"
		area "hello world" help 'help-2
	return
	check "help checkmark" help 'help-2
	drop-list data ["a" "b" "c"] help 'help-3
	return
	t: table 67x50
		options ["a" left .25 num-sort "b" left .25 num-sort "c" left .25 num-sort "d" left .25 num-sort]
		data [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
		help 'help3
	return
	button 50 "open window" [
		display/dialog "new window" [
			field help 'help-1
			return
			button 30 "close me" [hide-popup]
		]
	]
]

do-events