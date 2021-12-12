class_name SaveLoadDialog
extends FileDialog


enum DialogMode {
	LOAD,
	SAVE,
}

var dialog_mode: DialogMode = DialogMode.LOAD

var _save_as_title := "Save the node graph as"
var _load_title := "Load an existing graph"
var _default_file_suggestion := "new_graph.tpgn"


func _ready() -> void:
	file_selected.connect(_on_file_selected)


func show_dialog() -> void:
	match dialog_mode:
		DialogMode.LOAD:
			_load_graph()
		DialogMode.SAVE:
			_save_graph_as()


func _load_graph() -> void:
	title = _load_title
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	current_file = ""
	popup_centered()


func _save_graph_as(suggestion := "") -> void:
	title = _save_as_title
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	current_file = suggestion if not suggestion.is_empty() else _default_file_suggestion
	popup_centered()


func _on_file_selected(path: String) -> void:
	match dialog_mode:
		DialogMode.LOAD:
			GlobalEventBus.load_graph.emit(path)
		DialogMode.SAVE:
			GlobalEventBus.save_graph_as.emit(path)
