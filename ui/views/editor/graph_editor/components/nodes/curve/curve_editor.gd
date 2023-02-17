class_name CurveEditor
extends Control

# The CurveEditor is part of the Curve graphnode component class.
# Allows the user to edit 1D curves.


signal curve_changed


@onready var _panel: CurvePanel = $%CurvePanel
@onready var _min: CustomSpinBox = $%Min
@onready var _max: CustomSpinBox = $%Max
@onready var _resolution: CustomSpinBox = $%Resolution


var _curve: Curve


func _ready() -> void:
	_min.value_changed.connect(_on_min_value_changed)
	_max.value_changed.connect(_on_max_value_changed)
	_resolution.value_changed.connect(_update_curve_parameters)
	_panel.curve_updated.connect(_on_curve_changed)
	set_curve(_curve)


func set_curve(curve: Curve) -> void:
	_curve = curve

	if _curve and is_instance_valid(_panel):
		_min.set_value_no_undo(curve.min_value)
		_max.set_value_no_undo(curve.max_value)
		_resolution.set_value_no_undo(curve.bake_resolution)
		_panel.set_curve(curve)


func get_curve() -> Curve:
	return _curve


func _update_curve_parameters() -> void:
	if not _curve:
		return

	_curve.set_min_value(_min.value)
	_curve.set_max_value(_max.value)
	_curve.set_bake_resolution(int(_resolution.value))
	_panel.queue_redraw()


func _on_min_value_changed(value: float) -> void:
	if _min.value >= _max.value:
		_min.set_value_no_signal(_max.value - _max.step)

	_update_curve_parameters()


func _on_max_value_changed(value: float) -> void:
	if _max.value <= _min.value:
		_max.set_value_no_signal(_min.value + _min.step)

	_update_curve_parameters()


func _on_curve_changed() -> void:
	curve_changed.emit(_curve)
