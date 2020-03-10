tool
extends ConceptNode


var _spinbox: SpinBox


func _init() -> void:
	node_title = "Scalar"
	category = "Input"
	description = "Returns a number"

	var opts = {
		"disable_slot": true,
		"max_value": 1000,
		"min_value": -1000,
		"allow_greater": true,
		"allow_lesser": true,
	}

	set_input(0, "Name", ConceptGraphDataType.STRING)
	set_input(1, "Value", ConceptGraphDataType.SCALAR, opts)
	set_input(2, "Export", ConceptGraphDataType.BOOLEAN, {"disable_slot": true})
	set_output(0, "", ConceptGraphDataType.SCALAR)


func _ready() -> void:
	connect("node_changed", self, "_on_node_changed")
	_on_node_changed(null, null)


func get_output(idx: int) -> float:
	var expose = get_input(2, false)
	if not expose:
		return get_input(1)

	return get_parent().get_value_from_inspector(get_input(0))


func _on_node_changed(_node, _value):
	if not get_input(2):
		return
	var name = get_input(0, "Scalar")
	if not get_parent().expose_to_inspector(name, ConceptGraphDataType.SCALAR, 0):
		set_default_gui_input_value(2, false) # Turn it off to avoid conflict
		# TODO : find a better way to signal naming conflicts to the user
