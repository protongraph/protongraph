extends Node

const TEST: bool = true
const YIELD: String = "finished"
const CRASH_IF_TEST_FAILS: bool = true

var asserts: Reference
var direct: Reference
var rerun_method: bool = false

# This is used to access variable data with the user test
# e.g assert.is_equal(p.augend + p.addend, p.result, etc;
var p: Dictionary
 
var _watcher: Reference
var _parameters: Reference
var _yielder: Timer
var _testcase: Reference
var _recorder: Script

signal described

func methods() -> PoolStringArray:
	var output: PoolStringArray = []
	for method in get_method_list():
		if method.name.begins_with("test"):
			output.append(method.name)
	return output
	
func setup(assertions, yielder, testcase, director, 
           signal_watcher, parameters, recorder):
	asserts = assertions
	direct = director
	_testcase = testcase
	_yielder = yielder
	_watcher = signal_watcher
	_parameters = parameters
	_recorder = recorder
	
func record(who: Object, properties: Array) -> Node:
	var record = _recorder.new()
	record.record(who, properties)
	add_child(record)
	return record
	
func _ready() -> void:
	p = _parameters.parameters
	asserts.connect("asserted", _testcase, "_on_asserted")
	connect("described", _testcase, "_on_test_method_described")

func any():
	return preload("any.gd").new()

func describe(message: String) -> void:
	emit_signal("described", message)

func parameters(list: Array) -> void:
	rerun_method = _parameters.parameters(list)

func path() -> String:
	var path = get_script().get_path()
	return path if path != "" else get_script().get_meta("path")
	
func title() -> String:
	var path: String = get_script().get_path()
	var substr: String = path.substr(path.find_last("/") + 1, 
	path.find(".gd")).replace(".gd", "").replace("test", "").replace(".", " ").capitalize()
	return substr

func watch(emitter, event: String) -> void:
	_watcher.watch(emitter, event)
	
func unwatch(emitter, event: String) -> void:
	_watcher.unwatch(emitter, event)

## Untested
## Thanks to bitwes @ https://github.com/bitwes/Gut/
func simulate(obj, times, delta):
	for i in range(times):
		if(obj.has_method("_process")):
			obj._process(delta)
		if(obj.has_method("_physics_process")):
			obj._physics_process(delta)

		for kid in obj.get_children():
			simulate(kid, 1, delta)

func until_signal(emitter: Object, event: String, time_limit: float) -> Node:
	watch(emitter, event)
	return _yielder.until_signal(time_limit, emitter, event)

func until_timeout(time_limit: float) -> Node:
	return _yielder.until_timeout(time_limit)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_watcher.clear()
