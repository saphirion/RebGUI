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

files: 1
bytes: size? %rebgui-ctx.r

string: find code "#include"

while [not none? string] [
	;	find start and end of #include
	p1: index? string
	p2: index? find string ".r"
	;	extract source file name
	f: second to block! copy/part at code p1 2 + p2 - p1
	print f
	;	increment file and byte count
	files: files + 1
	bytes: bytes + size? f
	;	replace #include with referenced source file
	remove/part at code p1 2 + p2 - p1
	insert at code p1 mold/only/flat load f
	;	find next #include
	string: find code "#include"
]

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

print rejoin [
	"^/Files===> " files
	"^/Bytes===> " bytes
	"^/Into====> " n: size? %rebgui.r " bytes"
	"^/Saving==> " to integer! 1 - (n / bytes) * 100 "%"
]

halt