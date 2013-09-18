rebol []

do %../../framework/libraries/rebgui.r
print ""

; focusing issues

main: ctx-rebgui/layout [f: password g: password]

; both password fields show a cursor

show-focus f

display/dialog/no-hide "" main
do-events