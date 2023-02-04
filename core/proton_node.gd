class_name ProtonNode
extends Resource


signal local_value_changed(idx, value)
signal layout_changed


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


func create_input(idx: String, name: String, type: int, options := SlotOptions.new()) -> void:
	if not _slot_creation_check(idx, inputs):
		return

	var input = ProtonNodeSlot.new()
	input.name = name
	input.type = type
	input.original_type = type
	input.local_value = null
	input.options = options
	inputs[idx] = input


func create_output(idx: String, name: String, type: int, options := SlotOptions.new()) -> void:
	if not _slot_creation_check(idx, outputs):
		return

	var output = ProtonNodeSlot.new()
	output.name = name
	output.type = type
	output.original_type = type
	output.options = options
	outputs[idx] = output


func create_extra(idx: String, name: String, type: int, options := SlotOptions.new()) -> void:
	if not _slot_creation_check(idx, extras):
		return

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
		var output_slot: ProtonNodeSlot = outputs[output_idx]
		output_slot.mirror_type_from = input_idx

		var input_slot: ProtonNodeSlot = inputs[input_idx]
		input_slot.mirror_type_to.push_back(output_idx)


func disable_type_mirroring_on_slot(output_idx) -> void:
	if output_idx in outputs:
		var output_slot: ProtonNodeSlot = outputs[output_idx]
		var input_idx: String = output_slot.mirror_type_from
		output_slot.mirror_type_from = ""
		output_slot.type = output_slot.original_type

		var input_slot: ProtonNodeSlot = inputs[input_idx]
		input_slot.mirror_type_to.erase(output_idx)
		if input_slot.mirror_type_to.is_empty():
			input_slot.type = input_slot.original_type


func set_local_value(idx: String, value: Variant) -> void:
	if idx in inputs:
		inputs[idx].local_value = value
		changed.emit()
		local_value_changed.emit(idx, value)


func get_local_value(idx: String) -> Variant:
	if idx in inputs:
		return inputs[idx].local_value
	return null


# Returns the associated data to the given input index. It either comes from a
# connected input node, or from a local control field in the case of a simple
# type (float, string)
func get_input(idx: String, default = []):
	if not idx in inputs:
		push_error("Error in ", type_id, ", Input ", idx, " was not defined")
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
func get_input_single(idx: String, default = null):
	var input: Array = get_input(idx)
	if input.is_empty() or input[0] == null:
		return default
	return input[0]


# Called from the parent graph when  passing values from previous
# nodes to this one.
func set_input(idx: String, value) -> void:
	if not idx in inputs:
		push_error("Invalid index: ", idx, " was not found in inputs")
		return

	if not value is Array:
		value = [value]

	# Append the value to the existing one in case multiple nodes are connected
	# to this same input.
	inputs[idx].computed_value.append_array(value)
	inputs[idx].computed_value_ready = true

	# Outputs are no longer valid, reset them.
	for o_idx in outputs:
		outputs[o_idx].computed_value = []
		outputs[o_idx].computed_value_ready = false


# Called from the custom nodes when generating values.
func set_output(idx: String, value) -> void:
	if not idx in outputs:
		push_error("Invalid index: ", idx, " was not found in outputs")
		return

	if not value is Array:
		value = [value]

	outputs[idx].computed_value = value
	outputs[idx].computed_value_ready = true


func clear_values() -> void:
	for idx in inputs:
		inputs[idx].computed_value = []
		inputs[idx].computed_value_ready = false

	for idx in outputs:
		outputs[idx].computed_value = []
		outputs[idx].computed_value_ready = false


# Check if an output has been computed.
# If no specific idx is provided, returns true if every output have been computed,
# false overwise.
func is_output_ready(idx: String = "") -> bool:
	if outputs.is_empty():
		return false

	if idx.is_empty(): # No index provided, check them all
		for i in outputs:
			if not outputs[i].computed_value_ready:
				return false
		return true

	if not idx in outputs:
		return false

	return outputs[idx].computed_value_ready


func _slot_creation_check(idx: String, map: Dictionary) -> bool:
	if idx.is_empty():
		push_error("Cannot create slot with an empty id.")
		return false

	if idx in map:
		push_error("Slot id ", idx, " already exists, aborting.")
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


func _to_string() -> String:
	return "[" + unique_name + "]"
