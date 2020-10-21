extends MenuButton

# Broadcast a global event when one of the entry is clicked. No logic happens
# here, it only sends commands.


var _new_icon = TextureUtil.get_texture("res://ui/icons/icon_new.svg")
var _load_icon = TextureUtil.get_texture("res://ui/icons/icon_load.svg")
var _save_icon = TextureUtil.get_texture("res://ui/icons/icon_save.svg")
var _settings_icon = TextureUtil.get_texture("res://ui/icons/icon_cog.svg")
var _close_icon = TextureUtil.get_texture("res://ui/icons/icon_close.svg")


func _ready() -> void:
	var popup = get_popup()
	popup.connect("id_pressed", self, "_on_id_pressed")
	popup.add_icon_item(_new_icon, "New Template", 0)
	popup.add_icon_item(_load_icon, "Load Template", 1)
	popup.add_separator()
	popup.add_icon_item(_save_icon, "Save Template", 10)
	popup.add_icon_item(_save_icon, "Save Template As", 12)
	popup.add_icon_item(_save_icon, "Save All Templates", 14)
	popup.add_separator()
	popup.add_icon_item(_settings_icon, "Settings", 20)
	popup.add_separator()
	popup.add_icon_item(_close_icon, "Quit", 30)

	var l = max(rect_size.x, rect_size.y)
	rect_min_size = Vector2(l, l)


func _on_id_pressed(id) -> void:
	match id:
		0:
			GlobalEventBus.dispatch("create_template")
		1:
			GlobalEventBus.dispatch("load_template")
		10:
			GlobalEventBus.dispatch("save_template")
		12:
			GlobalEventBus.dispatch("save_template_as")
		14:
			GlobalEventBus.dispatch("save_all_templates")
		20:
			GlobalEventBus.dispatch("open_settings")
		30:
			GlobalEventBus.dispatch("quit")
