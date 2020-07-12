extends Control

signal curve_updated
signal value_changed


export var c: Curve
export var curve_panel: NodePath

var _curve: Curve
var _curve_panel: Control


func init(name: String, value: Curve) -> void:
	_curve_panel = get_node(curve_panel)
	_curve_panel.connect("curve_updated", self, "_on_curve_updated")
	_curve = value if value else Curve.new()


func set_value(curve) -> void:
	print("Set value called ", curve)
	if curve is Curve:
		_curve = curve

	elif curve is String:
		_curve = Curve.new()
		var data = parse_json(curve)
		for p in data:
			_curve.add_point(p.pos, p.lt, p.rt, p.lm, p.rm)

	_curve_panel.draw_curve(_curve)


func get_value(storage := false):
	if not storage:
		return _curve

	var res = []
	for i in _curve.get_point_count():
		var p := {}
		p["lm"] = _curve.get_point_left_mode(i)
		p["lt"] = _curve.get_point_left_tangent(i)
		p["pos"] = _curve.get_point_position(i)
		p["rm"] = _curve.get_point_right_mode(i)
		p["rt"] = _curve.get_point_right_tangent(i)
		res.append(p)
	return res


func _on_curve_updated() -> void:
	emit_signal("value_changed")
