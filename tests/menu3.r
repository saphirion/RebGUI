rebol []

include %../rebgui-ctx.r 
print ""

; problem with menu getting a scroll bar, when it's a certain distance to the task bar:

; 1. move the window so that the red box bottom is aligned with the top of the taskbar
; 2. and start right clicking around the red box. you will notice that when right clicking at the top of the red box the length of the menu is somewhat similar to the length of the box, but then adds a scroller to the menu and leaves out a menu item instead of simply moving the menu above the mouse cursor

view display "" [
	b: box red 20x20
]

add-ctx-menu b [
	"a" []
	"b" []
	"c" []
	"d" []
]

do-events
