extends ConceptNodeUi
class_name ConceptNode


signal cache_cleared


var unique_id: String
var ignore := false
var node_pool: NodePool # Injected from template
var thread_pool: ThreadPool # Injected from template
var output := []


var _generation_requested := false # True after calling prepare_output once
var _output_ready := false # True when the background generation was completed


func _enter_tree() -> void:
	._enter_tree()
	_reset_output()
	Signals.safe_connect(self, "gui_value_changed", self, "_on_value_changed")


func is_output_ready() -> bool:
	return _output_ready


# Override this function to return true if the node marks the end of a graphnode
func is_final_output_node() -> bool:
	return false


# Returns the associated data to the given slot index. It either comes from a
# connected input node, or from a local control field in the case of a simple
# type (float, string)
func get_input(idx: int, default = []) -> Array:
	var parent = get_parent()
	if not parent:
		return default

	var inputs: Array = parent.get_left_nodes(self, idx)
	if inputs.size() > 0: # Input source connected, ignore local data
		var res = []
		for input in inputs:
			var node_output = input["node"].get_output(input["slot"], default)
			if node_output is Array:
				res += node_output
			else:
				res.append(node_output)
		return res

	if has_custom_gui():
		var node_output = _get_input(idx)
		if node_output == null:
			return default
		return node_output

	# If no source is connected, check if it's a base type with a value defined on the node itself
	var local_value = _get_default_gui_value(idx)
	if local_value != null:
		return [local_value]

	return default # Not a base type and no source connected


# By default, every input and output is an array. This is just a short hand with
# all the necessary checks that returns the first value of the input.
func get_input_single(idx: int, default = null):
	var input = get_input(idx)
	if input == null or input.size() == 0 or input[0] == null:
		return default
	return input[0]


# Returns what the node generates for a given slot
# This method ensure the output is not calculated more than one time per run.
# It's useful if the output node is connected to more than one node. It ensure
# the results are the same and save some performance
func get_output(idx: int, default := []) -> Array:
	if not is_output_ready():
		_generate_outputs()
		_output_ready = true

	if output.size() < idx + 1:
		return default

	var res = output[idx]
	if not res is Array:
		res = [res]
	if res.size() == 0:
		return default

	# If the output is a node array, we need to duplicate them first otherwise they get passed as
	# references which causes issues when the same output is sent to two different nodes.
	if res[0] is Object and res[0].has_method("duplicate"):
		var duplicates = []
		for i in res.size():
			# TODO move the duplication in a helper function instead
			var node = res[i]
			var duplicate
			if node is Resource:
				duplicate = node.duplicate(true)
			else:
				duplicate = node.duplicate(7)

			# TODO : Check if other nodes needs extra steps
			if node is Path or node is Path2D:
				duplicate.curve = node.curve.duplicate(true)

			# Outputs from final nodes are the responsibility of the ConceptGraph node
			if not is_final_output_node():
				register_to_garbage_collection(duplicate)

			duplicates.append(duplicate)
		return duplicates

	# If it's not a node array, it either contains built in types or nested arrays.
	# Arrays are passed as reference so return a deep copy
	return res.duplicate(true)


func get_output_single(idx: int, default = null):
	var res = get_output(idx)
	if res == null or res.size() == 0 or res[0] == null:
		return default
	return res[0]


# Return the variables exposed to the node inspector. Same format as
# get_property_list [ {name: , type: }, ... ]
func get_exposed_variables() -> Array:
	return []


func get_editor_input(_val):
	return null


# Clears the cache and the cache of every single nodes right to this one.
func reset() -> void:
	clear_cache()
	if get_parent():
		for node in get_parent().get_all_right_nodes(self):
			node.reset()


func clear_cache() -> void:
	_clear_cache()
	_reset_output()
	_output_ready = false
	emit_signal("cache_cleared")


# Because we're saving the tree to a json file, we need each node to explicitely
# specify the data to save. It's also the node responsability to restore it
# when we load the file. Most nodes won't need this but it could be useful for
# nodes that allows the user to type in raw values directly if nothing is
# connected to a slot.
func export_custom_data() -> Dictionary:
	return {}


# This method get exactly what it exported from the export_custom_data method.
# Use it to manually restore the previous node state.
func restore_custom_data(_data: Dictionary) -> void:
	pass


# Override this method when exposing a variable to the inspector. It's up to
# you to decide what to do with the user defined value.
func set_value_from_inspector(_name: String, _value) -> void:
	pass


func register_to_garbage_collection(resource):
	get_parent().register_to_garbage_collection(resource)


# Overide this function in the derived classes to return something usable.
# Generate all the outputs for every output slots declared.
func _generate_outputs() -> void:
	pass


# Overide this function to customize how the output cache should be cleared. If
# you have memory to free or anything else, that's where you should define it.
func _clear_cache():
	pass


# Clear previously generated outputs
func _reset_output():
	for slot in output:
		if slot is Array:
			for res in slot:
				if res is Node:
					res.queue_free()
		elif slot is Node:
			slot.queue_free()

	output = []
	for i in _outputs.size():
		output.append([])


func _on_value_changed(_value, _idx) -> void:
	reset()
	emit_signal("node_changed", self, true)
