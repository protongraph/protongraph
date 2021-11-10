class_name ProtonNode
extends Resource


@export var external_data: Dictionary
@export var unique_name: String


var type_id: String
var title: String
var description: String
var category: String
var documentation: NodeDocumentation
var ignore := false

var inputs: Dictionary
var outputs: Dictionary


func create_input(idx, name: String, type: int, options := {}) -> void:
	inputs[idx] = {
		"name": name,
		"type": type,
		"local_value": null,
		"options": options,
	}


func create_output(idx, name: String, type: int, options := {}) -> void:
	outputs[idx] = {
		"name": name,
		"type": type,
		"value": null,
		"options": options,
	}


func get_input(idx, default := []) -> Array:
	return default


# By default, every input and output is an array. This is just a short hand with
# all the necessary checks that returns the first value of the input.
func get_input_single(idx, default = null):
	var input := get_input(idx)
	if input.is_empty() or input[0] == null:
		return default
	return input[0]


func set_output(idx, value) -> void:
	if idx in outputs:
		outputs[idx].value = value

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
	for idx in outputs.keys():
		MemoryUtil.free(outputs.idx.value)
		outputs.idx.value = null

