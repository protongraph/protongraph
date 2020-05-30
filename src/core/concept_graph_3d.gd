tool
extends Spatial
class_name ConceptGraph3D


func _ready() -> void:
	var script = load(ConceptGraphEditorUtil.get_plugin_root_path() + "/src/core/concept_graph.gd")
	self.set_script(script)
