tool
extends GraphNode

class_name ConceptNode


signal delete_node


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


func _connect_signals() -> void:
	self.connect("close_request", self, "_on_close_request")
	self.connect("resize_request", self, "_on_resize_request")


func _on_resize_request(new_size) -> void:
	rect_size = new_size


func _on_close_request() -> void:
	emit_signal("delete_node", self)

