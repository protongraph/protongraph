extends GenericExportNode


func _init() -> void:
	._init(["*.exr"])
	ignore = false
	unique_id = "export_exr"
	display_name = "Export EXR"
	category = "Output"
	description = "Save a texture to the disk (EXR format)"
	
	set_input(0, "Texture", DataType.TEXTURE_2D)


func _trigger_export() -> void:
	var path: String = get_resource_path()
	var image = get_input_single(0, null)
	if image and image is Image:
		image.save_exr(path)
	
