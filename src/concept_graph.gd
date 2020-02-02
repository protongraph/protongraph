tool
extends Spatial

class_name ConceptGraph

"""
The main class of this plugin. Add a ConceptGraph node to your scene and attach a template to this
node to start editing the graph from the bottom panel editor.
This node then travel through the ConceptGraphTemplate object to generate content on the fly every
time the associated graph is updated.
"""


signal template_changed

export(String, FILE, "*.cgraph") var template := "" setget set_template
export var show_result_in_editor_tree := false setget set_show_result

var _template: ConceptGraphTemplate
var _input_root: Node
var _output_root: Node


func _ready() -> void:
	_input_root = _get_or_create_root("Input")
	_output_root = _get_or_create_root("Output")
	_template = ConceptGraphTemplate.new()
	add_child(_template)
	generate()


func generate() -> void:
	"""
	Ask the Template object to go through the node graph and process each nodes until the final
	result is complete.
	"""
	print("Generating concept graph output")
	for c in _output_root.get_children():
		_output_root.remove_child(c)
		c.queue_free()

	if not _template:
		_template = ConceptGraphTemplate.new()
		add_child(_template)

	_template.load_from_file(template)
	var result = _template.get_output()
	if not result:
		print("No result returned")
		return

	if not result is Array:
		result = [result]

	for node in result:
		_output_root.add_child(node)
		node.set_owner(get_tree().get_edited_scene_root())


func set_template(val) -> void:
	template = val
	emit_signal("template_changed", val)	# This signal is only useful for the editor view


func set_show_result(val) -> void:
	"""
	Decides whether to show the resulting nodes in the editor tree or keep it hidden (but still
	visible in the viewport)
	"""
	show_result_in_editor_tree = val
	if not _output_root:
		return

	if val:
		_output_root.set_owner(get_tree().get_edited_scene_root())
	else:
		_output_root.set_owner(self)


func get_input(name: String) -> Node:
	if not _input_root:
		print("No input root found")
		return null
	print("Input root found, looking for ", name)
	return _input_root.get_node(name)


func _get_or_create_root(name: String) -> Spatial:
	if has_node(name):
		return get_node(name) as Spatial

	var root = Spatial.new()
	root.set_name(name)
	add_child(root)
	root.set_owner(get_tree().get_edited_scene_root())
	return root

