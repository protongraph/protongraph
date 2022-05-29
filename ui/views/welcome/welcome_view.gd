extends Control


@onready var new_button: Button = $"%New"
@onready var load_button: Button = $"%Load"


func _ready() -> void:
	new_button.pressed.connect(_on_new_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)


func _on_new_button_pressed() -> void:
	GlobalEventBus.create_graph.emit()


func _on_load_button_pressed() -> void:
	GlobalEventBus.load_graph.emit()
