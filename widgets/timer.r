timer: make rebface [
	feel: make default-feel [
		redraw: none
		engage: make function! [face act event] [
			if act = 'time [
				face/action face
			]
		]
		detect: none
	]

	last-rate: none
	timer-state: 'stop
		
	set-rate: make function! [
		timer-rate
	][
		last-rate: rate: timer-rate
		if timer-state = 'run [
			show self
		]
	]
	
	get-state: make function! [][
		timer-state
	]
	
	start: make function! [][
		unless timer-state = 'run [
			rate: last-rate
			show self
			timer-state: 'run
		]
	]

	stop: make function! [][
		unless timer-state = 'stop [
			last-rate: rate
			rate: none
			show self
			timer-state: 'stop
		]
	]
	
	init: make function! [] [
		size: 1x1
		offset: -1000000x-1000000
		if rate [timer-state: 'run]
	]
]
