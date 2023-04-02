class_name ViewportShadingPanel
extends Control


signal debug_draw_selected(type: int)
signal light_mode_selected(follow: bool)


@onready var _display_button: OptionButton = %DisplayButton
@onready var _light_button: CheckButton = %LightButton


func _ready() -> void:
	_display_button.add_item("Normal", Viewport.DEBUG_DRAW_DISABLED)
	_display_button.add_item("Wireframe", Viewport.DEBUG_DRAW_WIREFRAME)
	_display_button.add_item("Overdraw", Viewport.DEBUG_DRAW_OVERDRAW)
	_display_button.add_item("Unshaded", Viewport.DEBUG_DRAW_UNSHADED)

	_display_button.item_selected.connect(_on_debug_draw_item_selected)
	_light_button.toggled.connect(_on_light_button_toggled)


func _on_debug_draw_item_selected(index: int) -> void:
	debug_draw_selected.emit(_display_button.get_item_id(index))


func _on_light_button_toggled(enabled: bool) -> void:
	light_mode_selected.emit(enabled)
