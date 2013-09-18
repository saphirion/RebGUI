REBOL [
	title: "Table 23 Playground, table columns crash"
]

; produce the error by:
; 1. use the f1 key to switch between table layouts
; 2. hover the mouse over the table, over the table contents
; 3. switch the table layout
; 4. crash:
;    ** Script Error: Cannot use path on none! value
;    ** Where: wake-event
;    ** Near: cell/offset/x: col-offset cell/size/x: p/widths/:i -
; Notes:
;    it seems to happen only when adding, not removing columns

do %../../framework/libraries/rebgui.r
print ""

; use 2 different column setups
types: [
	["a" center 300]
	["boo" center 100 "foo" center 100]
]

; table layout
display "Table" [
	t: table 100x50 data ["1" "2" "3" "4"]
]

; function to switch between table layouts
set-table-columns: does [
	types: next types
	if tail? types [types: head types]
	t/set-columns probe first types
]

; keyboard shortcut to switch between the 2 column setups
add-key-shortcut false false #f1 [set-table-columns]

set-table-columns

do-events

quit