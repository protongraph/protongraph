tool
extends Node2D
class_name ConceptGraph2D


func _ready() -> void:
	var script = load(ConceptGraphEditorUtil.get_plugin_root_path() + "/src/core/concept_graph.gd")
	self.set_script(script)
