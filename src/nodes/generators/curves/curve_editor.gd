tool
extends ConceptNode

"""
Generates a curve object made of a single line
"""

var _curve_widget: Control

func _init() -> void:
	unique_id = "function_curve_editor"
	display_name = "Curve Function Editor"
	category = "Generators/Curves"
	description = "Allows you to create and edit a mathematical curve from the graph editor"
	resizable = true
	set_output(0, "Curve", ConceptGraphDataType.CURVE_FUNC)


func _on_default_gui_ready() -> void:
	_create_curve_widget()


func _generate_outputs() -> void:
	output[0] = _curve_widget.get_value()


func export_custom_data() -> Dictionary:
	return {"curve": _curve_widget.get_value(true)}


func restore_custom_data(data: Dictionary) -> void:
	if not _curve_widget:
		_create_curve_widget()
	_curve_widget.set_value(data["curve"])


func _create_curve_widget() -> void:
	if _curve_widget:
		remove_child(_curve_widget)
		_curve_widget.queue_free()

	_curve_widget = preload("res://views/editor/inspector/curve/curve_property.tscn").instance()
	_curve_widget.init("", Curve.new())
	add_child(_curve_widget)
	connect("resize_request", self, "_on_resize")
	update()


# Graphnode doesn't support childnodes with the expand flag so we fake it here
func _on_resize(new_size: Vector2) -> void:
	var new_min_size = _curve_widget.rect_min_size

	# Magic number, probably the combined height of the top and bottom margin. Only works because
	# the curve widget is the only element in the graph node. If there were other, their height
	# should be taken in account as well
	new_min_size.y = new_size.y - 60
	_curve_widget.rect_min_size = new_min_size
