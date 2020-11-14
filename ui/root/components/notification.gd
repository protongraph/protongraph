extends Control
class_name Notification


var _timer: Timer

onready var _icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/TextureRect
onready var _title: Label = $MarginContainer/VBoxContainer/HBoxContainer/Title
onready var _details: Label = $MarginContainer/VBoxContainer/Details


func _ready() -> void:
	_timer = Timer.new()
	_timer.autostart = false
	_timer.one_shot = true
	add_child(_timer)
	
	Signals.safe_connect(self, "pressed", self, "_remove_notification")
	Signals.safe_connect(_timer, "timeout", self, "_remove_notification")


func create(title: String, details: String, icon: Texture, delay := 5.0):
	_icon.texture = icon
	_title.text = title
	_details.text = details
	
	var container: MarginContainer = get_child(0)
	var margin = container.get("custom_constants/margin_top") + container.get("custom_constants/margin_bottom") 
	container.rect_size.y = 0
	rect_min_size.y = container.rect_size.y - margin
	
	if delay > 0:
		_timer.start(delay)


func _remove_notification():
	self.queue_free()
