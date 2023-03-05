extends Node

# Enable support for multiple themes as well as thirdparty user provided themes
#
# TODO

const DEFAULT_THEME := preload("res://ui/themes/default.tres")


func _ready() -> void:
	_udpate_root_theme()
	GlobalEventBus.settings_updated.connect(_on_settings_updated)


func get_current_theme() -> Theme:
	return _get_scaled_theme(DEFAULT_THEME) # TMP


func get_default_font() -> Font:
	return ThemeDB.fallback_font # TODO - return one from the current theme


func _udpate_root_theme() -> void:
	get_tree().get_root().theme = _get_scaled_theme(DEFAULT_THEME)


func _get_scaled_theme(theme: Theme) -> Theme:
	var scale := EditorUtil.get_editor_scale()
	if scale == 1.0:
		return theme

	var res: Theme = theme.duplicate(true)

	for theme_item in res.get_font_size_type_list():
		for size_property in res.get_font_size_list(theme_item):
			var size = res.get_font_size(size_property, theme_item)
			res.set_font_size(size_property, theme_item, round(size * scale))

	for stylebox_type in res.get_stylebox_type_list():
		for const_name in res.get_constant_list(stylebox_type):
			var c = res.get_constant(const_name, stylebox_type)
			res.set_constant(const_name, stylebox_type, c * scale)

		for box_name in res.get_stylebox_list(stylebox_type):
			var box: StyleBox = res.get_stylebox(box_name, stylebox_type)

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


func _scale_spinbox_custom_stylebox() -> void:
	var scale := EditorUtil.get_editor_scale()
	var path = "res://ui/views/editor/components/spinbox/styles/"
	var dir = DirAccess.open(path)

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


func _on_settings_updated(setting) -> void:
	if setting == Settings.EDITOR_SCALE:
		_udpate_root_theme()
