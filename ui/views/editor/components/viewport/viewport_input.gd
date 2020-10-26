extends ViewportContainer

# Allows the viewport and its child object to receive events, otherwise the
# first mouse blocking parent consumes every events automatically. 

onready var _viewport = $Viewport


func _gui_input(event):
	_viewport.unhandled_input(event)
