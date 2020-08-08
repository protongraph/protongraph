tool
extends ConceptNode


func _init() -> void:
	ignore = true
	unique_id = "inspector_spatial_material"
	display_name = "Material Property"
	category = "Inputs/Inspector"
	description = "Expose a material to the inspector"

	set_input(0, "Name", ConceptGraphDataType.STRING)
	set_input(1, "Default", ConceptGraphDataType.MATERIAL)
	set_input(2, "Section", ConceptGraphDataType.STRING)
	set_output(0, "", ConceptGraphDataType.MATERIAL)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var name: String = get_input_single(0, "")
	var value = get_parent().get_value_from_inspector(name)

	if not value:
		value = get_input_single(1)

	output[0] = value


func get_exposed_variables() -> Array:
	var name: String = get_input_single(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.MATERIAL,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Material",
		"default_value": get_input_single(1, null),
		"section": get_input_single(2, ""),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0 or slot == 2:
		get_parent().update_exposed_variables()
