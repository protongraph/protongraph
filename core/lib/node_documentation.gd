class_name NodeDocumentation


var _docs: Dictionary


func _init(script_path: String):
	var extension = script_path.get_extension()
	var json_path = script_path.rstrip(extension) + "json"
	_load_documentation(json_path)


func add_warning(text: String, opts: Dictionary = {}) -> void:
	var warning = {}
	warning.text = StringUtil.remove_line_breaks(text)
	warning.level = opts["level"] if "level" in opts else 0
	_docs["warnings"].push_back(warning)


# Performance cost ranges from 0 to 3, 0 means no cost, 3 is a huge cost.
func add_parameter(parameter_name: String, text: String, opts: Dictionary = {}) -> void:
	var parameter = {}
	parameter["name"] = parameter_name
	parameter["text"] = StringUtil.remove_line_breaks(text)
	parameter["cost"] = opts["cost"] if "cost" in opts else 0
	_docs["parameters"].push_back(parameter)


func add_paragraph(text: String, opts: Dictionary = {}) -> void:
	var paragraph = {}
	paragraph["text"] = StringUtil.remove_line_breaks(text)
	_docs["paragraphs"].push_back(paragraph)


func get_warnings() -> Array:
	return _docs["warnings"]


func get_parameters() -> Array:
	return _docs["parameters"]


func get_paragraphs() -> Array:
	return _docs["paragraphs"]


func _load_documentation(json_path) -> void:
	var file = File.new()
	if not file.file_exists(json_path):
		_docs = {
			"warnings": [],
			"paragraphs": [],
			"parameters": []
		}
		return

	file.open(json_path, File.READ)
	var content = file.get_as_text()
	file.close()

	var json := JSON.parse(content)
	if json.error == OK:
		_docs = _validate_dict(json.result)
	else:
		print("Could not parse documentation for ", json_path)
		print(json.error_line, ": ", json.error_string)
		print("--")


func _validate_dict(json: Dictionary) -> Dictionary:
	if not "warnings" in json:
		json["warnings"] = []

	if not "parameters" in json:
		json["parameters"] = []

	if not "paragraphs" in json:
		json["paragraphs"] = []

	for warning in json["warnings"]:
		if not "level" in warning:
			warning["level"] = 0

	for parameter in json["parameters"]:
		if not "cost" in parameter:
			parameter["cost"] = 0

	return json
