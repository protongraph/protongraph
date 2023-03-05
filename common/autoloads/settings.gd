extends Node

# User settings.
# Keep the ids unique across every settings, regardless of their parent category.

const EDITOR_SCALE := {
	"category": "editor",
	"id": "editor_scale",
	"title": "Editor UI scale",
	"description":
		"""Increase this number if the text appears too small.
		Decrease it if the text appears too large.""",
	}
const AUTOSAVE_ENABLED := {
	"category": "editor",
	"id": "enable_autosave",
	"title": "Enable Autosave",
	"description": "Automatically save the edited graph at regular intervals.",
}
const AUTOSAVE_INTERVAL := {
	"category": "editor",
	"id": "autosave_interval",
	"title": "Autosave interval",
	"description":
		"""Save edited templates every X seconds.
		Only applicable when autosave is enabled.""",
}
const GROUP_NODES_BY_TYPE := {
	"category": "editor",
	"id": "group_nodes_by_type",
	"title": "Group nodes by type",
	"description":
		"""In the "Add node" popup, by default, nodes are grouped by purpose (Generators, Modifiers...).
		Turn this setting on to group them by data type (Meshes, Curves ...).""",
}

const CONFIG_PATH = "user://config.cfg"

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
	AUTOSAVE_INTERVAL: 300.0,
	EDITOR_SCALE: 100.0,
}

var _require_restart := [
	EDITOR_SCALE
]


func require_restart(setting: Dictionary) -> bool:
	return setting in _require_restart


func get_list() -> Array:
	return _list


func get_setting(setting, default = null):
	if not _initialized:
		load_or_create_config_file()

	if _values.has(setting):
		return _values[setting]

	return default


func update_setting(setting, value) -> void:
	var old_value = _values[setting]
	_values[setting] = value
	save_config()

	if require_restart(setting): # Keep using the old value until the user restarts the application
		_values[setting] = old_value

	GlobalEventBus.settings_updated.emit(setting)


func load_or_create_config_file() -> void:
	var dir := DirAccess.open("user://")
	if not dir:
		print_debug("Could not open user://")
		return

	if dir.file_exists(CONFIG_PATH):
		print(CONFIG_PATH, " already exists, loading config")
		load_config()
	else:
		print(CONFIG_PATH, " doesn't exists, creating the config file")
		save_config()

	_initialized = true


func load_config() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		print_debug("Failed to load the configuration file ", CONFIG_PATH)
		return

	# TODO: change this to ignore the category and only take the id in account, in case
	# we move a setting to another category this shouldn't break the config file.
	for setting in _list:
		_values[setting] = config.get_value(setting.category, setting.id, _values[setting])


func save_config() -> void:
	var config = ConfigFile.new()
	for setting in _list:
		config.set_value(setting.category, setting.id, _values[setting])
	config.save(CONFIG_PATH)
