tool
extends ProtonNode


func _init() -> void:
	unique_id = "inspector_scalar"
	display_name = "Number Property"
	category = "Inputs/Inspector"
	description = "Expose a number to the inspector"

	var opts = {
		"disable_slot": true,
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
		"value": 1,
	}

	set_input(0, "Name", DataType.STRING)
	set_input(1, "Default", DataType.SCALAR, opts)
	set_input(2, "Section", DataType.STRING)
	set_output(0, "", DataType.SCALAR)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var name: String = get_input_single(0, "")
	var value = get_parent().get_value_from_inspector(name)

	if value == null:
		value =  get_input_single(1, 0.0)

	output[0] = value


func get_exposed_variables() -> Array:
	var name: String = get_input_single(0, "")
	if not name:
		return []

	return [{
		"name": name,
		"type": DataType.SCALAR,
		"default_value": get_input_single(1, 1.0),
		"section": get_input_single(2, ""),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0 or slot == 2:
		get_parent().update_exposed_variables()
