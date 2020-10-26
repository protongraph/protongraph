extends "base_test.gd"
class_name WATTest

class State:
	const START: String = "start"
	const PRE: String = "pre"
	const EXECUTE: String = "execute"
	const POST: String = "post"
	const END: String = "end"
	
var _state: String
var _methods: Array = []
var _method: String
var time: float = 0.0
signal completed

func _ready() -> void:
	_yielder.connect("finished", self, "_next")
	add_child(_yielder)

func _next(vargs = null):
	# When yielding until signals or timeouts, this gets called on resume
	# We call defer here to give the __testcase method time to reach either the end
	# or an extra yield at which point we're able to check the _state of the yield and
	# see if we stay paused or can continue
	call_deferred("_change_state")
	
func _change_state() -> void:
	if _yielder.is_active():
		return
	match _state:
		State.START:
			_pre()
		State.PRE:
			_execute()
		State.EXECUTE:
			_post()
		State.POST:
			_pre()
		State.END:
			_end()
	
func _start():
	_state = State.START
	start()
	_next()
	
func _pre():
	time = OS.get_ticks_msec()
	if _methods.empty() and not rerun_method:
		_state = State.END
		_next()
		return
	_state = State.PRE
	pre()
	_next()
	
func _execute():
	_state = State.EXECUTE
	_method = _method if rerun_method else _methods.pop_back()
	_testcase.add_method(_method)
	call(_method)
	_next()
	
func _post():
	_testcase.methods.back().time = (OS.get_ticks_msec() - time) / 1000.0
	_state = State.POST
	post()
	_next()
	
func _end():
	_state = State.END
	end()
	emit_signal("completed")
	
func _exit_tree() -> void:
	queue_free()
	
func start():
	pass
	
func pre():
	pass
	
func post():
	pass
	
func end():
	pass
