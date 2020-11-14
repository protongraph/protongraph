tool
extends ProtonNode


var _source_scene = load("res://nodes/outputs/print_area.tscn")
var _print_area: Control
var _label: Label


func _init() -> void:
	unique_id = "output_console"
	display_name = "Print"
	category = "Output"
	description = "Print the data as text"
	resizable = true
	
	set_input(0, "Any", DataType.ANY)


func is_final_output_node() -> bool:
	return true


func _generate_outputs() -> void:
	var input := get_input(0)
	_label.text = ""
	
	for object in input:
		if object is Object:
			_label.text += object.to_string() + "\n"
		else:
			_label.text += String(object) + "\n"


func _on_default_gui_ready() -> void:
	_create_text_container()
	

func _create_text_container() -> void:
	if _print_area:
		if has_node(_print_area.name):
			remove_child(_print_area)
		_print_area.queue_free()

	_print_area = load("res://nodes/outputs/print_area.tscn").instance()
	_label = _print_area.get_node("PanelContainer/Label")
	add_child(_print_area)
	Signals.safe_connect(self, "resize_request", self, "_on_resize")
	update()


# Graphnode doesn't support childnodes with the expand flag so we fake it here
func _on_resize(new_size: Vector2) -> void:
	_print_area.rect_min_size.y = max(new_size.y - 60, 32 * EditorUtil.get_editor_scale())

