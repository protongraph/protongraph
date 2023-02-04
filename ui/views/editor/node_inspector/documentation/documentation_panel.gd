class_name DocumentationPanel
extends RichTextLabel


# Formats and displays the DocumentationData provided by the graph nodes.

var _edited_text: String
var _accent_color := Color.CORNFLOWER_BLUE
var _editor_scale := 1.0 # TODO: fetch these options from the settings page.
var _sub_header_size := 14
var _icon_width := 20


func _ready() -> void:
	bbcode_enabled = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func set_data(data: DocumentationData) -> void:
	if not data:
		set_text("No documentation provided")
		return

	_begin_formatting()

	# Paragraphs
	for p in data.get_paragraphs():
		_format_paragraph(p)

	# Parameters
	if not data.get_parameters().is_empty():
		_format_subtitle("Parameters")

		for p in data.get_parameters():
			_format_parameter(p)

	# Warnings
	if not data.get_warnings().is_empty():
		_format_subtitle("Warnings")

		for w in data.get_warnings():
			_format_warning(w)

	set_text(_edited_text)


func _begin_formatting() -> void:
	_edited_text = ""


func _format_subtitle(subtitle: String) -> void:
	_edited_text += "[font_size=" + var_to_str(_sub_header_size * _editor_scale) + "]"
	_edited_text += "[color=" + _accent_color.to_html() + "]"
	#_edited_text += "[b]"
	_edited_text += subtitle
	#_edited_text += "[/b]"
	_edited_text += "[/color]"
	_edited_text += "[/font_size]"
	_format_line_break(2)


func _format_line_break(count := 1) -> void:
	for i in count:
		_edited_text += "\n"


func _format_paragraph(p: String) -> void:
	_edited_text += "[p]" + p + "[/p]"
	_format_line_break(2)


func _format_parameter(p) -> void:
	var root_folder = "res://ui/icons"
	var img_tag := "[img=" + str(_icon_width) + "]"
	_edited_text += "[indent]"

	if not p.type.is_empty():
		var file_name = "icon_" + p.type.to_lower() + ".svg"
		_edited_text += img_tag + root_folder + "/data_types/" + file_name + "[/img]  "

	_edited_text += "[b]" + p.name + "[/b]  "

	match p.cost:
		1:
			_edited_text += img_tag + root_folder + "/icon_arrow_log.svg[/img]"
		2:
			_edited_text += img_tag + root_folder + "/icon_arrow_linear.svg[/img]"
		3:
			_edited_text += img_tag + root_folder + "/icon_arrow_exp.svg[/img]"

	_format_line_break(2)
	_edited_text += "[indent]" + p.description + "[/indent]"
	_format_line_break(2)

	for warning in p.warnings:
		if not warning.text.is_empty():
			_format_warning(warning)

	_edited_text += "[/indent]"


func _format_warning(w, indent := true) -> void:
	if indent:
		_edited_text += "[indent]"

	var color := "Darkgray"
	match w.importance:
		1:
			color = "yellow"
		2:
			color = "red"

	_edited_text += "[color=" + color + "][i]" + w.text + "[/i][/color]\n"

	if indent:
		_edited_text += "[/indent]"

	_format_line_break(1)
