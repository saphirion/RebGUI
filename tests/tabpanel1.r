rebol []

do %../../framework/libraries/rebgui.r
print ""

; [1] - inequal margin around red box with blue edge. edge on or off has no effect on inequality.
; [2] - if changing the margin to 0x0, the right blue edge and bottom blue edge of the box are covered up

display "" [tab-panel data ["a" [margin 1x1 box 20x20 red edge [color: blue size: 1x1]]]]

do-events