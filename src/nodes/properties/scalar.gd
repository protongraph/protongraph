tool
extends ConceptNode


func _init() -> void:
	node_title = "Scalar property"
	category = "Properties"
	description = "Expose a Scalar value to the inspector"

	var opts = {
		"disable_slot": true,
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}

	set_input(0, "Name", ConceptGraphDataType.STRING, {"disable_slot": true})
	set_input(1, "Default", ConceptGraphDataType.SCALAR, opts)
	set_output(0, "", ConceptGraphDataType.SCALAR)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func get_output(idx: int) -> float:
	var name = get_input(0)
	if not name:
		return get_input(1)

	return get_parent().get_value_from_inspector(name)


func get_exposed_variables() -> Array:
	var name = get_input(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.SCALAR,
		"default_value": get_input(1),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0:
		get_parent().update_exposed_variables()
