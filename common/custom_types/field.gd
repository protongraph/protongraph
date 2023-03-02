class_name Field
extends RefCounted


var _default_value: Variant
var _generator: Callable


func set_default_value(value) -> void:
	_default_value = value


func set_generator(generator: Callable) -> void:
	_generator = generator


func get_value() -> Variant:
	if _generator:
		return _generator.call()

	return _default_value


func _to_string() -> String:
	return "[Field: " + str(get_value()) + "]"
