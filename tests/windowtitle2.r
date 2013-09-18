REBOL [
	title: "Refresh window title playground"
]

do %../../framework/libraries/rebgui.r
do %../../framework/libraries/window-manage.r
print ""

data-set: []

ctx-rebgui/debug/redraws: true ; shows that only one redraw occurs

repeat i 20000 [append data-set checksum form i] ; 10000 rows

lay: make-window [
	button 25 "update title" [
; when all are commented out, table is refreshed properly
;		lay/changes: 'offset ; works ok
;		lay/changes: 'minimize ; works ok
;		lay/changes: 'maximize ; works ok
;		lay/changes: 'restore ; works ok
		lay/changes: 'text ; [!] - does not refresh table properly
;		lay/changes: 'activate ; [!] - does not refresh table properly

		disable-show ; prevents SHOW from occurring

		; first table
		t1/set-columns reduce options
		insert t1/data data-set
		t1/redraw

		; second table
		t2/data: copy data-set
		t2/redraw
		; fiddle with the table to see if that helps redraw
		t2/select-row/no-action 1
		t2/go-to 1

;		enable-show lay ; enables SHOW; this single SHOW must update title and table

		enable-show none ; enables SHOW, but does not perform SHOW
		ctx-rebgui/show-native lay ; perform REBOL/View native SHOW
	]
	return
	t1: table #HW 189x35
	return
	t2: table #XH 189x35 options [disable-sort no-return-key]
	return
] []

open-window "test" lay

options: [
	"foo" 'left 200
	mold now/precise 'center 200
]

t2/set-columns reduce options
do-events

quit