extends Label
tool

var base: float = 0.0
var count: float = 0.0
var running: bool = false
var dots = 10

func start():
	base = OS.get_ticks_msec()
	running = true

func _process(delta):
	if running:
		text = ""
		for i in dots:
			text += "."
		dots += 1
		if dots > 10:
			dots = 0
#
func _stop(x):
	running = false
	count = OS.get_ticks_msec() - base
	text = "Total Time: %s msecs" % count as String
	update()
