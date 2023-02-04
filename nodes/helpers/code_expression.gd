extends ProtonNode


const CodeUi := preload("./code_expression.tscn")

var _ui := CodeUi.instantiate()


func _init() -> void:
	type_id = "code_expression"
	title = "Expression"
	category = "Helpers"
	description = "Write and execute custom code."

	var opts = SlotOptions.new()
	opts.custom_ui = _ui
	create_extra("code_edit", "Code editor", DataType.MISC_CUSTOM_UI, opts)


func export_custom_data() -> Dictionary:
	var code: String = _ui.get_text()
	print("export: ", code)
	return {"code": code}


func restore_custom_data(_data: Dictionary) -> void:
	print("restoring ", _data)
	if "code" in _data:
		_ui.set_text(_data["code"])


func _generate_outputs() -> void:
	var input: Array = get_input("input")
	var text: String = ""

	for object in input:
		text += str(object) + "\n"

	_ui.set_text(text)
