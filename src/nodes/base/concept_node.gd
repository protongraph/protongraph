tool
extends GraphNode

class_name ConceptNode


signal delete_node

var _cached_output


func _ready() -> void:
	if not has_custom_gui():
		title = get_name()
		resizable = true
		show_close = true
	_connect_signals()


func has_custom_gui() -> bool:
	return false


func get_name() -> String:
	return "ConceptNode"


func get_category() -> String:
	return "No category"


func get_description() -> String:
	return "A brief description of the node functionality"

func get_output():
	"""
	Returns what the node generates.
	This method ensure the output is not calculated more than one time per run. It's useful if the
	output node is connected to more than one node. It ensure the results are the same and save
	some performance
	"""
	if _cached_output:
		return _cached_output
	_cached_output = _generate_output()
	return _cached_output


func reset() -> void:
	"""
	Invalidate the cache to force the node to recalculate its output. This method is called
	when something changed earlier in& the graph.
	"""
	_cached_output = null
	# TODO : for each node connected on the right -> reset


func _generate_output():
	"""
	Overide this function in the derived classes to return something usable
	"""
	return null


func _connect_signals() -> void:
	self.connect("close_request", self, "_on_close_request")
	self.connect("resize_request", self, "_on_resize_request")


func _on_resize_request(new_size) -> void:
	rect_size = new_size


func _on_close_request() -> void:
	emit_signal("delete_node", self)

