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

	# If the graph is already loaded, open the relevant tab directly
	if not path.is_empty():
		# TODO: Tight coupling, check how this could be improved
		var view_container: ViewContainer = GlobalDirectory.get_registered_node("ViewContainer")
		if view_container and view_container.is_graph_loaded(path):
			view_container.focus(path)
			return

	# No path provided, display the file selection popup
	if path.is_empty():
		_file_dialog.show_load_dialog()
		path = await _file_dialog.path_selected

	_load_graph(path)


func _on_save_graph_requested(graph: NodeGraph) -> void:

	# No path assigned to the graph, open the file selection popup
	if graph.save_file_path.is_empty():
		_file_dialog.show_save_dialog()
		graph.save_file_path = await _file_dialog.path_selected

	_save_graph(graph)


func _on_save_graph_as_requested(graph: NodeGraph) -> void:
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
	# Extract data

	# Store to file
	# Write file
	file.save(graph.save_file_path)

	GlobalEventBus.graph_saved.emit(graph)


func _load_graph(path: String) -> void:
	var file := ConfigFile.new()
	file.load(path)

	var graph = NodeGraph.new()
	graph.save_file_path = path

	GlobalEventBus.graph_loaded.emit(graph)
