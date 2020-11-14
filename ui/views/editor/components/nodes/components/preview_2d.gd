extends VBoxContainer
class_name Preview2D


signal preview_requested
signal preview_hidden


var _image_texture := ImageTexture.new()
var _buffer_rect_size : Vector2
var _index: int
var _preview_outdated := true

onready var _button: Button = $Button
onready var _container: Container = $Container
onready var _texture_rect: TextureRect = $Container/TextureRect
onready var _size_spinbox: CustomSpinBox = $Container/SpinBox


func _ready() -> void:
	_texture_rect.texture = _image_texture
	var parent = get_parent()
	Signals.safe_connect(parent, "cache_cleared", self, "_on_cache_cleared")
	Signals.safe_connect(parent, "output_ready", self, "_on_output_ready")


func link_to_output(idx: int) -> void:
	_index = idx


func generate_preview() -> void:
	if not _preview_outdated:
		return
	
	var source = get_parent().get_output_single(_index)
	if not source:
		return
	
	if source is Noise:
		create_from_noise(source)
	elif source is Heightmap:
		create_from_heightmap(source)
	elif source is Image:
		create_from_image(source)
	
	_preview_outdated = false


func create_from_noise(noise: Noise) -> void:
	var s = _size_spinbox.value
	_image_texture.create_from_image(noise.get_image(s, s))
	_size_spinbox.visible = true


func create_from_heightmap(heightmap: Heightmap) -> void:
	_image_texture.create_from_image(heightmap.get_image())
	_size_spinbox.visible = false


func create_from_image(image: Image) -> void:
	_image_texture.create_from_image(image)
	_size_spinbox.visible = false


func _is_displayed():
	return _container.visible


func _on_button_preview_pressed() -> void:
	if _is_displayed():
		_container.visible = false
		_button.text = "Show Preview"
		emit_signal("preview_hidden")
	else:
		_container.visible = true
		_button.text = "Hide Preview"
		emit_signal("preview_requested")
		if _preview_outdated:
			generate_preview()


func _on_cache_cleared() -> void:
	_preview_outdated = true


func _on_preview_size_changed(_value: float) -> void:
	if _is_displayed():
		generate_preview()


func _on_output_ready() -> void:
	if _is_displayed():
		generate_preview()
