extends Control


@onready var new_button: Button = $LeftContainer/VBoxContainer/Buttons/VBoxContainer/New
@onready var load_button: Button = $LeftContainer/VBoxContainer/Buttons/VBoxContainer/Load


func _ready() -> void:
	new_button.connect("pressed", _on_new_button_pressed)
	load_button.connect("pressed", _on_load_button_pressed)


func _on_new_button_pressed() -> void:
	GlobalEventBus.create_graph.emit()


func _on_load_button_pressed() -> void:
	GlobalEventBus.load_graph.emit()
