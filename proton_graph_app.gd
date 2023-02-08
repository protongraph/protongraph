class_name ProtonGraphApp
extends Node


@onready var _view_container: ViewContainer = $%ViewContainer


func _ready():
	get_tree().auto_accept_quit = false

	_view_container.quit_completed.connect(_on_quit_completed)


func _notification(event):
	if event == NOTIFICATION_WM_CLOSE_REQUEST:
		_view_container.save_all_and_quit()


func _on_quit_completed() -> void:
	get_tree().quit()

