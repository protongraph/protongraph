tool
extends ConceptNode


func _init() -> void:
	unique_id = "inspector_bool"
	display_name = "Boolean property"
	category = "Inspector properties"
	description = "Expose a Boolean value to the inspector"

	set_input(0, "Name", ConceptGraphDataType.STRING, {"disable_slot": true})
	set_input(1, "Default", ConceptGraphDataType.BOOLEAN, {"disable_slot": true})
	set_output(0, "", ConceptGraphDataType.BOOLEAN)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_output(idx: int) -> bool:
	var name: String = get_input_single(0)
	var value = get_parent().get_value_from_inspector(name)

	if not value:
		return get_input_single(1, false)

	return value


func get_exposed_variables() -> Array:
	var name: String = get_input_single(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.BOOLEAN,
		"default_value": get_input_single(1, false),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0:
		get_parent().update_exposed_variables()
