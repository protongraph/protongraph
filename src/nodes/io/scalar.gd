tool
extends ConceptNode


var _spinbox: SpinBox


func _init() -> void:
	node_title = "Scalar"
	category = "Input"
	description = "Returns a number"

	var opts = {
		"disable_slot": true,
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}

	set_input(0, "Name", ConceptGraphDataType.STRING)
	set_input(1, "Value", ConceptGraphDataType.SCALAR, opts)
	set_input(2, "Export", ConceptGraphDataType.BOOLEAN, {"disable_slot": true})
	set_output(0, "", ConceptGraphDataType.SCALAR)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func get_output(idx: int) -> float:
	var expose = get_input(2, false)
	var name = get_input(0)
	if not expose or not name:
		return get_input(1)

	return get_parent().get_value_from_inspector(name)


func get_exposed_variables() -> Array:
	var name = get_input(0)
	if not name or not get_input(2):
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.SCALAR,
		"default_value": get_input(1),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0 or slot == 2:
		get_parent().update_exposed_variables()
