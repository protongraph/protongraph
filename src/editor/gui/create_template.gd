tool
extends PanelContainer


signal load_template(path)

var _file_dialog: FileDialog
var _save_title := "Create a new graph template"
var _load_title := "Load an existing template"
var _default_file_suggestion := "new_template.cgraph"
var _save_mode = true

# TODO : Move this in a default template file instead
var default_output_node : String = '{"connections":[],"nodes":[{"data":{},"editor":{"offset_x":100,"offset_y":20,"slots":{}},"name":"GraphNode","type":"final_output"}]}'


func _ready() -> void:
	_file_dialog = get_node("FileDialog")
	_file_dialog.visible = false


func _on_load_template_request() -> void:
	_save_mode = false
	_file_dialog.window_title = _load_title
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.current_file = ""
	_file_dialog.popup_centered()


func _on_create_template_request() -> void:
	_save_mode = true
	_file_dialog.window_title = _save_title
	_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	_file_dialog.current_file = _default_file_suggestion
	_file_dialog.popup_centered()


func _on_file_selected(path: String) -> void:
	if _save_mode:
		var template_file = File.new()
		template_file.open(path, File.WRITE)
		template_file.store_line(default_output_node)
		template_file.close()
	emit_signal("load_template", path)
