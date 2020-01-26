tool
extends PanelContainer


signal load_template(path)

var _file_dialog: FileDialog
var _save_title := "Create a new graph template"
var _load_title := "Load an existing template"
var _default_file_suggestion := "new_template.cgraph"
var _save_mode = true


func _ready() -> void:
	_file_dialog = get_node("FileDialog")
	_file_dialog.visible = false


func _on_load_template_request() -> void:
	print("in load request")
	_save_mode = false
	_file_dialog.window_title = _load_title
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.current_file = ""
	_file_dialog.visible = true


func _on_create_template_request() -> void:
	print("in create request")
	_save_mode = true
	_file_dialog.window_title = _save_title
	_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	_file_dialog.current_file = _default_file_suggestion
	_file_dialog.visible = true


func _on_file_selected(path: String) -> void:
	print("path : ", path)
	if _save_mode:
		var template_file = File.new()
		template_file.open(path, File.WRITE)
		template_file.close()
	emit_signal("load_template", path)
