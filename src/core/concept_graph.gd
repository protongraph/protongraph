tool
class_name ConceptGraph, "../../icons/graph.svg"
extends Spatial

"""
The main class of this plugin. Add a ConceptGraph node to your scene and attach a template to this
node to start editing the graph from the bottom panel editor.
This node then travel through the ConceptGraphTemplate object to generate content on the fly every
time the associated graph is updated.
"""


signal template_path_changed

export(String, FILE, "*.cgraph") var template_path := "" setget set_template_path
export var show_result_in_editor_tree := false setget set_show_result
export var paused := false

var _initialized := false
var _template: ConceptGraphTemplate
var _input_root: Node
var _output_root: Node
var _exposed_variables := {}


"""
Runs the simulation once so the result is available once the scene is loaded, otherwise
the user would have to manually rerun every template in the scene.
"""
func _enter_tree():
	if _initialized:
		return

	if Engine.is_editor_hint():
		_input_root = _get_or_create_root("Input")
		_input_root.connect("input_changed", self, "_on_input_changed")
		_output_root = _get_or_create_root("Output")
		reload_template()
		_initialized = true


"""
Custom property list to expose user defined template parameters to the inspector.
This requires to override _get and _set as well
"""
func _get_property_list() -> Array:
	var res := []
	for name in _exposed_variables.keys():
		var dict := {
			"name": name,
			"type": _exposed_variables[name]["type"],
		}
		if _exposed_variables[name].has("hint"):
			dict["hint"] = _exposed_variables[name]["hint"]
		if _exposed_variables[name].has("hint_string"):
			dict["hint_string"] = _exposed_variables[name]["hint_string"]
		res.append(dict)
	return res


func _get(property):
	if _exposed_variables.has(property):
		if _exposed_variables[property].has("value"):
			return _exposed_variables[property]["value"]


func _set(property, value): # overridden
	if property.begins_with("Template/"):
		if _exposed_variables.has(property):
			_exposed_variables[property]["value"] = value
			generate(true)
		else:
			# This happens when loading the scene, don't regenerate here as it will happen again
			# in _enter_tree
			_exposed_variables[property] = {"value": value}

			if value is float:
				_exposed_variables[property]["type"] = TYPE_REAL
			elif value is String:
				_exposed_variables[property]["type"] = TYPE_STRING
			elif value is Vector3:
				_exposed_variables[property]["type"] = TYPE_VECTOR3
			elif value is bool:
				_exposed_variables[property]["type"] = TYPE_BOOL
			elif value is Curve:
				_exposed_variables[property]["type"] = TYPE_OBJECT
				_exposed_variables[property]["hint"] = PROPERTY_HINT_RESOURCE_TYPE
				_exposed_variables[property]["hint_string"] = "Curve"

			property_list_changed_notify()
		return true
	return false


func update_exposed_variables(variables: Array) -> void:
	var old = _exposed_variables
	_exposed_variables = {}

	for v in variables:
		if _exposed_variables.has(v.name):
			continue

		var value = old[v.name]["value"] if old.has(v.name) else v["default_value"]
		_exposed_variables[v.name] = {
			"type": v["type"],
			"value": value,
		}
		if v.has("hint"):
			_exposed_variables[v.name]["hint"] = v["hint"]
		if v.has("hint_string"):
			_exposed_variables[v.name]["hint_string"] = v["hint_string"]
	property_list_changed_notify()


func reload_template() -> void:
	if not _template:
		_template = ConceptGraphTemplate.new()
		add_child(_template)
		_template.concept_graph = self
		_template.root = _output_root
		_template.node_library = get_tree().root.get_node("ConceptNodeLibrary")
		_template.connect("simulation_outdated", self, "generate")

	_template.load_from_file(template_path)
	_template.update_exposed_variables()
	generate()


"""
Clear the scene tree from every returned by the template generation.
"""
func clear_output() -> void:
	if not _output_root:
		_output_root = _get_or_create_root("Output")

	for c in _output_root.get_children():
		_output_root.remove_child(c)
		c.queue_free()

	_template.run_garbage_collection()


"""
Ask the Template object to go through the node graph and process each nodes until the final
result is complete.
"""
func generate(force_full_simulation := false) -> void:
	if not Engine.is_editor_hint() or paused:
		return
	# print("Memory MB : ", OS.get_static_memory_usage() / (1024 * 1024))
	clear_output()

	if force_full_simulation:
		_template.clear_simulation_cache()

	var result = _template.get_output()	# Actual simulation happens here
	if not result or result.size() == 0:
		return

	for node in result:
		if not node:
			continue
		_output_root.add_child(node)
		node.set_owner(get_tree().get_edited_scene_root())
		_set_children_owner(node)


func _set_children_owner(node) -> void:
	for c in node.get_children():
		c.set_owner(get_tree().get_edited_scene_root())
		_set_children_owner(c)


func set_template_path(val) -> void:
	if template_path != val:
		template_path = val
		if get_tree():
			reload_template()
			emit_signal("template_path_changed", val)	# This signal is only useful for the editor view


"""
Decides whether to show the resulting nodes in the editor tree or keep it hidden (but still
visible in the viewport)
"""
func set_show_result(val) -> void: # TODO : not working
	show_result_in_editor_tree = val
	return
	if not _output_root:
		_output_root = _get_or_create_root("Output")

	if val:
		_output_root.set_owner(get_tree().get_edited_scene_root())
	else:
		_output_root.set_owner(self)


func get_input(name: String) -> Node:
	if not _input_root:
		return null
	return _input_root.get_node(name)


func _get_or_create_root(name: String) -> Spatial:
	if has_node(name):
		return get_node(name) as Spatial

	#var root = Spatial.new()
	var root = ConceptGraphInputManager.new() if name == "Input" else Spatial.new()
	root.set_name(name)
	add_child(root)
	root.set_owner(get_tree().get_edited_scene_root())
	return root


func _on_input_changed(node) -> void:
	generate(true)
