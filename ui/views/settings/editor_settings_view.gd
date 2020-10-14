extends PanelContainer
class_name EditorSettingsView


# TODO: Find a better way to generate this scene instead of manually
# creating all the controls in the 2D interface.


export var autosave: NodePath
export var autosave_interval: NodePath
export var delay_before_generation: NodePath
export var inline_vectors: NodePath
export var multithreading: NodePath
export var search_group_by_type: NodePath
export var scale: NodePath

var _autosave: CheckBox
var _autosave_interval: SpinBox
var _delay: SpinBox
var _inline_vectors: CheckBox
var _mt: CheckBox
var _search_group_type: CheckBox
var _scale: SpinBox


func _ready() -> void:
	_autosave = _setup_control(autosave, Settings.AUTOSAVE_ENABLED, TYPE_BOOL)
	_autosave_interval = _setup_control(autosave_interval, Settings.AUTOSAVE_INTERVAL, TYPE_REAL)
	_delay = _setup_control(delay_before_generation, Settings.GENERATION_DELAY, TYPE_REAL)
	_inline_vectors = _setup_control(inline_vectors, Settings.INLINE_VECTOR_FIELDS, TYPE_BOOL)
	_mt = _setup_control(multithreading, Settings.MULTITHREAD_ENABLED, TYPE_BOOL)
	_search_group_type = _setup_control(search_group_by_type, Settings.GROUP_NODES_BY_TYPE, TYPE_BOOL)
	_scale = _setup_control(scale, Settings.EDITOR_SCALE, TYPE_REAL)


func _setup_control(nodepath: NodePath, setting: String, type: int) -> Control:
	var node = get_node(nodepath)
	match type:
		TYPE_BOOL:
			node.pressed = Settings.get_setting(setting)
			node.connect("toggled", self, "_on_setting_changed", [setting])
		TYPE_REAL:
			node.value = Settings.get_setting(setting)
			node.connect("value_changed", self, "_on_setting_changed", [setting])
	return node


func _on_setting_changed(value, setting) -> void:
	Settings.update_setting(setting, value)
