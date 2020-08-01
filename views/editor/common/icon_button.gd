extends MarginContainer

export var margin := 4
var _button: Button
var _texture_rect: TextureRect
var _updating := false


func _ready() -> void:
	_button = get_parent()
	_texture_rect = get_child(0)

	var scaled_margin = margin * ConceptGraphEditorUtil.get_editor_scale()

	add_constant_override("margin_bottom", scaled_margin)
	add_constant_override("margin_top", scaled_margin)
	add_constant_override("margin_left", scaled_margin)
	add_constant_override("margin_right", scaled_margin)

	update_texture()

	_button.connect("resized", self, "_on_button_resized")


func update_texture(texture: Texture = null) -> void:
	if not texture:
		texture = _button.icon
	_texture_rect.texture = texture
	_button.icon = null


func _on_button_resized():
	if _updating:
		return

	_updating = true
	var l = max(_button.rect_size.x, _button.rect_size.y) - 1
	_button.rect_min_size = Vector2(l, l)
	update()
	_updating = false
