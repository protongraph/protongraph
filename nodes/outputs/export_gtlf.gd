extends GenericExportNode


func _init() -> void:
	._init(["*.gltf", "*.glb"])
	ignore = false
	unique_id = "export_gltf"
	display_name = "Export GLTF"
	category = "Output"
	description = "Save the 3D data as a GLTF or GLB file"

	set_input(0, "Node", DataType.NODE_3D)


func _trigger_export() -> void:
	var node: Spatial = get_input_single(0, null)
	var path: String = get_resource_path()
	print("In force export")
	if node and path != "":
		var gltf := PackedSceneGLTF.new()
		gltf.export_gltf(node, path)
		print("Exported gltf file ", path)
