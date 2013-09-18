rebol []

do %../../framework/libraries/rebgui.r
print ""

; grid column widths issues

lo: [
	g: grid #HW 206x35 data [ ; [1] - NOTE: 80 + 92 + 30 + 4 = 206 = exact width of grid
		header 			["Input Column" "Values" "Column Type"]
		content 		[
			["a" 1 "Unknown"]
			["b" 2 "Test"]
			["c" 3 "Master"]
			["d" 4 "Price"]
			["e" 5 "Unknown"]
			["f" 6 "Driver"]
			["g" 7 "Quantity"]
		]
		row-spec		[
			[text red 80x5 font [style: 'bold align: 'right valign: 'middle] para [wrap?: none]]
			[text blue 92x5 #WP para [wrap?: none]] ; [2] - resizes only half way, when maximizing
			[drop-list 30x5 ["a" "b"
				; [3] - do not resize drop-list at all, only move it. #X has no effect.
				; [4, 5, 6] - observed behavior, may be the result of not calculating the vertical scroller in, when calculating the horizontal scroller:
				; [4] - when drop-list is 30 wide, a horizontal scroller appears, when maximizing and unmaximizing (possibly incorrect)
				; [5] - when drop-list is 29 instead of 30 wide, a horizontal scroller does not appear, when maximizing and unmaximizing (possibly correct)
				; [6] - when drop-list is 29 instead of 30 wide, you can see that the drop list becomes 30 wide, when maximizing and unmaximizing
				; [7] - when resizing, the bottom row gets cut off, if the vertical size of the list isn't multiplied by the cell-height and the final row is taller than one half cell-height.
				; [8] - NOTE: when dragging the v-scroller right at start, the drop-list becomes a tad wider as a result of redraw (correct behavior). See [13].
				; [9] - the header width of the center column does not match the column width, so the third header is 2 pixels to the left of where it should be.
				; [10] - the left edge of first header creeps to the right when resizing horizontally upwards extremely.
				; [11] - increasing drop-list in width to 50 causes a horizontal scroller to appear, which behaves erratically.
				; [12] - when drop list is 35 wide, it matches the width of the entire grid, including the scrollbar. only then does the horizontal scroller appear. it should appear, when the drop-list is 30 wide to include the vertical scrollbar.
			]]
		]
	]
]

ll: ctx-rebgui/layout copy/deep lo
g/redraw ; [13] - enable this for the width to be correct, so this is probably correct behavior. this is disabled, so you can see what the REDRAW does, if you do [8]
display "" ll
do-events