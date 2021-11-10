class_name SaveLoadDialog
extends FileDialog


enum DialogMode {
	LOAD,
	SAVE,
	SAVE_AS,
}

var dialog_mode: DialogMode = DialogMode.LOAD

var _save_title := "Create a new template"
var _save_as_title := "Save the template as"
var _load_title := "Load an existing template"
var _default_file_suggestion := "new_template.tpgn"


func _ready() -> void:
	file_selected.connect(_on_file_selected)


func show_dialog() -> void:
	match dialog_mode:
		DialogMode.LOAD:
			_load_template()
		DialogMode.SAVE:
			_create_template()
		DialogMode.SAVE_AS:
			_save_template_as()


func _create_template() -> void:
	title = _save_title
	mode = FileDialog.FILE_MODE_SAVE_FILE
	current_file = _default_file_suggestion
	popup_centered()


func _load_template() -> void:
	title = _load_title
	mode = FileDialog.FILE_MODE_OPEN_FILE
	current_file = ""
	popup_centered()


func _save_template_as(opened_file := "") -> void:
	title = _save_as_title
	mode = FileDialog.FILE_MODE_SAVE_FILE
	current_file = opened_file
	popup_centered()


func _on_file_selected(path: String) -> void:
	match dialog_mode:
		DialogMode.LOAD:
			GlobalEventBus.load_template.emit(path)
		DialogMode.SAVE:
			GlobalEventBus.create_template.emit(path)
		DialogMode.SAVE_AS:
			GlobalEventBus.save_template_as.emit(path)
