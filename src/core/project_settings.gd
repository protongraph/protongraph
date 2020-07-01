tool
extends Node
class_name ConceptGraphSettings


const MULTITHREAD_ENABLED = "enable_multithreading"
const GENERATION_DELAY = "delay_before_generation"
const INLINE_VECTOR_FIELDS = "inline_vector_fields"
const GROUP_NODES_BY_TYPE = "group_nodes_by_type"
const AUTOSAVE_ENABLED = "enable_autosave"
const AUTOSAVE_INTERVAL = "autosave_interval"

var _path = "res://config.json"
var _settings = {}
var _json_util = load("res://src/thirdparty/json_beautifier/json_beautifier.gd")

func _ready() -> void:
	load_config()


func has(setting: String) -> bool:
	return _settings.has(setting)


func get_setting(setting: String):
	if _settings.has(setting):
		return _settings[setting]
	return null


func update_setting(setting: String, value) -> void:
	_settings[setting] = value


func load_config() -> void:
	# Open the file and read the contents
	var file = File.new()
	file.open(_path, File.READ)
	var json = JSON.parse(file.get_as_text())
	if not json or not json.result:
		print("Failed to parse the configuration file ", _path)
		return

	_settings = json.result
	print("Settings : ", _settings)


func save_config() -> void:
	var json = _json_util.beautify_json(to_json(_settings))
	var file = File.new()
	file.open(_path, File.WRITE)
	file.store_string(json)
	file.close()
