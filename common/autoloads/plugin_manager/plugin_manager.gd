extends Node


const PLUGINS_DIR := "res://plugins/"


var _plugins: Array[Plugin] = []


func _ready() -> void:
	scan_plugins()


func scan_plugins() -> void:
	var scripts := DirectoryUtil.get_all_valid_scripts_in(PLUGINS_DIR, true)

	for script in scripts:
		var node = script.new()
		if node is Plugin:
			_plugins.push_back(node)
			add_child(node)
			node.enable()
		else:
			MemoryUtil.safe_free(node)
