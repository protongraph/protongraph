extends VBoxContainer
class_name Preview2D


signal preview_requested
signal preview_hidden


var is_displayed := false

var _button: Button
var _texture_rect: TextureRect
var _container: Container
var _size: CustomSpinBox
var _image_texture := ImageTexture.new()
var _buffer_rect_size : Vector2
var _noise


func _ready() -> void:
	_button = get_node("Button")
	_container = get_node("Container")
	_texture_rect = get_node("Container/TextureRect")
	_size = get_node("Container/SpinBox")
	_texture_rect.texture = _image_texture


func create_from_noise(noise: Noise) -> void:
	_noise = noise
	var s = _size.value
	_image_texture.create_from_image(noise.get_image(s, s))


func create_from_heightmap(heightmap: ConceptGraphHeightmap) -> void:
	_image_texture.create_from_image(heightmap.get_image())


func create_from_image(image: Image) -> void:
	_image_texture.create_from_image(image)


func _on_button_preview_pressed() -> void:
	if is_displayed:
		_container.visible = false
		is_displayed = false
		_button.text = "Show Preview"
		emit_signal("preview_hidden")
	else:
		is_displayed = true
		_container.visible = true
		_button.text = "Hide Preview"
		emit_signal("preview_requested")


func _on_preview_size_changed(value: float) -> void:
	if is_displayed and _noise:
		create_from_noise(_noise)
