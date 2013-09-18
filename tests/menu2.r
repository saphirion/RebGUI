rebol []

include %../rebgui-ctx.r 
print ""

set-fonts/size/name 11 "Arial"

lay: display "" [
	menu data [
		"Sub Menu Bug" [
			"Sub Menu 1 Here" <sub> ["a" "b" "c"]
			<ghosted> "Sub Menu 2 Here" <sub> ["a" "b" "c"] ; remove <ghosted> in this line and 3 items show
			<ghosted> "Sub Menu 3 Here" <sub> ["a" "b" "c"] ; [1] - this item does not show
			"Sub Menu 4 Here" <sub> ["a" "b" "c"] ; this item does not show
		]
		"Menu Bug 2" [
			<checked> "Checked Item 1"
			<ghosted> "Ghosted Item 2"
			<ghosted> <checked> "Checked ghosted item 3" ; [2] - does not show
			"Item 4" ; does not show
		]
	]
]

do-events
