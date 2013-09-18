rebol []

do %../../framework/libraries/rebgui.r
print ""

; 1. click in a field in A to focus it
; 2. click the window title of B to activate it
; 3. field in A is not unfocused, which it should be.
; 4. press tab to navigate in the inactive window. this is a bug.

display "A" [
	field "abcde"
	field "test"
]

display "B" [
	box 10x10
]

do-events