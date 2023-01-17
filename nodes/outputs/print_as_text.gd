extends ProtonNode


const PrintAsTextUi := preload("./print_as_text.tscn")

var _ui := PrintAsTextUi.instantiate()


func _init() -> void:
	type_id = "output_print"
	title = "Print"
	category = "Output"
	description = "Print the data as text"
	leaf_node = true

	create_input("input", "Any", DataType.ANY)

	var opts = SlotOptions.new()
	opts.custom_ui = _ui
	create_extra("print", "TextArea", DataType.MISC_CUSTOM_UI, opts)


func _generate_outputs() -> void:
	var input := get_input("input")
	var text: String = ""

	for object in input:
		text += str(object) + "\n"

	_ui.set_text(text)
