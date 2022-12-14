@tool
extends ProtonNode


#const PrintUi :=

const PrintAsTextUi := preload("./print_as_text.tscn")

var _ui := PrintAsTextUi.instantiate()


func _init() -> void:
	type_id = "output_print"
	title = "Print"
	category = "Output"
	description = "Print the data as text"
	leaf_node = true

	create_input(0, "Any", DataType.ANY)

	var opts = SlotOptions.new()
	opts.custom_ui = _ui
	create_extra(0, "TextArea", DataType.MISC_CUSTOM_UI, opts)


func _generate_outputs() -> void:
	var input := get_input(0)
	var text: String = ""

	for object in input:
		text += str(object) + "\n"

	_ui.set_text(text)
