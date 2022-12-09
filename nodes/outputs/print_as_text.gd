@tool
extends ProtonNode


#const PrintUi :=

var _custom_ui := preload("./print_as_text.tscn").instantiate()


func _init() -> void:
	type_id = "output_print"
	title = "Print"
	category = "Output"
	description = "Print the data as text"
	#resizable = true

	create_input(0, "Any", DataType.ANY)

	#_custom_ui = PrintUi.instantiate()


func get_custom_ui():
	return _custom_ui


func is_final_output_node() -> bool:
	return true


func _generate_outputs() -> void:
	var input := get_input(0)
	var text: String = ""

	for object in input:
		text += String(object) + "\n"

	_custom_ui.set_text(text)
