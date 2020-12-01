class_name NodeDocumentation


var _docs: Dictionary


func _init():
	_docs = {
		"warnings": [],
		"parameters": [],
		"paragraphs": []
	}


func add_warning(text: String, opts: String) -> void:
	var warning = {}
	warning.text = text


func set_parameter(parameter_name: String, text: String) -> void:
	var parameter = {}
	parameter["name"] = parameter_name
	parameter["text"] = text
	_docs["parameters"][parameter_name] = parameter


func add_paragraph(text: String, opts: Dictionary) -> void:
	var paragraph = {}
	paragraph["text"] = text
	_docs["paragraphs"].push_back(paragraph)
