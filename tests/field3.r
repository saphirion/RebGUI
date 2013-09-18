rebol []

do %../../framework/libraries/rebgui.r
print ""

; when setting the cursor over "abcde" with mouse down and dragging out of the field, the field is unfocused on mouse release.

display "" [
	field "abcde"
]
do-events