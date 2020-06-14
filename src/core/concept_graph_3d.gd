tool
extends Spatial
class_name ConceptGraph3D, "../../icons/icon_concept_graph.svg"


func _ready() -> void:
	var script = load(ConceptGraphEditorUtil.get_plugin_root_path() + "/src/core/concept_graph.gd")
	self.set_script(script)
	self._enter_tree()
