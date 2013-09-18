rebol []

do %../../framework/libraries/rebgui.r
print ""

; perform action per key-press in field

display "" [
	f: field on-key [probe f/text]
]

do-events