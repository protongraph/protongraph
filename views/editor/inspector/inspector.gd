extends ScrollContainer
class_name InspectorPanel


var _root: Control
var _exposed_variables := {}


func _ready() -> void:
	_root = get_node("VBoxContainer")
	_regenerate_inspector_ui()


func update_variables(variables: Array) -> void:
	var old = _exposed_variables
	_exposed_variables = {}

	for v in variables:
		if _exposed_variables.has(v.name):
			continue

		var value = old[v.name]["value"] if old.has(v.name) else v["default_value"]
		v["value"] = value
		_exposed_variables[v.name] = v

	_regenerate_inspector_ui()


func _regenerate_inspector_ui() -> void:
	_clear_inspector()

	var sections = {}

	for vname in _exposed_variables.keys():
		var v = _exposed_variables[vname]
		var s
		if sections.has(v.section):
			s = sections[v.section]
		else:
			s = _create_section(v.section)
			_root.add_child(s)
			sections[v.section] = s

		var control = _get_control_for(v)
		if not control:
			return

		s.add_child(control)


func _clear_inspector() -> void:
	for c in _root.get_children():
		_root.remove_child(c)
		c.queue_free()


func _create_section(name: String) -> Control:
	if name == "":
		name = "General"

	var s = preload("section.tscn").instance()
	s.set_name(name.capitalize())
	return s


func _get_control_for(v):
	var ui
	match v.type:
		ConceptGraphDataType.SCALAR:
			ui = preload("scalar_property.tscn").instance()
		ConceptGraphDataType.BOOLEAN:
			ui = preload("bool_property.tscn").instance()

	if ui:
		ui.init(v.name, v.value)
		return ui

	return null
