tool
extends ConceptNode

var default: Curve

func _init() -> void:
	unique_id = "inspector_curve_2d"
	display_name = "Curve property"
	category = "Inspector properties"
	description = "Expose a 2D curve value to the inspector"

	set_input(0, "Name", ConceptGraphDataType.STRING, {"disable_slot": true})
	set_input(1, "Default", ConceptGraphDataType.MATH_CURVE)
	set_output(0, "", ConceptGraphDataType.MATH_CURVE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")

	default = Curve.new()
	default.add_point(Vector2(0.0, 0.0))
	default.add_point(Vector2(1.0, 1.0))


func _generate_outputs() -> void:
	var name: String = get_input_single(0)
	var value: Curve = get_parent().get_value_from_inspector(name)

	if not value:
		value = get_input_single(1, default)

	output[0] = value.duplicate()


func get_exposed_variables() -> Array:
	var name: String = get_input_single(0)
	if not name:
		return []

	return [{
		"name": name,
		"type": ConceptGraphDataType.MATH_CURVE,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Curve",
		"default_value": get_input(1, default),
		}]


func _on_input_changed(slot: int, _value) -> void:
	if slot == 0:
		get_parent().update_exposed_variables()
