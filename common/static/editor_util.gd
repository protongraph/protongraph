class_name EditorUtil
extends RefCounted


static func get_editor_scale() -> float:
	var scale: float = Settings.get_value(Settings.EDITOR_SCALE) / 100.0
	if not scale:
		return 1.0
	return scale


static func get_absolute_position(control: Control) -> Vector2i:
	var parent_window = WindowManager.get_parent_window(control)
	return parent_window.position + Vector2i(control.get_global_transform().origin)
