class_name Notification
extends Control


var _timer: Timer

@onready var _icon: TextureRect = $%TextureRect
@onready var _title: Label = $%TitleLabel
@onready var _details: Label = $%DetailsLabel
@onready var _close: Button = $%CloseButton


func _ready() -> void:
	_timer = Timer.new()
	_timer.autostart = false
	_timer.one_shot = true
	add_child(_timer)

	_timer.timeout.connect(_remove_notification)
	_close.pressed.connect(_remove_notification)


func create(title: String, details: String, notification_icon: Texture, delay := 5.0):
	_icon.texture = notification_icon
	_title.text = title
	_details.text = details
	_details.visible = not details.is_empty()
	_timer.start(delay)


func _remove_notification():
	queue_free()
