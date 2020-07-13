tool
extends ConceptNode

"""
Generates a curve object made of a single line
"""

var _curve_widget: Control

func _init() -> void:
	unique_id = "function_curve_editor"
	display_name = "Function Curve Editor"
	category = "Generators/Curves"
	description = "Allows you to create and edit a mathematical curve from the graph editor"
	resizable = true
	set_output(0, "Curve", ConceptGraphDataType.CURVE_FUNC)


func _ready() -> void:
	_curve_widget = preload("res://views/editor/inspector/curve/curve_property.tscn").instance()
	_curve_widget.init("", Curve.new())
	add_child(_curve_widget)
	update()


func _generate_outputs() -> void:
	output[0] = _curve_widget.get_value()


func export_custom_data() -> Dictionary:
	return {"curve": _curve_widget.get_value(true)}


func restore_custom_data(data: Dictionary) -> void:
	_curve_widget.set_value(data["curve"])
