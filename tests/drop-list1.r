rebol []

do %../../framework/libraries/rebgui.r
print ""

; test drop list

display "" [
	d: drop-list data ["a" "b" "c"]
]

d/popup-mode: 'outside

do-events