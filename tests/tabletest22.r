REBOL [
	title: "Table 22 Playground, table instances"
]

do %../../framework/libraries/rebgui.r
print ""

prototype: [
	table 100x30 options [multi no-column-resize "a" center 0.5 "b" center 0.5]
]

; must copy/deep PROTOTYPE to prevent table options block from being modified

display "Table Dispenser" [
	button 25 "Create Table" [display form now/precise prototype]
]

do-events

quit