extends Control

# Handles everything related to saving and loading NodeGraph on the disk.


var _black_overlay: Panel
var _unsaved_changes_dialog: ConfirmDialog
var _file_dialog: SaveLoadDialog


func _ready():
	# Initialize dialogs
	theme = ThemeManager.get_current_theme()
	_unsaved_changes_dialog = preload("./ui/unsaved_changes_dialog.tscn").instantiate()
	add_child(_unsaved_changes_dialog)
	_unsaved_changes_dialog.about_to_popup.connect(_toggle_overlay.bind(true))
	_unsaved_changes_dialog.popup_hide.connect(_toggle_overlay.bind(false))

	_file_dialog = SaveLoadDialog.new()
	add_child(_file_dialog)
	_file_dialog.about_to_popup.connect(_toggle_overlay.bind(true))
	_file_dialog.close_requested.connect(_toggle_overlay.bind(false))
	_file_dialog.cancelled.connect(_toggle_overlay.bind(false))

	_black_overlay = preload("./ui/black_overlay.tscn").instantiate()
	add_child(_black_overlay)

	# Setup signal connections
	GlobalEventBus.load_graph.connect(_on_load_graph_requested)
	GlobalEventBus.save_graph.connect(_on_save_graph_requested)
	GlobalEventBus.save_graph_as.connect(_on_save_graph_as_requested)


func _toggle_overlay(val: bool) -> void:
	_black_overlay.visible = val


func _on_load_graph_requested(path: String = "") -> void:
	# No path provided, display the file selection popup
	if path.is_empty():
		_file_dialog.show_load_dialog()
		path = await _file_dialog.path_selected

	_load_graph(path)


func _on_save_graph_requested(graph: NodeGraph) -> void:
	if not graph:
		return

	# No path assigned to the graph, open the file selection popup
	if graph.save_file_path.is_empty():
		_file_dialog.show_save_dialog()
		graph.save_file_path = await _file_dialog.path_selected

	_save_graph(graph)


func _on_save_graph_as_requested(graph: NodeGraph) -> void:
	if not graph:
		return

	_file_dialog.show_save_dialog()
	var new_path = await _file_dialog.path_selected

	if new_path.is_empty:
		return

	graph.save_file_path = new_path
	_save_graph(graph)


# TODO: move to dedicated loader / saver file?

func _save_graph(graph: NodeGraph) -> void:
	if graph.save_file_path.is_empty():
		return

	var file := ConfigFile.new()

	file.set_value("graph_node", "version", 1)
	file.set_value("graph_node", "connections", graph.connections)
	file.set_value("graph_node", "external_data", graph.external_data)

	for node_name in graph.nodes:
		var node: ProtonNode = graph.nodes[node_name]

		var local_values := {}
		for idx in node.inputs:
			local_values[idx] = node.get_local_value(idx)

		file.set_value(node_name, "type_id", node.type_id)
		file.set_value(node_name, "local_values", local_values)
		file.set_value(node_name, "custom_data", node.export_custom_data())
		file.set_value(node_name, "external_data", node.external_data)

	file.save(graph.save_file_path)
	GlobalEventBus.graph_saved.emit(graph)


func _load_graph(path: String) -> void:
	var file := ConfigFile.new()
	var err = file.load(path)

	if err != OK:
		return

	var graph = NodeGraph.new()
	graph.save_file_path = path

	for node_name in file.get_sections():
		var type_id = file.get_value(node_name, "type_id", "")
		if type_id.is_empty():
			continue

		var data: Dictionary = file.get_value(node_name, "external_data", {})
		data.name = node_name
		var node := graph.create_node(type_id, data, false)
		if not node:
			continue

		var local_values: Dictionary = file.get_value(node_name, "local_values", {})
		for idx in local_values:
			node.set_local_value(idx, local_values[idx])

	graph.connections = file.get_value("graph_node", "connections", [])
	graph.external_data = file.get_value("graph_node", "external_data", {})

	GlobalEventBus.graph_loaded.emit(graph)
