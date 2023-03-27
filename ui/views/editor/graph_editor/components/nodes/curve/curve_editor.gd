class_name CurveEditor
extends Control

# The CurveEditor is part of the Curve graphnode component class.
# Allows the user to edit 1D curves.


const PRESET_FLAT_0 := 0
const PRESET_FLAT_1 := 1
const PRESET_LINEAR := 2
const PRESET_EASE_IN := 3
const PRESET_EASE_OUT := 4
const PRESET_SMOOTHSTEP := 5


signal curve_changed


@onready var _panel: CurvePanel = %CurvePanel
@onready var _min: CustomSpinBox = %Min
@onready var _max: CustomSpinBox = %Max
@onready var _resolution: CustomSpinBox = %Resolution
@onready var _snap_toggle_button: Button = %SnapToggleButton
@onready var _snap_spinbox: CustomSpinBox = %SnapSpinbox
@onready var _presets_menu_button: MenuButton = %PresetsMenu


var _curve: Curve
var _presets_popup: PopupMenu


func _ready() -> void:
	_min.value_changed.connect(_on_min_value_changed)
	_max.value_changed.connect(_on_max_value_changed)
	_resolution.value_changed.connect(_update_curve_parameters)
	_panel.curve_updated.connect(_on_curve_changed)
	_snap_toggle_button.toggled.connect(_on_snap_changed)
	_snap_spinbox.value_changed.connect(_on_snap_changed)

	_presets_popup = _presets_menu_button.get_popup()
	_presets_popup.add_item("Flat 0", PRESET_FLAT_0)
	_presets_popup.add_item("Flat 1", PRESET_FLAT_1)
	_presets_popup.add_item("Linear", PRESET_LINEAR)
	_presets_popup.add_item("Ease in", PRESET_EASE_IN)
	_presets_popup.add_item("Ease out", PRESET_EASE_OUT)
	_presets_popup.add_item("Smoothstep", PRESET_SMOOTHSTEP)
	_presets_popup.id_pressed.connect(_on_preset_selected)

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


func _on_snap_changed(_val) -> void:
	_panel.toggle_snap(_snap_toggle_button.button_pressed, _snap_spinbox.value)


func _on_preset_selected(id: int) -> void:
	var curve_preset := Curve.new()

	match id:
		PRESET_FLAT_0:
			curve_preset.add_point(Vector2.ZERO)
		PRESET_FLAT_1:
			curve_preset.add_point(Vector2(0.0, 1.0))
		PRESET_LINEAR:
			curve_preset.add_point(Vector2.ZERO, 0, 0,Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
			curve_preset.add_point(Vector2.ONE, 0, 0,Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
		PRESET_EASE_IN:
			curve_preset.add_point(Vector2.ZERO)
			curve_preset.add_point(Vector2.ONE, (curve_preset.get_max_value() - curve_preset.get_min_value()) * 1.4)
		PRESET_EASE_OUT:
			curve_preset.add_point(Vector2.ZERO, 0, (curve_preset.get_max_value() - curve_preset.get_min_value()) * 1.4)
			curve_preset.add_point(Vector2.ONE)
		PRESET_SMOOTHSTEP:
			curve_preset.add_point(Vector2.ZERO)
			curve_preset.add_point(Vector2.ONE)

	set_curve(curve_preset)


func _on_curve_changed() -> void:
	curve_changed.emit(_curve)
