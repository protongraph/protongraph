extends GenericImportNode


func _init() -> void:
	._init(["*.glb", "*.gltf"])
	ignore = false
	unique_id = "import_gltf"
	display_name = "Import GLTF"
	category = "Inputs"
	description = "Load a gltf or glb file"

	set_output(0, "", DataType.MESH_3D)


func _trigger_import() -> void:
	_data = []
	var path: String = get_resource_path()
	var gltf = PackedSceneGLTF.new()
	gltf.pack_gltf(path)
	_data = gltf.instance()
	if _data.get_child_count() == 1:
		_data = _data.get_child(0)
