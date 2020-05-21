tool
class_name ConceptGraphEditorUtil


# Taken from https://github.com/Zylann/godot_heightmap_plugin/blob/master/addons/zylann.hterrain/tools/util/editor_util.gd
static func get_dpi_scale() -> float:
	var editor_plugin = EditorPlugin.new()
	var editor_settings = editor_plugin.get_editor_interface().get_editor_settings()
	editor_plugin.queue_free()
	var display_scale = editor_settings.get("interface/editor/display_scale")
	var custom_display_scale = editor_settings.get("interface/editor/custom_display_scale")
	var edscale := 0.0

	match display_scale:
		0:
			# Try applying a suitable display scale automatically
			var screen = OS.current_screen
			var large = OS.get_screen_dpi(screen) >= 192 and OS.get_screen_size(screen).x > 2000
			edscale = 2.0 if large else 1.0
		1:
			edscale = 0.75
		2:
			edscale = 1.0
		3:
			edscale = 1.25
		4:
			edscale = 1.5
		5:
			edscale = 1.75
		6:
			edscale = 2.0
		_:
			edscale = custom_display_scale

	return edscale


"""
Returns the path to res://addons/concept_graph, no matter how the user renamed the addon folder
"""
static func get_plugin_root_path() -> String:
	var dummy = ConceptGraph.new()
	var path = dummy.get_script().get_path()
	dummy.queue_free()
	return path.replace("src/core/concept_graph.gd", "")
