extends Control

# Handles saving and loading NodeGraph on the disk.


signal cancelled
signal discarded
signal confirmed
signal file_selected


var _black_overlay: Panel
var _unsaved_changes_dialog: ConfirmDialog
var _file_dialog: SaveLoadDialog


func _ready():
	_unsaved_changes_dialog = preload("./unsaved_changes_dialog.tscn").instantiate()
	add_child(_unsaved_changes_dialog)
	_unsaved_changes_dialog.cancelled.connect(_on_confirm_dialog_action.bind(cancelled))
	_unsaved_changes_dialog.discarded.connect(_on_confirm_dialog_action.bind(discarded))
	_unsaved_changes_dialog.confirmed.connect(_on_confirm_dialog_action.bind(confirmed))
	_unsaved_changes_dialog.popup_hide.connect(_hide_overlay)

	_file_dialog = SaveLoadDialog.new()
	add_child(_file_dialog)
	_file_dialog.file_selected.connect(_on_file_selected)
	_file_dialog.close_requested.connect(_hide_overlay)
	_file_dialog.cancelled.connect(_hide_overlay)

	_black_overlay = preload("./black_overlay.tscn").instantiate()
	add_child(_black_overlay)


func load_graph(path: String) -> NodeGraph:
	if path.is_empty():
		show_load_dialog()
		return null

	return NodeGraph.new()


func save_graph(graph: NodeGraph) -> void:
	if graph.save_file_path.is_empty():
		show_save_dialog()



func show_load_dialog() -> void:
	_file_dialog.dialog_mode = SaveLoadDialog.DialogMode.LOAD
	_show_file_dialog()


func show_save_dialog() -> void:
	_file_dialog.dialog_mode = SaveLoadDialog.DialogMode.SAVE
	_show_file_dialog()


func show_confirm_dialog() -> void:
	_show_overlay()
	_unsaved_changes_dialog.popup_centered()


func _show_file_dialog() -> void:
	_show_overlay()
	_file_dialog.show_dialog()


func _show_overlay() -> void:
	_black_overlay.visible = true


func _hide_overlay() -> void:
	_black_overlay.visible = false


func _on_show_confirm_dialog() -> void:
	_show_overlay()
	_unsaved_changes_dialog.popup_centered()


func _on_file_selected(file) -> void:
	_hide_overlay()
	file_selected.emit(file)


func _on_confirm_dialog_action(s: Signal) -> void:
	_hide_overlay()
	s.emit()
