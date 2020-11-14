extends Node
class_name Constants


const LOAD = 0
const CREATE = 1
const SAVE_AS = 2

const UI_PREVIEW_2D = 10


static func get_slot_height() -> float:
	return 24 * EditorUtil.get_editor_scale()


static func get_vector_width() -> float:
	return 120 * EditorUtil.get_editor_scale()


static func get_readable_name(constant) -> String:
	match constant:
		UI_PREVIEW_2D:
			return "2D Preview"
	
	return "Custom UI"
