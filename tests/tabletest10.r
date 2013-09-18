REBOL [
	title: "Table 8 Playground, last column width problem"
]

do %../../framework/libraries/rebgui.r
print ""
render-cell: [face/color: red]

data-set: load %list-base-data.txt

display "test" [
	t: table #WH 125x50 options [multi resize-last-column-only no-column-resize on-render-cell render-cell "a" left 50 "b" center 50 "d" right 50 "d" right 50] [print "table-function"]
]

options: ["ID" right 40 "In Set" center 46 "In Graph" center 46 "Used" center 44 "Base" center 30 "Set" center 30 "Preis / price [€] (P) * (P) *" tool-tip right 44 num-sort {Jahresbedarf / anual quantity [Stk / pcs] (Q) * (Q) *} tool-tip right 65 num-sort "Maße klein_d (PD) (PD)" tool-tip right 50 num-sort "Maße groß_D (PD) (xPD)" tool-tip right 50 num-sort "Maße B (PD) (PD)" tool-tip right 44 num-sort "Audit Price (P)" tool-tip right 26 num-sort]

t/set-columns options
insert clear t/data data-set
t/redraw

do-events

quit

;halt