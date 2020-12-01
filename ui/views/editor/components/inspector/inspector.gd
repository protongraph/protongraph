extends ScrollContainer
class_name InspectorPanel


signal value_changed


var _exposed_variables := {}
var _variables_ui := {}
var _cache := {}

onready var _root: Control = $PanelContainer/VBoxContainer


func _ready() -> void:
	_regenerate_inspector_ui()


func update_variables(variables: Array) -> void:
	_exposed_variables = {}
	if _cache.empty(): # Don't override the values cache if it already exists
		_cache = get_all_values()

	# Make sure there's no variables duplicates
	for v in variables:
		var vname = v.name.to_lower()
		if not _exposed_variables.has(vname):
			_exposed_variables[vname] = v

	# Regenerate the UI and restore values
	_regenerate_inspector_ui()
	set_all_values(_cache)
	_cache = {}


func get_value(name):
	name = name.to_lower()
	if _variables_ui.has(name):
		return _variables_ui[name].get_value()
	return null


func get_all_values(storage := false) -> Dictionary:
	var res = {}
	for vname in _variables_ui:
		res[vname] = _variables_ui[vname].get_value(storage)
	return res


func set_all_values(values) -> void:
	if _variables_ui.empty():
		_cache = values
		return # Inspector was not initialized yet, caching the values for later

	for vname in values:
		vname = vname.to_lower()
		if _variables_ui.has(vname):
			_variables_ui[vname].set_value(values[vname])


func _regenerate_inspector_ui() -> void:
	_clear_inspector()

	if _exposed_variables.empty():
		_root.add_child(preload("no_properties.tscn").instance())
		return

	var sections = {}

	for vname in _exposed_variables:
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
			continue

		section_control.add_control(control)
		_variables_ui[vname] = control
		control.connect("value_changed", self, "_on_value_changed", [vname])

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
		DataType.SCALAR:
			ui = preload("scalar_property.tscn").instance()
		DataType.BOOLEAN:
			ui = preload("bool_property.tscn").instance()
		DataType.CURVE_FUNC:
			ui = preload("curve/curve_property.tscn").instance()
		DataType.STRING:
			ui = preload("string_property.tscn").instance()
		DataType.VECTOR2:
			ui = preload("vector2_property.tscn").instance()
		DataType.VECTOR3:
			ui = preload("vector3_property.tscn").instance()

	if ui:
		ui.init(v.name.capitalize(), v.default_value)
		return ui

	return null


func _on_value_changed(vname: String) -> void:
	emit_signal("value_changed", vname)
