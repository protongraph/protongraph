extends Button

export var normal_icon: Texture
export var animated_icon: Texture

var _icon_button


func _ready() -> void:
	_icon_button = get_child(0)


func _on_build_started() -> void:
	_icon_button.update_texture(animated_icon)


func _on_build_completed() -> void:
	_icon_button.update_texture(normal_icon)
