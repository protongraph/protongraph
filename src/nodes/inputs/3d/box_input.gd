tool
extends ConceptNode


var _box: ConceptBoxInput


func _init() -> void:
	unique_id = "input_box"
	display_name = "Input Box"
	category = "Inputs/Boxes"
	description = "Expose one or multiple boxes from the editor to the graph"

	set_input(0, "", ConceptGraphDataType.STRING, {"placeholder": "Box Name"})
	set_input(1, "Position", ConceptGraphDataType.VECTOR3)
	set_input(2, "Rotation", ConceptGraphDataType.VECTOR3)
	set_input(3, "Scale", ConceptGraphDataType.VECTOR3)
	set_output(0, "", ConceptGraphDataType.BOX_3D)

	_box = ConceptBoxInput.new()


func export_custom_data() -> Dictionary:
	return {}


func restore_custom_data(data: Dictionary) -> void:
	pass


func get_manipulable_input_node() -> Spatial:
	return _box


func _generate_outputs() -> void:
	var input_name: String = get_input_single(0, "")
	var input = get_editor_input(input_name)

	if not input:
		return

	if input is ConceptBoxInput:
		output[0].append(input)
	for c in input.get_children():
		if c is ConceptBoxInput:
			output[0].append(c)
