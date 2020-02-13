tool
class_name ConceptNodeScalar
extends ConceptNode


var _spinbox: SpinBox

func _init() -> void:
	node_title = "Scalar"
	category = "Input"
	description = "Returns a number"

	set_output(0, "Value", ConceptGraphDataType.SCALAR)


func _ready() -> void:
	_spinbox = SpinBox.new()
	_spinbox.max_value = 1000
	_spinbox.min_value = -1000
	_spinbox.step = 0.001
	_spinbox.allow_greater = true
	_spinbox.allow_lesser = true
	_spinbox.connect("value_changed", self, "_on_value_changed")
	add_child(_spinbox)


func get_output(idx: int) -> float:
	return _spinbox.value


func export_custom_data() -> Dictionary:
	return {"value": _spinbox.value}


func restore_custom_data(data: Dictionary) -> void:
	if data.has("value"):
		_spinbox.value = data["value"]


func _on_value_changed(val) -> void:
	reset()
