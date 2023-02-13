extends Node

# Enable support for multiple themes as well as thirdparty user provided themes
#
# TODO

const DEFAULT_THEME := preload("res://ui/themes/default.tres")


func get_current_theme() -> Theme:
	return DEFAULT_THEME # TMP


func get_default_font() -> Font:
	for type in DEFAULT_THEME.get_font_type_list():
		print("type: ", type)
		print("fonts: ", DEFAULT_THEME.get_font_list(type))

	return ThemeDB.fallback_font
