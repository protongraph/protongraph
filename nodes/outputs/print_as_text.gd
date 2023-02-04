extends ProtonNode


const PrintAsTextUi := preload("./print_as_text.tscn")

var _ui := PrintAsTextUi.instantiate()


func _init() -> void:
	type_id = "output_print"
	title = "Print"
	category = "Output"
	description = "Print the data as text"
	leaf_node = true

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("input", "Any", DataType.ANY, opts)

	opts = SlotOptions.new()
	opts.custom_ui = _ui
	create_extra("print", "TextArea", DataType.MISC_CUSTOM_UI, opts)


func _generate_outputs() -> void:
	var input: Array = get_input("input")
	var text: String = ""

	text = str(input.size()) + " items to show:\n\n"

	for object in input:
		text += str(object) + "\n"

	_ui.set_text(text)
