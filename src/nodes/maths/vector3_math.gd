tool
extends ConceptNode

"""
Perform common math operations on two Vector3
"""

var _opts = {"allow_lesser": true}

func _init() -> void:
	unique_id = "math_vector3"
	display_name = "Math (Vector3)"
	category = "Maths"
	description = "Perform common math operations on two Vector3"


	set_input(0, "", ConceptGraphDataType.STRING, \
		{"type": "dropdown",
		"items": {
			"Add": 0,
			"Substract": 1,
			"Cross product": 2,
			"Dot product": 3,
			"Bounce": 4,
			"Normalize": 5,
			"Floor": 6,
			"Ceil": 7
		}})
	set_input(1, "A", ConceptGraphDataType.VECTOR3, _opts)
	set_input(2, "B", ConceptGraphDataType.VECTOR3, _opts)
	set_output(0, "", ConceptGraphDataType.VECTOR3)
	_setup_inputs()


func _generate_outputs() -> void:
	var operation: String = get_input_single(0, "Add")
	var a: Vector3 = get_input_single(1, Vector3.ZERO)
	var b: Vector3 = get_input_single(2, Vector3.ZERO)

	match operation:
		"Add":
			output[0] = a + b
		"Substract":
			output[0] = a - b
		"Cross product":
			output[0] = a.cross(b)
		"Dot product":
			output[0] = a.dot(b)
		"Bounce":
			output[0] = a.bounce(b)
		"Normalize":
			output[0] = a.normalized()
		"Floor":
			output[0] = a.floor()
		"Ceil":
			output[0] = a.ceil()


func _on_default_gui_interaction(_value, _control, slot):
	if slot == 0:
		_setup_inputs()


func _setup_inputs() -> void:
	var operation: String = get_input_single(0, "Add")
	match operation:
		"Add", "Substract", "Cross product", "Bounce":
			set_output(0, "", ConceptGraphDataType.VECTOR3)
			set_input(2, "B", ConceptGraphDataType.VECTOR3, _opts)

		"Dot product":
			set_output(0, "", ConceptGraphDataType.SCALAR)
			set_input(2, "B", ConceptGraphDataType.VECTOR3, _opts)

		"Normalize", "Floor", "Ceil":
			set_output(0, "", ConceptGraphDataType.VECTOR3)
			remove_input(2)

	regenerate_default_ui()
