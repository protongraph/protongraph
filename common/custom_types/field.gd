class_name Field
extends RefCounted


var _default_value: Variant
var _generator: Callable
var _list: Array
var _current_index: int


func set_default_value(value) -> void:
	_default_value = value


func set_list(list: Array) -> void:
	_list = list.duplicate()
	_current_index = 0


func set_generator(generator: Callable) -> void:
	_generator = generator


func get_value() -> Variant:
	if _generator:
		return _execute()

	return _default_value


func _execute() -> Variant:
	print("in execute")
	if _list.is_empty():
		print("empty list, ")
		return _generator.call()

	if _current_index >= _list.size():
		_current_index = 0

	var item = _list[_current_index]
	_current_index += 1
	print("item: ", item, " ", item.transform.origin)
	print("calling ", _generator)

	return _generator.call(item)


func _to_string() -> String:
	return "[Field: " + str(get_value()) + "]"
