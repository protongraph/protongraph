extends Node


const EDITOR_SCALE = {
	"category": "editor",
	"id": "editor_scale",
	"title": "Editor UI scale",
	"description": 
		"""Increase this number if the text appears too small.
		Decrease it if the text appears too large.""",
	}
const AUTOSAVE_ENABLED = {
	"category": "editor",
	"id": "enable_autosave",
	"title": "Enable Autosave",
	"description": "Automatically save the edited graph at regular intervals.",
}
const AUTOSAVE_INTERVAL = {
	"category": "editor",
	"id": "autosave_interval",
	"title": "Autosave interval",
	"description":
		"""Save edited templates every X seconds.
		Only applicable when autosave is enabled.""",
}
const GROUP_NODES_BY_TYPE = {
	"category": "editor",
	"id": "group_nodes_by_type",
	"title": "Group nodes by type",
	"description": 
		"""In the "Add node" popup, by default nodes are grouped by purpose (Generators, Modifiers...).
		Turn this setting on to group them by data type (Meshes, Curves ...).""",
}

var _path = "user://config.cfg"
var _initialized := false
var _list := [
	EDITOR_SCALE,
	AUTOSAVE_ENABLED,
	AUTOSAVE_INTERVAL,
	GROUP_NODES_BY_TYPE,
]

# Default settings values
var _values = {
	GROUP_NODES_BY_TYPE: false,
	AUTOSAVE_ENABLED: true,
	AUTOSAVE_INTERVAL: 30,
	EDITOR_SCALE: 1.0,
}

var _require_restart := [
	EDITOR_SCALE
]


func _ready() -> void:
	load_or_create_config_file()


func has(setting) -> bool:
	return _values.has(setting)


func get_setting(setting, default = null):
	if not _initialized:
		load_or_create_config_file()
	
	if _values.has(setting):
		return _values[setting]
	
	return default


func update_setting(setting: String, value) -> void:
	var old_value = _values[setting]
	_values[setting] = value
	save_config()

	if _require_restart.has(setting): # Keep using the old value until the user restarts the application
		_values[setting] = old_value
	else:
		GlobalEventBus.settings_updated.emit(setting)


func load_or_create_config_file() -> void:
	var dir = Directory.new()
	dir.open("user://")
	if dir.file_exists(_path):
		print(_path, " already exists, loading config")
		load_config()
	else:
		print(_path, " doesn't exists, creating the config file")
		save_config()

	_initialized = true


func load_config() -> void:
	var config = ConfigFile.new()
	if config.load(_path) != OK:
		print("Failed to load the configuration file ", _path)
		return

	for setting in _list:
		_values[setting] = config.get_value(setting.category, setting.id, _values[setting])


func save_config() -> void:
	var config = ConfigFile.new()
	for setting in _list:
		config.set_value(setting.category, setting.id, _values[setting])
	config.save(_path)
