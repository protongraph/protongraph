tool
extends ProtonNode


func _init() -> void:
	unique_id = "inspector_vector2"
	display_name = "Vector2 Property"
	category = "Inputs/Inspector"
	description = "Expose a Vector2 value to the inspector"

	set_input(0, "Name", DataType.STRING)
	set_input(1, "Default", DataType.VECTOR2)
	set_input(2, "Section", DataType.STRING)
	set_output(0, "", DataType.VECTOR3)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var name: String = get_input_single(0, "")
	var value = get_parent().get_value_from_inspector(name)

	if value == null:
		value = get_input_single(1, Vector2.ZERO)

	output[0] = value


func get_exposed_variables() -> Array:
	var name: String = get_input_single(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": DataType.VECTOR2,
		"default_value": get_input_single(1, Vector2.ZERO),
		"section": get_input_single(2, ""),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0 or slot == 2:
		get_parent().update_exposed_variables()
