class_name EditorUtil
extends RefCounted


static func get_editor_scale() -> float:
	var scale: float = Settings.get_setting(Settings.EDITOR_SCALE) / 100.0
	if not scale:
		return 1.0
	return scale

