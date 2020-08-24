extends GenericExportNode


func _init() -> void:
	._init(["*.png"])
	ignore = false
	unique_id = "export_png"
	display_name = "Export PNG"
	category = "Output"
	description = "Save a picture to the disk"
	
	set_input(0, "Data", ConceptGraphDataType.TEXTURE_2D)


func _trigger_export() -> void:
	var path: String = get_resource_path()
	var image: Image = get_input_single(0, null)
	if image:
		image.save_png(path)
