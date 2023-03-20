class_name TexturePreviewUi
extends Control


var _source: Variant
var _preview_outdated := true

@onready var _button: Button = %TogglePreviewButton
@onready var _container: Container = %PreviewContainer
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _size_spinbox: CustomSpinBox = %Spinbox


func _ready() -> void:
	_button.pressed.connect(_on_toggle_preview_button_pressed)
	_size_spinbox.value_changed.connect(_on_preview_size_changed)
	_container.visible = false


func show_preview_for(source: Variant) -> void:
	_source = source
	_preview_outdated = true

	if _is_displayed():
		_update_preview()


func _update_preview() -> void:
	if not _preview_outdated:
		return

	if _source is ProtonNoise:
		_create_from_noise()
	elif _source is Image:
		_create_from_image()
	else:
		print_debug("Unsupported type for 2D preview: ", typeof(_source))
		print_debug("source: ", _source)

	_preview_outdated = false


func _create_from_noise() -> void:
	var noise := _source as ProtonNoise
	var s = _size_spinbox.value
	_texture_rect.texture = ImageTexture.create_from_image(noise.get_image(s, s))
	_size_spinbox.visible = true


#func create_from_heightmap(heightmap: Heightmap) -> void:
#	_image_texture.create_from_image(heightmap.get_image())
#	_size_spinbox.visible = false


func _create_from_image() -> void:
	var image := _source as Image
	_texture_rect.texture = ImageTexture.create_from_image(image)
	_size_spinbox.visible = false


func _is_displayed():
	return _container.visible


func _on_toggle_preview_button_pressed() -> void:
	if _is_displayed():
		_container.visible = false
		_button.text = "Show Preview"
	else:
		_container.visible = true
		_button.text = "Hide Preview"
		_update_preview()


func _on_preview_size_changed(_value: float) -> void:
	_preview_outdated = true
	if _is_displayed():
		_update_preview()
