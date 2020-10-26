extends Reference

const RUN_CURRENT_SCENE_GODOT_3_2: int = 39
const RUN_CURRENT_SCENE_GODOT_3_1: int = 33

func run(test_runner_path: String) -> void:
	var plugin = EditorPlugin.new()
	plugin.get_editor_interface().open_scene_from_path(test_runner_path)
	var previous_resource = plugin.get_editor_interface().get_script_editor().get_current_script()
	var version = Engine.get_version_info()
	if version.minor == 1:
		_run(RUN_CURRENT_SCENE_GODOT_3_1)
	elif version.minor == 2:
		_run(RUN_CURRENT_SCENE_GODOT_3_2)
	if previous_resource:
		plugin.get_editor_interface().edit_resource(previous_resource)

func _run(version: int) -> void:
	var plugin = EditorPlugin.new()
	plugin.get_editor_interface().get_parent()._menu_option(version)
