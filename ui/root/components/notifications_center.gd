extends Control
class_name NotificationsCenter


var _notification = preload("res://ui/root/components/notification.tscn")

onready var _root: VBoxContainer = $ScrollContainer/VBoxContainer


func _ready() -> void:
	GlobalEventBus.register_listener(self, "template_saved", "_on_template_saved")


func _create(title: String, details: String, icon: Texture, delay: float) -> void:
	var notification = _notification.instance()
	_root.add_child(notification)
	notification.create(title, details, icon, delay)


func _on_template_saved(path: String) -> void:
	var title = "Template saved"
	var details = path
	var icon = TextureUtil.get_texture("res://ui/icons/icon_save.svg")
	_create(title, details, icon, 2.5)
