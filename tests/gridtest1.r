REBOL [
	title: "Grid Playground, content generation"
]

do %../../framework/libraries/rebgui.r
print ""
render-cell: [face/color: red]

window: ctx-rebgui/layout [
	margin 2x2
	space 1x1
	pds: grid #HW 100x100 data [
		header			["a" "resizable" "c" "X"] ; [1] - header size doesn't follow content size
		content			[
			["a" 5 "Not Recommended" #[false]] ; [2] - *this* content disappears after resizing
			["c" 0.01 "Not Recommended" #[true]]
		]
		row-spec		[
			[text 40 font [valign: 'middle] para [wrap?: none]]
			[text #W 20 font [align: 'right valign: 'middle] para [wrap?: none]]
			[text #W 30 font [valign: 'middle] para [wrap?: none]]
			[check #X 5 []] ; [4] - scroller area disappears after resizing
		]
	]
	panel #WX data [
		space 1x1
		button 25 "Quit" [quit] return
		button 25 "Problem 1" [ ; [5] - header width is altered slightly after changing the content only
			insert pds/data/content test-content
			insert pds/data/visible-rows [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28]
			pds/set-data pds/data ; [6] - apparently there is a difference between this and passing content in the layout code
			probe pds/data
			pds/redraw
		]
	]
]

pds/sort-columns?: false
pds/hilite-cell?: false
pds/hilite-row?: false
clear pds/data/visible-rows
clear pds/data/content
test-content: [ ; [3] - maximizing and unmaximizing corrupts the size of *this* content
	["a" 5 "Start" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 2 "Not Recommended" #[false]]
	["c" 0.41 "Not Recommended" #[true]]
	["a" 1 "Not Recommended" #[false]]
	["c" 0.61 "Not Recommended" #[true]]
	["a" 22 "Not Recommended" #[false]]
	["c" 0.71 "Not Recommended" #[true]]
	["a" 11 "Not Recommended" #[false]]
	["c" 0.251 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 5 "Not Recommended" #[false]]
	["c" 0.01 "End" #[true]]
]
display "test" window

do-events

quit

;halt