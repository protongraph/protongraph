extends Control

signal curve_updated
signal value_changed


export var c: Curve
export var curve_panel: NodePath

var _curve: Curve
var _curve_panel: Control
var _label: Label


func init(name: String, value: Curve) -> void:
	_curve_panel = get_node(curve_panel)
	_curve_panel.connect("curve_updated", self, "_on_curve_updated")
	_curve = value if value else Curve.new()
	set_value(_curve)

	_label = get_node("Label")
	_label.text = name
	if name == "":
		_label.visible = false



func set_value(curve) -> void:
	if curve is Curve:
		_curve = curve

	elif curve is Array:
		_curve = Curve.new()
		for p in curve:
			_curve.add_point(Vector2(p.pos_x, p.pos_y), p.lt, p.rt, p.lm, p.rm)

	_curve_panel.set_curve(_curve)


func get_value(storage := false):
	if not storage:
		return _curve

	return _curve_panel.get_curve_data()
	# We can't store the curve object in the save file so we turn in in a json first



func _on_curve_updated() -> void:
	emit_signal("value_changed")
