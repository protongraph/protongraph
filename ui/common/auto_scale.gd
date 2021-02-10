extends Control


export var min_size_x := false
export var min_size_y := false
export var const_separation := false

onready var scale = EditorUtil.get_editor_scale()


func _ready() -> void:
	if is_equal_approx(scale, 1.0):
		return

	if min_size_x:
		rect_min_size.x *= scale

	if min_size_y:
		rect_min_size.y *= scale

	if const_separation:
		var s = get_constant("separation")
		add_constant_override("separation", s * scale)

	_scale_custom_margins()


func _scale_custom_margins() -> void:
	var ref = self
	if not ref is MarginContainer:
		return

	var top = get_constant("margin_top") * scale
	var bottom = get_constant("margin_bottom") * scale
	var left = get_constant("margin_left") * scale
	var right = get_constant("margin_right") * scale

	set("custom_constants/margin_top", top)
	set("custom_constants/margin_bottom", bottom)
	set("custom_constants/margin_left", left)
	set("custom_constants/margin_right", right)
