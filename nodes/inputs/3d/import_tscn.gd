extends GenericImportNode


func _init() -> void:
	._init(["*.tscn", "*.scn"])
	ignore = false
	unique_id = "import_tscn"
	display_name = "Import Godot Scene"
	category = "Inputs"
	description = "Load a Godot scene file (scn or tscn)"

	set_output(0, "", DataType.NODE_3D)


func _trigger_import() -> void:
	if _data:
		_data.free()
		_data = null

	var path: String = get_resource_path()
	if ResourceLoader.exists(path):
		var scene: PackedScene = ResourceLoader.load(path, "PackedScene", true)
		if scene and scene.can_instance():
			_data = scene.instance().duplicate(7)
