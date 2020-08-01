extends MenuButton


signal menu_action


var _new_icon = preload("res://icons/icon_new.svg")
var _load_icon = preload("res://icons/icon_load.svg")
var _save_icon = preload("res://icons/icon_save.svg")
var _settings_icon = preload("res://icons/icon_cog.svg")
var _close_icon = preload("res://icons/icon_close.svg")


func _ready() -> void:
	var popup = get_popup()
	popup.connect("id_pressed", self, "_on_id_pressed")
	popup.add_icon_item(_new_icon, "New Template", 0)
	popup.add_icon_item(_load_icon, "Load Template", 1)
	popup.add_separator()
	popup.add_icon_item(_save_icon, "Save Template", 10)
	popup.add_separator()
	popup.add_icon_item(_settings_icon, "Settings", 20)
	popup.add_separator()
	popup.add_icon_item(_close_icon, "Quit", 30)

	var l = max(rect_size.x, rect_size.y)
	rect_min_size = Vector2(l, l)


func _on_id_pressed(id) -> void:
	match id:
		0:
			emit_signal("menu_action", "new")
		1:
			emit_signal("menu_action", "load")
		10:
			emit_signal("menu_action", "save")
		20:
			emit_signal("menu_action", "settings")
		30:
			emit_signal("menu_action", "quit")
