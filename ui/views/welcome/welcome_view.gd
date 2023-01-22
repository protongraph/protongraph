extends Control


const FileEntry := preload("./file_entry.tscn")

@onready var new_button: Button = $%New
@onready var load_button: Button = $%Load
@onready var examples_button: Button = $%BrowseExamplesButton
@onready var history_panel: Control = $%HistoryPanel
@onready var files_root: Control = $%FilesRoot


func _ready() -> void:
	new_button.pressed.connect(_on_new_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	examples_button.pressed.connect(_on_browse_examples_button_pressed)
	GlobalEventBus.file_history_changed.connect(_rebuild_history_view)
	_rebuild_history_view()


func _rebuild_history_view() -> void:
	var history := FileHistory.get_list()

	if history.is_empty():
		history_panel.visible = false
		return

	history_panel.visible = true
	NodeUtil.remove_children(files_root)

	for path in history:
		var link: HistoryFileEntry = FileEntry.instantiate()
		files_root.add_child(link)
		link.set_path(path)


func _on_new_button_pressed() -> void:
	GlobalEventBus.create_graph.emit()


func _on_load_button_pressed() -> void:
	GlobalEventBus.load_graph.emit()


func _on_browse_examples_button_pressed() -> void:
	GlobalEventBus.browse_examples.emit()
