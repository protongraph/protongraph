class_name ProtonNode
extends Resource


@export var external_data: Dictionary

var sub_graph_id: int
var unique_id: String
var display_name: String
var description: String
var documentation: NodeDocumentation

var _inputs: Dictionary
var _outputs: Dictionary


func create_input(idx, name: String, type: int, options := {}) -> void:
	_inputs[idx] = {
		"name": name,
		"type": type,
		"local_value": null,
		"options": options,
	}


func create_output(idx, name: String, type: int, options := {}) -> void:
	_outputs[idx] = {
		"name": name,
		"type": type,
		"value": null,
		"options": options,
	}


# Overide this function in the derived classes to return something usable.
# Generates all the outputs for every declared outputs.
func _generate_outputs() -> void:
	pass


# Overide this function if you have memory to free or anything else in between
# calls to _generate_outputs.
func _clear_cache():
	pass


# Clear previously generated outputs
func _clear_outputs():
	for idx in _outputs.keys():
		MemoryUtil.free(_outputs.idx.value)
		_outputs.idx.value = null


func get_input(idx):
	pass
