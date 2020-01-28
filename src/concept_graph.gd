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
var _result: Spatial


func _ready() -> void:
	_template = ConceptGraphTemplate.new()


func generate() -> void:
	if _result:
		remove_child(_result)
		_result.queue_free()

	_result = _template.get_output()
	if not _result:
		return

	add_child(_result)

	if show_result_in_editor_tree:
		_result.set_owner(get_tree().get_edited_scene_root())


func set_template(val) -> void:
	template = val
	emit_signal("template_changed", val)


func set_show_result(val) -> void:
	show_result_in_editor_tree = val
	if not _result:
		return

	if val:
		_result.set_owner(get_tree().get_edited_scene_root())
	else:
		_result.set_owner(self)

