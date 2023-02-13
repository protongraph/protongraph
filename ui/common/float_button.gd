class_name FloatButton
extends Button

# Handles requesting or closing a new window dock for some panels to attach to.

const WindowIcon := preload("res://ui/icons/icon_window.svg")

@export var subwindow_id: String


func _ready():
	icon = WindowIcon
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	expand_icon = true
	tooltip_text = "Toggle external window"

	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(30, 30)

	pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if WindowManager.has_window(subwindow_id):
		WindowManager.close_window(subwindow_id)
	else:
		WindowManager.request_window(subwindow_id)
