extends Control

# Handles everything related to saving and loading NodeGraph on the disk.


const UnsavedChangesDialogScene := preload("./ui/unsaved_changes_dialog.tscn")
const BlackOverlayScene := preload("./ui/black_overlay.tscn")

var _black_overlay: Panel
var _unsaved_changes_dialog: UnsavedChangesConfirmDialog
var _file_dialog: SaveLoadDialog


func _ready():
	# Initialize dialogs
	theme = ThemeManager.get_current_theme()
	_unsaved_changes_dialog = UnsavedChangesDialogScene.instantiate()
	add_child(_unsaved_changes_dialog)
	_unsaved_changes_dialog.about_to_popup.connect(_toggle_overlay.bind(true))
	_unsaved_changes_dialog.popup_hide.connect(_toggle_overlay.bind(false))
	_unsaved_changes_dialog.confirmed.connect(_on_saving_confirmed)
	_unsaved_changes_dialog.canceled.connect(_on_saving_canceled)
	_unsaved_changes_dialog.discarded.connect(_on_graph_discarded)

	_file_dialog = SaveLoadDialog.new()
	add_child(_file_dialog)
	_file_dialog.about_to_popup.connect(_toggle_overlay.bind(true))
	_file_dialog.close_requested.connect(_toggle_overlay.bind(false))
	_file_dialog.get_cancel_button().pressed.connect(_toggle_overlay.bind(false))

	_black_overlay = BlackOverlayScene.instantiate()
	add_child(_black_overlay)

	# Setup signal connections
	GlobalEventBus.load_graph.connect(_on_load_graph_requested)
	GlobalEventBus.save_graph.connect(_on_save_graph_requested)
	GlobalEventBus.save_graph_as.connect(_on_save_graph_as_requested)


func _toggle_overlay(val: bool) -> void:
	_black_overlay.visible = val


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
	graph.pending_changes = false

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
	graph.pending_changes = false

	# TODO:
	# When loading partially failed (missing nodes), display a confirm dialog
	# asking the user to either cancel, or load the graph without the missing
	# nodes (and show a list of nodes that couldn't be loaded)
	# If the user loads the partial graph, the connections array must first
	# be cleaned up

	GlobalEventBus.graph_loaded.emit(graph)


func _on_load_graph_requested(path: String = "") -> void:
	# No path provided, display the file selection popup
	if path.is_empty():
		_file_dialog.show_load_dialog()
		path = await _file_dialog.path_selected

	_load_graph(path)


func _on_save_graph_requested(graph: NodeGraph, show_confirm_dialog := false) -> void:
	if show_confirm_dialog:
		_unsaved_changes_dialog.show_for(graph)
		return

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

	# Prompt user for a new path
	_file_dialog.show_save_dialog()
	graph.save_file_path  = await _file_dialog.path_selected

	_save_graph(graph)


func _on_saving_confirmed(graph: NodeGraph) -> void:
	await _on_save_graph_requested(graph)
	GlobalEventBus.save_status_updated.emit("saved")


func _on_saving_canceled(_graph: NodeGraph) -> void:
	GlobalEventBus.save_status_updated.emit("canceled")


func _on_graph_discarded(_graph: NodeGraph) -> void:
	GlobalEventBus.save_status_updated.emit("discarded")


