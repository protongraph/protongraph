extends FileDialog
class_name LoadSaveDialog


var _save_title := "Create a new template"
var _save_as_title := "Save the template as"
var _load_title := "Load an existing template"
var _default_file_suggestion := "new_template.tpgn"
var _mode := Constants.LOAD


func _ready() -> void:
	Signals.safe_connect(self, "file_selected", self, "_on_file_selected")


func create_template() -> void:
	_mode = Constants.CREATE
	window_title = _save_title
	mode = FileDialog.MODE_SAVE_FILE
	current_file = _default_file_suggestion
	popup_centered()


func load_template() -> void:
	_mode = Constants.LOAD
	window_title = _load_title
	mode = FileDialog.MODE_OPEN_FILE
	current_file = ""
	popup_centered()


func save_template_as(opened_file := "") -> void:
	_mode = Constants.SAVE_AS
	window_title = _save_as_title
	mode = FileDialog.MODE_SAVE_FILE
	current_file = opened_file
	popup_centered()


func _on_file_selected(path: String) -> void:
	match _mode:
		Constants.CREATE:
			GlobalEventBus.dispatch("create_template", path)
		Constants.LOAD:
			GlobalEventBus.dispatch("load_template", path)
		Constants.SAVE_AS:
			GlobalEventBus.dispatch("save_template_as", path)
