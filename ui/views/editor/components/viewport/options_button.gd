extends MenuButton


signal show_keymap
signal show_fps
signal use_static_light
signal reset_camera


var _popup: PopupMenu


func _ready():
	icon = TextureUtil.get_texture("res://ui/icons/icon_menu.svg")
	_popup = get_popup()
	_popup.hide_on_checkable_item_selection = false
	_popup.add_check_item("Show Keymap")
	_popup.add_check_item("Show FPS")
	_popup.add_check_item("Use Static Light")
	_popup.add_separator()
	_popup.add_item("Reset Camera")

	_popup.connect("id_pressed", self, "_on_id_pressed")


func _on_id_pressed(id) -> void:
	match id:
		0:
			_on_check_item_pressed(0, "show_keymap")
		1:
			_on_check_item_pressed(1, "show_fps")
		2:
			_on_check_item_pressed(2, "use_static_light")
		4:
			emit_signal("reset_camera")


func _on_check_item_pressed(id, signal_name) -> void:
	var checked = not _popup.is_item_checked(id)
	_popup.set_item_checked(id, checked)
	emit_signal(signal_name, checked)
