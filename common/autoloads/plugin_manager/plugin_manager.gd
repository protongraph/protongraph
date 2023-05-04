extends Node


const PLUGINS_DIR := "res://plugins/"


var _plugins: Array[Plugin] = []


func _ready() -> void:
	scan_plugins()


func scan_plugins() -> void:
	var plugins_list := DirAccess.get_directories_at(PLUGINS_DIR)

	for plugin_name in plugins_list:
		var plugin_path := PLUGINS_DIR.path_join(plugin_name)
		var dir := DirAccess.open(plugin_path)
		if not dir:
			printerr("Could not open ", plugin_path)
			continue

		dir.include_hidden = false
		dir.include_navigational = false

		dir.list_dir_begin()
		while true:
			var file := dir.get_next()

			if file == "":
				break

			if dir.current_is_dir():
				continue

			if not file.ends_with(".gd") and not file.ends_with(".gdc"):
				continue

			var script = load(plugin_path.path_join(file))
			if script == null:
				print("Error: Failed to load script ", file)
				continue

			var node = script.new()
			if node is Plugin:
				_plugins.push_back(node)
				add_child(node)
				node.enable()
			else:
				MemoryUtil.safe_free(node)

		dir.list_dir_end()
