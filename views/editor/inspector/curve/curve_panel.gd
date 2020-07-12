extends Control

export var grid_color := Color(1, 1, 1, 0.15)
export var font: Font
export var text_color := Color(0.9, 0.9, 0.9)


func draw_curve(curve: Curve) -> void:
	if not curve:
		return

	var min_edge := Vector2(0, rect_size.y)
	var max_edge := Vector2(rect_size.x, 0)

	draw_line(Vector2(min_edge.x, curve.get_min_value()), Vector2(max_edge.x, curve.get_min_value()), grid_color)
	draw_line(Vector2(max_edge.x, curve.get_max_value()), Vector2(min_edge.x, curve.get_max_value()), grid_color)
	draw_line(Vector2(0, min_edge.y), Vector2(0, max_edge.y), grid_color)
	draw_line(Vector2(1, max_edge.y), Vector2(1, min_edge.y), grid_color)

	var curve_height: float = curve.get_max_value() - curve.get_min_value()
	var grid_steps: Vector2 = Vector2(0.25, 0.5 * curve_height)

	for x in range(0, 1, grid_steps.x):
		draw_line(Vector2(x, min_edge.y), Vector2(x, max_edge.y), grid_color)

	for y in range(curve.get_min_value(), curve.get_max_value(), grid_steps.y):
		draw_line(Vector2(min_edge.x, y), Vector2(max_edge.x, y), grid_color)

	var y: float = curve.get_min_value()
	var font_height: float = font.get_height()
	var off := Vector2(0, font_height - 1)

	draw_string(font, Vector2(0, y) + off, "0.0", text_color)
	draw_string(font, Vector2(0.25, y) + off, "0.25", text_color)
	draw_string(font, Vector2(0.5, y) + off, "0.5", text_color)
	draw_string(font, Vector2(0.75, y) + off, "0.75", text_color)
	draw_string(font, Vector2(1, y) + off, "1.0", text_color)

	var m0: float = curve.get_min_value()
	var m1: float = 0.5 * (curve.get_min_value() + curve.get_max_value())
	var m2: float = curve.get_max_value()
	off = Vector2(1, -1)

	draw_string(font, Vector2(0, m0) + off, String(m0), text_color)
	draw_string(font, Vector2(0, m1) + off, String(m1), text_color)
	draw_string(font, Vector2(0, m2) + off, String(m2), text_color)

