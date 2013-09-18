plate: make rebface [
	state-words: [
		text
		show?
	]
	state-action: make function! [word [word!] value /local p] [
		p: self
		switch/default word [
			text [p/text: :value]
		][
			set in p word :value
		]
	]
]