extends VBoxContainer


onready var name_label = $MarginContainer/LabelContainers/HBoxContainer/NameLabel
onready var text_label = $MarginContainer/LabelContainers/TextLabel
onready var cost_icon: TextureRect = $MarginContainer/LabelContainers/HBoxContainer/CostIcon


func _ready():
	cost_icon.texture = TextureUtil.get_texture("res://ui/icons/curved_arrow_up.svg")


func set_parameter_name(n: String) -> void:
	name_label.text = n


func set_parameter_description(t: String) -> void:
	text_label.text = t


func set_parameter_cost(cost: int) -> void:
	match cost:
		0:
			cost_icon.visible = false
		1:
			cost_icon.modulate = Color.white
		2:
			cost_icon.modulate = Color.yellow
		3:
			cost_icon.modulate = Color.red
