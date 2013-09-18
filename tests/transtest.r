REBOL [
	title: "Table 8 Playground, last column width problem"
]

do %../../framework/libraries/rebgui.r

load-locale [
	language: "TEST" 
	words: [
		"Translate it" "Translated OK"
		"translate it" "translated ok"
	]
]

display "test" [
	button 100 "<loc>Translate it"
	return
	button 100 "<loc>translate it"
]


do-events

