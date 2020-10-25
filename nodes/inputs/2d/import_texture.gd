extends GenericImportNode


func _init() -> void:
	._init(["*.png", "*.jpg", "*.tga", "*.webp"])
	ignore = false
	unique_id = "import_texture"
	display_name = "Import Texture"
	category = "Inputs"
	description = "Load a texture file"

	set_output(0, "", DataType.TEXTURE_2D)


func _trigger_import() -> void:
	_data = null
	var path: String = get_resource_path()
	var texture = load(path)
	if texture is Texture:
		_data = texture.get_data()
