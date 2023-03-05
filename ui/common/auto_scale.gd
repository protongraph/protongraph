class_name AutoScale
extends Node

# Automatically resize the parent (or siblings) control to take in account the
# custom editor scale.

@export_enum("Parent", "Siblings") var targets: int = 0
@export var min_size_x := true
@export var min_size_y := true
@export var const_separation := false
@export var font_size_override := false

var _targets := {}

class SizingData:
	var size: Vector2
	var font_size: int
	var separation: int
	var margin_top: int
	var margin_bottom: int
	var margin_left: int
	var margin_right: int


func _ready() -> void:
	var parent = get_parent()

	if targets == 0:
		if parent is Control:
			_targets[parent] = SizingData.new()
	else:
		for c in parent.get_children():
			if c is Control:
				_targets[c] = SizingData.new()

	for target in _targets.keys():
		var data: SizingData = _targets[target]
		data.size = target.custom_minimum_size
		data.font_size = target.get_theme_constant("font_size")
		data.separation = target.get_theme_constant("separation")
		data.margin_top = target.get_theme_constant("margin_top")
		data.margin_bottom = target.get_theme_constant("margin_bottom")
		data.margin_left = target.get_theme_constant("margin_left")
		data.margin_right = target.get_theme_constant("margin_right")


	_update_scaling()
	GlobalEventBus.settings_updated.connect(_on_settings_updated)


func _update_scaling() -> void:
	var editor_scale := EditorUtil.get_editor_scale()

	for target in _targets.keys():
		var data: SizingData = _targets[target]

		if min_size_x:
			target.custom_minimum_size.x = data.size.x * editor_scale

		if min_size_y:
			target.custom_minimum_size.y = data.size.y * editor_scale

		if const_separation:
			target.add_theme_constant_override("separation", data.separation * editor_scale)

		if font_size_override:
			target.add_theme_font_size_override("font_size", data.font_size * editor_scale)

		if target is MarginContainer:
			target.add_theme_constant_override("margin_top", data.margin_top * editor_scale)
			target.add_theme_constant_override("margin_bottom", data.margin_bottom * editor_scale)
			target.add_theme_constant_override("margin_left", data.margin_left * editor_scale)
			target.add_theme_constant_override("margin_right", data.margin_right * editor_scale)


func _on_settings_updated(setting) -> void:
	if setting == Settings.EDITOR_SCALE:
		_update_scaling()
