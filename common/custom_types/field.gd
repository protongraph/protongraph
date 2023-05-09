class_name Field
extends RefCounted


var _default_value: Variant
var _generator: Callable
var _list := []
var _current_index: int


func set_default_value(value) -> void:
	_default_value = value


func set_list(list: Array) -> void:
	_list = list.duplicate()
	_current_index = 0


func set_generator(generator: Callable) -> void:
	_generator = generator


func get_value() -> Variant:
	# No generator and no list of pre-computed values, return the default.
	if not _generator.is_valid() and _list.is_empty():
		return _default_value

	# Only the generator, call it and return
	if _generator.is_valid() and _list.is_empty():
		return _generator.call()

	# List contains data. Pick the current one and update the index tracker.
	if _current_index >= _list.size():
		_current_index = 0

	var item = _list[_current_index]
	_current_index += 1



	# Only the list and no generator:
	if not _generator.is_valid():
		return item

	# Both generator and the list are present
	return _generator.call(item)


func _to_string() -> String:
	return "[Field: " + str(get_script()) + "]"
