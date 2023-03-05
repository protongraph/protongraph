class_name CustomLabelSettings
extends LabelSettings


var _original_size: int


func _init():
	_original_size = font_size
	_update_scale()


func _update_scale() -> void:
	var scale := EditorUtil.get_editor_scale()
	font_size = int(_original_size * scale)


func _on_settings_changed(setting) -> void:
	if setting == Settings.EDITOR_SCALE:
		_update_scale()
