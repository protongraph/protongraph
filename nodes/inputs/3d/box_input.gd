extends ProtonNode


var _box: BoxInput
var _updating := false


func _init() -> void:
	unique_id = "input_box"
	display_name = "Input Box"
	category = "Inputs/Boxes"
	description = "Expose one or multiple boxes from the editor to the graph"

	set_input(0, "", DataType.STRING, {"placeholder": "Box Name"})
	set_input(1, "Position", DataType.VECTOR3)
	set_input(2, "Rotation", DataType.VECTOR3)
	set_input(3, "Scale", DataType.VECTOR3, {"value": 1})
	set_output(0, "", DataType.MASK_3D)

	_box = BoxInput.new()
	_box.name = "Unnamed Box"
	Signals.safe_connect(_box, "input_changed", self, "_on_box_input_changed")


func _enter_tree() -> void:
	get_parent().register_input_object(_box, self)


func _exit_tree() -> void:
	get_parent().deregister_input_object(_box, self)


func _on_editor_data_restored() -> void:
	_update_name()


func _generate_outputs() -> void:
	var input_name: String = get_input_single(0, "")
	output[0] = _box.duplicate(7)


func _update_name() -> void:
	_box.name = get_input_single(0, "Unnamed Box")
	_box.emit_signal("input_changed", self)


func _on_default_gui_interaction(_value, _control: Control, slot: int) -> void:
	if _updating:
		return

	match slot:
		0:
			_update_name()
		1:
			_box.transform.origin = get_input_single(1, Vector3.ZERO)
		2:
			_box.rotation_degrees = get_input_single(2, Vector3.ZERO)
		3:
			_box.size = get_input_single(3, Vector3.ONE)


func _on_box_input_changed(_node) -> void:
	_updating = true

	set_default_gui_value(1, _box.transform.origin)
	set_default_gui_value(2, _box.rotation_degrees)
	set_default_gui_value(3, _box.size)

	_updating = false
