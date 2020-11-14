extends Node


var _history_path := "user://history.json"
var _history: Array = []
var _initialized := false


func _ready():
	_load_or_create_file_history()
	GlobalEventBus.register_listener(self, "template_loaded", "_on_template_loaded")
	GlobalEventBus.register_listener(self, "remove_from_file_history", "_on_remove_from_history")


func get_list() -> Array:
	if not _initialized:
		_load_or_create_file_history()
	return _history


func _load_or_create_file_history() -> void:
	var dir = Directory.new()
	dir.open("user://")
	if dir.file_exists(_history_path):
		_load_file_history()
	else:
		_save_file_history()
	_initialized = true


func _load_file_history() -> void:
	var file = File.new()
	file.open(_history_path, File.READ)
	_history = JSON.parse(file.get_as_text()).result


func _save_file_history() -> void:
	var file = File.new()
	file.open(_history_path, File.WRITE)
	file.store_string(to_json(_history))
	file.close()


func _on_template_loaded(path: String) -> void:
	if _history.has(path):
		_history.erase(path)

	_history.push_front(path)
	if _history.size() > 20:
		_history.pop_back()

	_save_file_history()
	GlobalEventBus.dispatch("file_history_changed")


func _on_remove_from_history(path: String) -> void:
	if _history.has(path):
		_history.erase(path)
		_save_file_history()
		GlobalEventBus.dispatch("file_history_changed")
