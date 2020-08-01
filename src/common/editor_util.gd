class_name ConceptGraphEditorUtil


static func get_editor_scale() -> float:
	var scale = Settings.get_setting(Settings.EDITOR_SCALE)
	if not scale:
		scale = 100
	return scale / 100.0


"""
Returns the path to res://addons/concept_graph, no matter how the user renamed the addon folder
"""
static func get_plugin_root_path() -> String:
	var dummy = ConceptGraphNodePool.new()
	var path = dummy.get_script().get_path()
	dummy.queue_free()
	return path.replace("src/core/node_pool.gd", "")


"""
Returns a square texture or a given color. Used in GraphNodes that accept multiple connections
on the same slot.
"""
static func get_square_texture(color: Color) -> ImageTexture:
	var image = Image.new()
	image.create(10, 10, false, Image.FORMAT_RGBA8)
	image.fill(color)

	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image)
	imageTexture.resource_name = "square " + String(color.to_rgba32())

	return imageTexture


"""
>>>> ONLY CALL THIS ONCE <<<<
"""
static func scale_all_ui_resources() -> void:
	_scale_fonts()
	_scale_spinbox_custom_stylebox()
	_scale_common_stylebox()


static func get_scaled_theme(theme: Theme) -> Theme:
	var scale = get_editor_scale()
	if scale == 1.0:
		return theme

	var res: Theme = theme.duplicate(true)

	res.default_font.size *= scale

	for font_name in res.get_font_list("EditorFonts"):
		var font = res.get_font(font_name, "EditorFonts")
		font.size *= scale

	for stylebox_type in res.get_stylebox_types():
		for font_name in res.get_font_list(stylebox_type):
			var font = res.get_font(font_name, stylebox_type)
			font.size *= scale

		for const_name in res.get_constant_list(stylebox_type):
			var c = res.get_constant(const_name, stylebox_type)
			res.set_constant(const_name, stylebox_type, c * scale)

		for box_name in res.get_stylebox_list(stylebox_type):
			var box = res.get_stylebox(box_name, stylebox_type)

			box.content_margin_bottom *= scale
			box.content_margin_left *= scale
			box.content_margin_right *= scale
			box.content_margin_top *= scale

			if box is StyleBoxFlat:
				box.corner_radius_bottom_left *= scale
				box.corner_radius_bottom_right *= scale
				box.corner_radius_top_left *= scale
				box.corner_radius_top_right *= scale

				box.border_width_bottom *= scale
				box.border_width_top *= scale
				box.border_width_left *= scale
				box.border_width_right *= scale

				box.expand_margin_bottom *= scale
				box.expand_margin_top *= scale
				box.expand_margin_left *= scale
				box.expand_margin_right *= scale

	return res


"""
Scale the fonts from the font folder. Calling load takes advantage of the built in resource caching
and allows to update all the fonts manually assigned in different scenes without going through the
theme.
"""
static func _scale_fonts() -> void:
	var scale = get_editor_scale()
	var dir = Directory.new()
	var path = "res://views/themes/fonts/"
	dir.open(path)

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "tres":
			var resource = load(path + file_name)
			if resource is Font:
				resource.size *= scale

		file_name = dir.get_next()


static func _scale_spinbox_custom_stylebox() -> void:
	var scale = get_editor_scale()
	var dir = Directory.new()
	var path = "res://views/editor/common/spinbox/styles/"
	dir.open(path)

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "tres":
			var resource = load(path + file_name)
			if resource is StyleBoxFlat:
				resource.corner_radius_bottom_left *= scale
				resource.corner_radius_bottom_right *= scale
				resource.corner_radius_top_left *= scale
				resource.corner_radius_top_right *= scale

		file_name = dir.get_next()


static func _scale_common_stylebox() -> void:
	var scale = get_editor_scale()
	var dir = Directory.new()
	var path = "res://views/themes/styles/"
	dir.open(path)

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "tres":
			var resource = load(path + file_name)
			if resource is StyleBoxFlat:
				resource.corner_radius_bottom_left *= scale
				resource.corner_radius_bottom_right *= scale
				resource.corner_radius_top_left *= scale
				resource.corner_radius_top_right *= scale

		file_name = dir.get_next()
