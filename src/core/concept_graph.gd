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

export(String, FILE, "*.cgraph") var template := "" setget set_template
export var show_result_in_editor_tree := false setget set_show_result
export var paused := false

var _template: ConceptGraphTemplate
var _input_root: Node
var _output_root: Node
var _exposed_vars := {}


"""
Runs the simulation once so the result is available once the scene is loaded, otherwise
the user would have to manually rerun every template in the scene.
"""
func _enter_tree():
	if Engine.is_editor_hint():
		_input_root = _get_or_create_root("Input")
		_input_root.connect("input_changed", self, "_on_input_changed")
		_output_root = _get_or_create_root("Output")
		reload_template()


"""
Custom property list to expose user defined template parameters to the inspector.
This requires to override _get and _set as well
"""
func _get_property_list() -> Array:
	var res := []
	for name in _exposed_vars.keys():
		var dict := {
			"name": name,
			"type": _exposed_vars[name]["type"],
		}
		res.append(dict)
	return res


func _get(property):
	if _exposed_vars.has(property):
		if _exposed_vars[property].has("value"):
			return _exposed_vars[property]["value"]


func _set(property, value): # overridden
	if property.begins_with("Template/"):
		if _exposed_vars.has(property):
			_exposed_vars[property]["value"] = value
			generate(true)
		else:
			# This happens when loading the scene, don't regenerate here as it will happen again
			# in _enter_tree
			_exposed_vars[property] = {"value": value}
		return true
	return false


func expose_variable(name: String, type: int, default_value = null) -> bool:
	_exposed_vars[name] = {
		"type": type,
		"value": default_value,
	}
	property_list_changed_notify()
	return true # TODO return false in case of naming collision


"""
Short hand to create the template if it doesn't exists and load the template file defined in
template.
"""
func reload_template() -> void:
	if not _template:
		_template = ConceptGraphTemplate.new()
		add_child(_template)
		_template.concept_graph = self
		_template.root = _output_root
		_template.node_library = get_tree().root.get_node("ConceptNodeLibrary")
		_template.connect("simulation_outdated", self, "generate")

	_template.load_from_file(template)
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


"""
Ask the Template object to go through the node graph and process each nodes until the final
result is complete.
"""
func generate(force_full_simulation := false) -> void:
	if not Engine.is_editor_hint() or paused:
		return

	clear_output()
	if force_full_simulation:
		_template.clear_simulation_cache()

	var result = _template.get_output()	# Actual simulation happens here
	if not result:
		return

	if not result is Array:
		result = [result]

	for node in result:
		_output_root.add_child(node)
		node.set_owner(get_tree().get_edited_scene_root())
		_set_children_owner(node)


func _set_children_owner(node) -> void:
	for c in node.get_children():
		c.set_owner(get_tree().get_edited_scene_root())
		_set_children_owner(c)


func set_template(val) -> void:
	if template != val:
		template = val
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
