class_name ViewContainer
extends CustomTabContainer


signal quit_completed


const WelcomeViewScene := preload("res://ui/views/welcome/welcome_view.tscn")
const EditorViewScene = preload("res://ui/views/editor/editor_view.tscn")
const SettingsViewScene = preload("res://ui/views/settings/settings_view.tscn")
const ExamplesViewScene = preload("res://ui/views/examples/examples_view.tscn")


var _is_quitting := false


func _ready() -> void:
	super()
	tab_closed.connect(_on_tab_closed)

	GlobalEventBus.create_graph.connect(_on_create_graph)
	GlobalEventBus.graph_loaded.connect(_on_graph_loaded)
	GlobalEventBus.graph_saved.connect(_on_graph_saved)
	GlobalEventBus.open_settings.connect(_on_open_settings)
	GlobalEventBus.browse_examples.connect(_on_browse_examples)


# Loop through all the tabs and close them one by one, then notify the app it
# can safely close.
func save_all_and_quit() -> void:
	_is_quitting = true
	while _is_quitting and get_child_count() > 0:
		change_tab(0)
		var c = get_child(0)

		# Don't close immediately if the current view still have unsaved edits.
		if c is EditorView and c.has_pending_changes():
			_is_quitting = await c.save_and_close()

		# If the previous step wasn't canceled by the user, close the tab.
		if _is_quitting:
			close_tab(0)
			# Give enough time to the engine to update the tree.
			await get_tree().process_frame

	if _is_quitting:
		quit_completed.emit()


# Try to focus on a view with the given type.
# Returns true if it could open the view, false otherwise.
func _focus_view(type) -> bool:
	for c in get_children():
		if c is type:
			change_tab(c.get_index())
			return true

	return false


# Returns -1 if the graph was never loaded before.
# Otherwise, returns the tab id holding its EditorView.
func _get_graph_index(graph: NodeGraph) -> int:
	var path: String = graph.save_file_path

	if path.is_empty():
		return -1

	for c in get_children():
		if c is EditorView and c.get_edited_file_path() == path:
			return c.get_index()

	return -1


func _on_create_graph() -> void:
	_on_graph_loaded(NodeGraph.new())


func _on_graph_loaded(graph: NodeGraph) -> void:
	# If the graph was already loaded, open its editor tab directly.
	var index = _get_graph_index(graph)
	if index != -1:
		change_tab(index)
		return

	# Graph isn't loaded, create a new editor view.
	var editor = EditorViewScene.instantiate()

	if graph.save_file_path.is_empty():
		editor.name = "Untitled Graph"
	else:
		editor.name = graph.save_file_path.get_file().get_basename()

	add_tab(editor)
	editor.edit(graph)


# Ensure the tab name matches the graph file name.
func _on_graph_saved(graph: NodeGraph) -> void:
	if graph.save_file_path.is_empty():
		return # Should not happen

	var graph_name = graph.save_file_path.get_file().get_basename()
	var index := _get_graph_index(graph)
	if index != -1:
		set_tab_name(index, graph_name)


# Open the settings page, or focus it if already opened.
func _on_open_settings() -> void:
	if not _focus_view(SettingsView):
		var settings := SettingsViewScene.instantiate()
		add_tab(settings)


# Open the example pages or focus it if already opened.
func _on_browse_examples() -> void:
	if not _focus_view(ExamplesView):
		var examples := ExamplesViewScene.instantiate()
		add_tab(examples)


func _on_tab_close_pressed(tab: int) -> void:
	var view = get_child(tab)

	if view is EditorView:
		if not await view.save_and_close():
			return

	close_tab(tab)


# Ensure there's always at least one opened tab, unless we're quitting the app.
func _on_tab_closed() -> void:
	if get_child_count() == 0 and not _is_quitting:
		var welcome_view = WelcomeViewScene.instantiate()
		add_tab(welcome_view, true)
