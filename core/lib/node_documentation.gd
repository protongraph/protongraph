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
	_docs["warnings"].push_back(warning)


# Performance cost ranges from 0 to 3, 0 means no cost, 3 is a huge cost.
func add_parameter(parameter_name: String, text: String, performance_cost: int = 0) -> void:
	var parameter = {}
	parameter["name"] = parameter_name
	parameter["text"] = text
	parameter["cost"] = performance_cost
	_docs["parameters"].push_back(parameter)


func add_paragraph(text: String, opts: Dictionary) -> void:
	var paragraph = {}
	paragraph["text"] = text
	_docs["paragraphs"].push_back(paragraph)


func get_warnings() -> Array:
	return _docs["warnings"]


func get_parameters() -> Array:
	return _docs["parameters"]


func get_paragraphs() -> Array:
	return _docs["paragraphs"]
