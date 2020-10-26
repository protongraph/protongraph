extends Node

const displays: Dictionary = {
	0: "Left.UL Dock", 1: "Left.BL Dock", 2: "Left.UR Dock",
	3: "Left.BR Dock", 4: "Right.UL Dock", 5: "Right.BL Dock",
	6: "Right.UR Dock", 7: "Right.BR Dock", 8: "Bottom Panel",
}

enum { LEFT_UPPER_LEFT, LEFT_BOTTOM_LEFT, LEFT_UPPER_RIGHT,
	LEFT_BOTTOM_RIGHT, RIGHT_UPPER_LEFT, RIGHT_BOTTOM_LEFT,
	RIGHT_UPPER_RIGHT, RIGHT_BOTTOM_RIGHT, BOTTOM_PANEL,
	OUT_OF_BOUNDS
}

var _plugin: EditorPlugin
var _scene: Control
var _state: int

func _init(plugin: EditorPlugin, scene: Control) -> void:
	_plugin = plugin
	_scene = scene
	
func _ready() -> void:
	construct()
	
func _process(delta: float) -> void:
	update()
	
func _notification(what) -> void:
	if what == NOTIFICATION_PREDELETE:
		deconstruct()

func construct() -> void:
	if not ProjectSettings.has_setting("WAT/Display"):
		ProjectSettings.set_setting("WAT/Display", BOTTOM_PANEL)
		ProjectSettings.save()
	add_setting()
	_state = get_window_state()
	
	if _state == BOTTOM_PANEL:
		_plugin.add_control_to_bottom_panel(_scene, "Tests")
	else:
		_plugin.add_control_to_dock(_state, _scene)
	
func deconstruct() -> void:
	if _state == BOTTOM_PANEL:
		_plugin.remove_control_from_bottom_panel(_scene)
	else:
		_plugin.remove_control_from_docks(_scene)

func update() -> void:
	var state = get_window_state()
	if state == _state:
		return
		
	deconstruct()
	_state = state
	construct()

	ProjectSettings.set_setting("WAT/Display", _state)
	ProjectSettings.save()

func get_window_state() -> int:
	return ProjectSettings.get_setting("WAT/Display")

func add_setting() -> void:
	var property = {}
	property.name = "WAT/Display"
	property.type = TYPE_INT
	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = PoolStringArray(displays.values()).join(",")
	ProjectSettings.add_property_info(property)
	ProjectSettings.save()
