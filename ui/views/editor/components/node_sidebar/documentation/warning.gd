class_name Warning
extends Control


onready var _label: Label = $HBoxContainer/Label
onready var _icon: TextureRect = $HBoxContainer/TextureRect
onready var _container: HBoxContainer = $HBoxContainer


func _ready():
	_icon.texture = TextureUtil.get_texture("res://ui/icons/warning.svg")


func set_warning_text(t: String) -> void:
	_label.text = t


func set_warning_level(level: int) -> void:
	match level:
		0:
			_container.modulate = Color.white
		1:
			_container.modulate = Color.yellow
		2:
			_container.modulate = Color.crimson
