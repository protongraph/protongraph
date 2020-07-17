extends FileDialog


signal template_requested


var _save_title := "Create a new graph template"
var _load_title := "Load an existing template"
var _default_file_suggestion := "new_template.cgraph"
var _save_mode := true

# TODO : Move this in a default template file instead
var default_output_node : String = '{"editor":{"offset_x":-300, "offset_y":-200},"connections":[],"nodes":[{"data":{},"editor":{"offset_x":0,"offset_y":0,"slots":{}},"name":"GraphNode","type":"final_output"}]}'


func _ready() -> void:
	Signals.safe_connect(self, "file_selected", self, "_on_file_selected")


func create_template() -> void:
	_save_mode = true
	window_title = _save_title
	mode = FileDialog.MODE_SAVE_FILE
	current_file = _default_file_suggestion
	popup_centered()


func load_template() -> void:
	_save_mode = false
	window_title = _load_title
	mode = FileDialog.MODE_OPEN_FILE
	current_file = ""
	popup_centered()


func _on_file_selected(path: String) -> void:
	if _save_mode:
		var template_file = File.new()
		template_file.open(path, File.WRITE)
		template_file.store_line(default_output_node)
		template_file.close()
	emit_signal("template_requested", path)
