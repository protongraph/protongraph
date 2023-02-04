extends Node

# Holds a list of recently opened files.


const HISTORY_PATH := "user://history.json"

var _history: Array[String]
var _initialized := false


func _ready():
	_load_or_create_file_history()
	GlobalEventBus.graph_loaded.connect(_on_graph_loaded)
	GlobalEventBus.graph_saved.connect(_on_graph_loaded)
	GlobalEventBus.remove_from_file_history.connect(_on_remove_from_history)


func get_list() -> Array[String]:
	if not _initialized:
		_load_or_create_file_history()
	return _history


func _load_or_create_file_history() -> void:
	if not _load_file_history():
		_save_file_history()
	_initialized = true


func _load_file_history() -> bool:
	var file = ConfigFile.new()
	var err = file.load(HISTORY_PATH)
	if err != OK:
		push_warning("Could not load recent file history. Code: ", err)
		return false

	_history = file.get_value("history", "list", []) as Array[String]
	return true


func _save_file_history() -> void:
	var file = ConfigFile.new()
	file.set_value("history", "list", _history)
	file.save(HISTORY_PATH)


func _on_graph_loaded(graph: NodeGraph) -> void:
	var path = graph.save_file_path

	if _history.has(path):
		_history.erase(path)

	_history.push_front(path)
	if _history.size() > 20: # TODO: Expose in user settings
		_history.pop_back()

	_save_file_history()
	GlobalEventBus.file_history_changed.emit()


func _on_remove_from_history(path: String) -> void:
	if _history.has(path):
		_history.erase(path)
		_save_file_history()
		GlobalEventBus.file_history_changed.emit()
