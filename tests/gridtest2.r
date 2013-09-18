rebol []

do %../../framework/libraries/rebgui.r
print ""

; grid remembers its content, which is a problem

lo: [
	g: grid 100x100 data [
		header ["a" "resizable" "c" "X"]
;		content [] ; this should not be required
		row-spec [
			[text 40 font [valign: 'middle] para [wrap?: none]]
			[text #W 20 font [align: 'right valign: 'middle] para [wrap?: none]]
			[text #W 30 font [valign: 'middle] para [wrap?: none]]
			[check #X 5 []] ; [4] - scroller area disappears after resizing
		]
	] button "Close" [unview]]

test-content: [ ; [3] - maximizing and unmaximizing corrupts the size of *this* content
	["a" 5 "Start" #[false]]
	["c" 0.01 "Not Recommended" #[true]]
	["a" 2 "Not Recommended" #[false]]
	["c" 0.41 "Not Recommended" #[true]]
	["a" 1 "Not Recommended" #[false]]
	["c" 0.61 "Not Recommended" #[true]]
	["a" 22 "Not Recommended" #[false]]
	["c" 0.71 "Not Recommended" #[true]]
]

ll: ctx-rebgui/layout copy/deep lo
insert g/content test-content
insert g/visible-rows [1 2 3 4 5 6 7 8]
display "" ll
do-events
ll: ctx-rebgui/layout lo
display "" ll
do-events
ll: ctx-rebgui/layout lo
display "" ll
do-events