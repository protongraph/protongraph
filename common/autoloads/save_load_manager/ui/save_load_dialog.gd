class_name SaveLoadDialog
extends FileDialog


signal path_selected(String)


var _save_as_title := "Save the node graph as"
var _load_title := "Load a node graph"
var _default_file_suggestion := "new_graph.tpgn"


func _ready() -> void:
	file_selected.connect(_on_file_selected)
	get_cancel_button().pressed.connect(_on_canceled)
	min_size = Vector2i(600, 400)
	UserInterfaceUtil.fix_popup_theme_recursive(self)
	set_filters(PackedStringArray(["*.tpgn ; Text PGraphNode"]))
	access = FileDialog.ACCESS_FILESYSTEM


func show_load_dialog() -> void:
	title = _load_title
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	current_file = ""
	popup_centered()


func show_save_dialog(suggestion := "") -> void:
	title = _save_as_title
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	current_file = suggestion if not suggestion.is_empty() else _default_file_suggestion
	popup_centered()


func _on_file_selected(path: String) -> void:
	path_selected.emit(path)


func _on_canceled() -> void:
	path_selected.emit("")
