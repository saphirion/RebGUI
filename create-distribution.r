REBOL [
	Title:		"Create RebGUI distribution"
	Owner:		"Ashley G. Trüter"
	Version:	2.0.0
	Date:		7-May-2006
	Purpose:	"Merge RebGUI source files into a single file and remove unnecessary white-space."
	History: {
		1.0.0	Initial version based on prebol.r and prerebol.r from SDK.
		2.0.0	Removed SDK dependencies.
	}
	Note: {Changed by Ladislav to use INCLUDE}
]

code: make string! 150000
; insert code "REBOL []"
insert tail code mold/only/flat/all include/only %rebgui-ctx.r

bytes: length? code

;	remove newlines and surplus spaces
trim/lines code
;	compact block delimiters
replace/all code "[ " "["
replace/all code " ]" "]"
replace/all code " [" "["
replace/all code "] " "]"
;	compact expression delimiters
replace/all code "( " "("
replace/all code " )" ")"

write %rebgui.r code

write %../framework/libraries/rebgui.r code

print rejoin [
	"^/REBOL===> " system/version
	"^/Into====> " n: size? %rebgui.r " bytes"
	"^/Saving==> " to integer! 1 - (n / bytes) * 100 "%"
]

wait 2
