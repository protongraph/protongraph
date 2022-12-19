class_name ProtonNode
extends Resource


var external_data: Dictionary
var unique_name: String
var type_id: String
var title: String
var description: String
var category: String
var documentation := DocumentationData.new()
var ignore := false
var leaf_node := false
var graph: NodeGraph

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
	outputs[idx] = output


func create_extra(idx, name: String, type: int, options := SlotOptions.new()) -> void:
	var extra = ProtonNodeSlot.new()
	extra.name = name
	extra.type = type
	extra.options = options
	extras[idx] = extra


# Override in child class
func export_custom_data() -> Dictionary:
	return {}


func restore_custom_data(_data: Dictionary) -> void:
	pass


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


func set_local_value(idx, value) -> void:
	if idx in inputs:
		inputs[idx].local_value = value
		changed.emit()


func get_local_value(idx) -> Variant:
	if idx in inputs:
		return inputs[idx].local_value
	return null


# Returns the associated data to the given input index. It either comes from a
# connected input node, or from a local control field in the case of a simple
# type (float, string)
func get_input(idx: Variant, default = []) -> Array:
	if not idx in inputs:
		return []

	# Check if connected nodes on this input provided something.
	if inputs[idx].computed_value_ready:
		return inputs[idx].computed_value

	# If no source is connected check the local value provided by the slot gui
	var local_value = get_local_value(idx)
	if local_value != null:
		return [local_value]

	return default # No local value and no source connected


# By default, every input and output is an array. This is just a short hand with
# all the necessary checks that returns the first value of the input.
func get_input_single(idx, default = null):
	var input := get_input(idx)
	if input.is_empty() or input[0] == null:
		return default
	return input[0]


func set_output(idx, value) -> void:
	if not value is Array:
		value = [value]

	if idx in outputs:
		outputs[idx].computed_value = value
		outputs[idx].computed_value_ready = true


func clear_values() -> void:
	for idx in inputs:
		inputs[idx].computed_value.clear()
		inputs[idx].computed_value_ready = false

	for idx in outputs:
		outputs[idx].computed_value.clear()
		outputs[idx].computed_value_ready = false


func is_output_ready(idx = null) -> bool:
	if outputs.is_empty():
		return false

	if idx in outputs:
		return outputs[idx].computed_value_ready

	# No index provided, check them all
	for i in outputs:
		if not outputs[i].computed_value_ready:
			return false

	return true


# Overide this function in the derived classes to return something usable.
# Generates all the outputs for every declared outputs.
func _generate_outputs() -> void:
	pass


# Overide this function if you have memory to free or anything else in between
# calls to _generate_outputs.
func _clear_cache():
	pass

