tool
extends ConceptNode


func _init() -> void:
	node_title = "Vector property"
	category = "Inspector properties"
	description = "Expose a Vector3 value to the inspector"

	set_input(0, "Name", ConceptGraphDataType.STRING, {"disable_slot": true})
	set_input(1, "Default", ConceptGraphDataType.VECTOR)
	set_output(0, "", ConceptGraphDataType.VECTOR)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func get_output(idx: int):
	var name = get_input(0)
	if not name:
		return get_input(1, Vector3.ZERO)

	return get_parent().get_value_from_inspector(name)


func get_exposed_variables() -> Array:
	var name = get_input(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.VECTOR,
		"default_value": get_input(1),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0:
		get_parent().update_exposed_variables()
