class_name ProtonNode
extends Resource


@export var external_data: Dictionary
@export var unique_name: String

var type_id: String
var title: String
var description: String
var category: String
var documentation: DocumentationData
var ignore := false

# Dictionary format: { idx : ProtonNodeSlot }
var inputs: Dictionary
var outputs: Dictionary
var extras: Dictionary


func create_input(idx, name: String, type: int, options := SlotOptions.new()) -> void:
	var input = ProtonNodeSlot.new()
	input.name = name
	input.type = type
	input.local_value = null
	input.options = options
	inputs[idx] = input


func create_output(idx, name: String, type: int, options := SlotOptions.new()) -> void:
	var output = ProtonNodeSlot.new()
	output.name = name
	output.type = type
	output.options = options
	output.computed_value = null
	outputs[idx] = output


# Automatically change the output type to mirror the type of what's
# connected to the input slot
func enable_type_mirroring_on_slot(input_idx, output_idx) -> void:
	if input_idx in inputs and output_idx in outputs:
		var slot = outputs.output_index
		slot.mirror_type_from = input_idx
		slot.original_type = slot.type


func disable_type_mirroring_on_slot(output_idx) -> void:
	if output_idx in outputs:
		var slot = outputs.output_idx
		slot.mirror_type_from = null
		slot.type = slot.original_type


# Allows multiple connections on the same input slot.
func allow_multiple_connections_on_input_slot(idx: int, enabled := true) -> void:
	if idx in inputs:
		inputs[idx].allow_multiple_connections = enabled


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
		outputs[idx].computed_value = value


func set_input_slot_visibility(idx, visible: bool) -> void:
	_set_slot_visibility(inputs, idx, visible)


func set_output_slot_visibility(idx, visible: bool) -> void:
	_set_slot_visibility(outputs, idx, visible)


func set_extra_slot_visibility(idx, visible: bool) -> void:
	_set_slot_visibility(extras, idx, visible)


func _set_slot_visibility(dict: Dictionary, idx, visible: bool) -> void:
	if idx in dict:
		dict[idx].visible = visible


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
	for idx in outputs:
		MemoryUtil.safe_free(outputs[idx].computed_value)
		outputs[idx].computed_value = null

