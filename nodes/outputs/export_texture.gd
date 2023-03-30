extends ProtonNode


const FORMAT_PNG := 0
const FORMAT_JPG := 1
const FORMAT_EXR := 2
const FORMAT_WEBP := 3


func _init() -> void:
	type_id = "export_texture"
	title = "Export Texture"
	category = "Output"
	description = "Save a picture to the disk"
	leaf_node = true

	create_input("texture", "Texture", DataType.TEXTURE_2D)

	var opts := SlotOptions.new()
	opts.is_file = true
	opts.file_filters = ["*.png", "*.jpg", ".webp"]
	create_input("file_path", "File path", DataType.STRING, opts)

	create_input("lossy", "Lossy", DataType.BOOLEAN, SlotOptions.new(false))

	opts = SlotOptions.new()
	opts.value = 0.75
	opts.min_value = 0.0
	opts.max_value = 1.0
	opts.allow_greater = false
	opts.allow_lesser = false
	create_input("quality", "Quality", DataType.NUMBER, opts)


func _generate_outputs() -> void:
	var file_path: String = get_input_single("file_path", "")
	var image: Image = get_input_single("texture", null)
	var lossy: bool = get_input_single("lossy", false)
	var quality: float = get_input_single("quality", 0.75)

	if file_path.is_empty() or not image:
		return

	match file_path.get_extension():
		"png":
			image.save_png(file_path)
		"jpg":
			image.save_jpg(file_path, quality)
		"exr":
			image.save_exr(file_path)
		"webp":
			image.save_webp(file_path, lossy, quality)
		_:
			print("Unsupported file format: ", file_path)
