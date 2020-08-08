tool
extends ConceptNode

var default: Curve

func _init() -> void:
	unique_id = "inspector_curve_2d"
	display_name = "Curve Property"
	category = "Inputs/Inspector"
	description = "Expose a 2D curve value to the inspector"

	set_input(0, "Name", ConceptGraphDataType.STRING, {"disable_slot": true})
	set_input(1, "Default", ConceptGraphDataType.CURVE_FUNC)
	set_input(2, "Section", ConceptGraphDataType.STRING)
	set_output(0, "", ConceptGraphDataType.CURVE_FUNC)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")

	default = Curve.new()
	default.add_point(Vector2(0.0, 0.0))
	default.add_point(Vector2(1.0, 1.0))


func _generate_outputs() -> void:
	var name: String = get_input_single(0, "")
	var value = get_parent().get_value_from_inspector(name)

	if not value:
		value = get_input_single(1, default)

	output[0] = value.duplicate()


func get_exposed_variables() -> Array:
	var name: String = get_input_single(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.CURVE_FUNC,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Curve",
		"default_value": get_input_single(1, default),
		"section": get_input_single(2, ""),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0 or slot == 2:
		get_parent().update_exposed_variables()
