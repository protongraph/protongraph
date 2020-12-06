extends VBoxContainer


onready var _name_label: Label = $MarginContainer/LabelContainers/HBoxContainer/NameLabel
onready var _text_label: Label = $MarginContainer/LabelContainers/MarginContainer/TextLabel
onready var _cost_icon: TextureRect = $MarginContainer/LabelContainers/HBoxContainer/CostIcon


func _ready():
	_cost_icon.texture = TextureUtil.get_texture("res://ui/icons/arrow_up.svg")


func set_parameter_name(n: String) -> void:
	_name_label.text = n


func set_parameter_description(t: String) -> void:
	_text_label.text = t


func set_parameter_cost(cost: int) -> void:
	match cost:
		0:
			_cost_icon.visible = false
		1:
			_cost_icon.modulate = Color.white
		2:
			_cost_icon.modulate = Color.yellow
		3:
			_cost_icon.modulate = Color.red
