tool
extends ConceptNode

"""
This node marks the end of every ConceptNodeTemplate. A template can have multiple outputs.
"""


func _init() -> void:
	unique_id = "export_gltf"
	display_name = "Export GLTF"
	category = "Output"
	description = "The final node of any template"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_SAVE_FILE,
			"filters": ["*.gltf", "*.glb"]
		}
	}
	set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_input(1, "Export path", ConceptGraphDataType.STRING, opts)


func _generate_outputs() -> void:
	output.append(get_input(0))	# Special case, don't specify the index here


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)


func is_final_output_node() -> bool:
	return true
