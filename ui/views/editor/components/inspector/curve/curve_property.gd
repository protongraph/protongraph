extends Control

signal curve_updated
signal value_changed


export var c: Curve
export var curve_panel: NodePath
export var min_value: NodePath
export var max_value: NodePath
export var bake_resolution: NodePath


var _curve: Curve
var _curve_panel: CurvePanel
var _label: Label
var _min: CustomSpinBox
var _max: CustomSpinBox
var _res: CustomSpinBox


func init(name: String, curve: Curve) -> void:
	_curve_panel = get_node(curve_panel)
	Signals.safe_connect(_curve_panel, "curve_updated", self, "_on_curve_updated")

	_min = get_node(min_value)
	_max = get_node(max_value)
	_res = get_node(bake_resolution)
	
	var scale = EditorUtil.get_editor_scale()
	_min.rect_min_size.y *= scale
	_max.rect_min_size.y *= scale
	_res.rect_min_size.y *= scale

	_curve = curve if curve else Curve.new()
	set_value(_curve)

	_label = get_node("Label")
	_label.text = name
	if name == "":
		_label.visible = false

	Signals.safe_connect(_min, "value_changed", self, "_on_parameter_changed", ["min"])
	Signals.safe_connect(_max, "value_changed", self, "_on_parameter_changed", ["max"])
	Signals.safe_connect( _res, "value_changed", self, "_on_parameter_changed", ["res"])


func set_value(curve) -> void:
	if curve is Curve:
		_curve = curve

	elif curve is Dictionary:
		_curve = Curve.new()
		_curve.set_min_value(curve.parameters["min"])
		_curve.set_max_value(curve.parameters["max"])
		_curve.set_bake_resolution(curve.parameters["res"])

		_min.set_value_no_undo(curve.parameters["min"])
		_max.set_value_no_undo(curve.parameters["max"])
		_res.set_value_no_undo(curve.parameters["res"])

		for p in curve.points:
			_curve.add_point(Vector2(p.pos_x, p.pos_y), p.lt, p.rt, p.lm, p.rm)

	_curve_panel.set_curve(_curve)


func get_value(storage := false):
	if not storage:
		return _curve

	# We can't store the curve object in the save file so we turn it in a json first
	return _curve_panel.get_curve_data()


func _on_curve_updated() -> void:
	emit_signal("value_changed")


func _on_parameter_changed(value: float, parameter: String) -> void:
	if not _curve:
		return

	match parameter:
		"min":
			if _min.value >= _max.value:
				_min.value = _max.value - _max.step
		"max":
			if _max.value <= _min.value:
				_max.value = _min.value + _min.step

	_curve.set_min_value(_min.value)
	_curve.set_max_value(_max.value)
	_curve.set_bake_resolution(int(_res.value))
	_curve_panel.update()
