rebol []

;do %../../framework/libraries/rebgui.r
include %../rebgui-ctx.r
print ""

; grid remembers its content, which is a problem
a: ""

display "" [button "Set" [a: b/text] button "Same?" [probe same? a b/text] b: button "My Button"]
do-events