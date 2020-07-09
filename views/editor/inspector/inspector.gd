extends ScrollContainer
class_name InspectorPanel


export var root: NodePath

var _root: Control
var _exposed_variables := {}
var _variables_ui := {}
var _cache = null


func _ready() -> void:
	_root = get_node(root)
	_regenerate_inspector_ui()


func update_variables(variables: Array) -> void:
	_exposed_variables = {}
	if not _cache: # Don't override the values cache if it already exists
		_cache = get_all_values()

	# Make sure there's no variables duplicates
	for v in variables:
		var vname = v.name.to_lower()
		if not _exposed_variables.has(vname):
			_exposed_variables[vname] = v

	# Regenerate the UI and restore values
	_regenerate_inspector_ui()
	set_all_values(_cache)
	_cache = null


func get_value(name):
	name = name.to_lower()
	if _variables_ui.has(name):
		return _variables_ui[name].get_value()
	return null


func get_all_values() -> Dictionary:
	var res = {}
	for vname in _variables_ui.keys():
		res[vname] = _variables_ui[vname].get_value()
	return res


func set_all_values(values) -> void:
	if _variables_ui.empty():
		_cache = values
		return # Inspector was not initialized yet, caching the values for later

	for vname in values.keys():
		vname = vname.to_lower()
		if _variables_ui.has(vname):
			_variables_ui[vname].set_value(values[vname])


func _regenerate_inspector_ui() -> void:
	_clear_inspector()

	var sections = {}

	for vname in _exposed_variables.keys():
		var v = _exposed_variables[vname]
		var section_control
		var section_name = ""
		if v.has("section"):
			section_name = v.section

		if sections.has(section_name):
			section_control = sections[section_name]
		else:
			section_control = _create_section(section_name)
			sections[section_name] = section_control

		var control = _get_control_for(v)
		if not control:
			return

		section_control.add_child(control)
		_variables_ui[vname] = control

	var keys = sections.keys()
	keys.sort()
	for key in keys:
		_root.add_child(sections[key])


func _clear_inspector() -> void:
	_variables_ui = {}
	for c in _root.get_children():
		_root.remove_child(c)
		c.queue_free()


func _create_section(name: String) -> Control:
	if name == "":
		name = "General Properties"

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
		ui.init(v.name, v.default_value)
		return ui

	return null
