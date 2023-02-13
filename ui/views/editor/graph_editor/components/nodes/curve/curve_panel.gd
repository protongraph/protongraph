class_name CurvePanel
extends Control


# Recreaton of Godot curve editor in GDscript.


signal curve_updated


@export var grid_color := Color(1, 1, 1, 0.2)
@export var grid_color_sub := Color(1, 1, 1, 0.1)
@export var curve_color := Color(1, 1, 1, 0.9)
@export var point_color := Color.WHITE
@export var selected_point_color := Color.ORANGE
@export var point_radius := 4.0
@export var text_color := Color(0.9, 0.9, 0.9)
@export var columns := 4
@export var rows := 2
@export var dynamic_row_count := true

var _curve: Curve
var _font: Font


var _hover_point := -1:
	set(val):
		if val != _hover_point:
			_hover_point = val
			queue_redraw()

var _selected_point := -1:
	set(val):
		if val != _selected_point:
			_selected_point = val
			queue_redraw()

var _selected_tangent := -1:
	set(val):
		if val != _selected_tangent:
			_selected_tangent = val
			queue_redraw()

var _dragging := false
var _hover_radius := 50.0 # Squared
var _tangents_length := 30.0
var _undo_data := {}


func _ready() -> void:
	_font = ThemeManager.get_default_font()
	custom_minimum_size.y *= EditorUtil.get_editor_scale()
	queue_redraw()
	resized.connect(_on_resized)


func get_curve() -> Curve:
	return _curve


func set_curve(c: Curve) -> void:
	_curve = c
	queue_redraw()


func get_curve_data() -> Dictionary:
	var res = {}
	res.points = []
	for i in _curve.get_point_count():
		var p := {}
		p["lm"] = _curve.get_point_left_mode(i)
		p["lt"] = _curve.get_point_left_tangent(i)
		var pos = _curve.get_point_position(i)
		p["pos_x"] = pos.x
		p["pos_y"] = pos.y
		p["rm"] = _curve.get_point_right_mode(i)
		p["rt"] = _curve.get_point_right_tangent(i)
		res.points.push_back(p)

	res.parameters = {
		"min": _curve.get_min_value(),
		"max": _curve.get_max_value(),
		"res": _curve.get_bake_resolution(),
	}
	return res


func _gui_input(event) -> void:
	if event is InputEventKey:
		if _selected_point != -1 and event.scancode == KEY_DELETE:
			remove_point(_selected_point)

	elif event is InputEventMouseButton:
		if event.double_click:
			print("here")
			add_point(_to_curve_space(event.position))

		elif event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			var i = get_point_at(event.position)
			if i != -1:
				remove_point(i)

		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_selected_tangent = get_tangent_at(event.position)

			if _selected_tangent == -1:
				_selected_point = get_point_at(event.position)
			if _selected_point != -1:
				_dragging = true

		elif _dragging and not event.pressed:
			_dragging = false
			# TODO Commit action

	elif event is InputEventMouseMotion:
		if _dragging:
			if _undo_data.is_empty():
				_undo_data = get_curve_data()

			var curve_amplitude: float = _curve.get_max_value() - _curve.get_min_value()

			# Snap to "round" coordinates when holding Ctrl.
			# Be more precise when holding Shift as well.
			var snap_threshold: float
			if event.ctrl_pressed:
				snap_threshold = 0.025 if event.shift_pressed else 0.1
			else:
				snap_threshold = 0.0

			if _selected_tangent == -1: # Drag point
				var point_pos: Vector2 = _to_curve_space(event.position).snapped(Vector2(snap_threshold, snap_threshold * curve_amplitude))

				# The index may change if the point is dragged across another one
				var i: int = _curve.set_point_offset(_selected_point, point_pos.x)
				_hover_point = i
				_selected_point = i

				# This is to prevent the user from losing a point out of view.
				point_pos.y = clamp(point_pos.y, _curve.get_min_value(), _curve.get_max_value())

				_curve.set_point_value(_selected_point, point_pos.y)

			else: # Drag tangent
				var point_pos: Vector2 = _curve.get_point_position(_selected_point)
				var control_pos: Vector2 = _to_curve_space(event.position).snapped(Vector2(snap_threshold, snap_threshold * curve_amplitude))

				var dir: Vector2 = (control_pos - point_pos).normalized()

				var tangent: float
				if not is_zero_approx(dir.x):
					tangent = dir.y / dir.x
				else:
					tangent = 1 if dir.y >= 0 else -1
					tangent *= 9999

				var link: bool = not Input.is_key_pressed(KEY_SHIFT)

				if _selected_tangent == 0:
					_curve.set_point_left_tangent(_selected_point, tangent)

					# Note: if a tangent is set to linear, it shouldn't be linked to the other
					if link and _selected_point != (_curve.get_point_count() - 1) and _curve.get_point_right_mode(_selected_point) != Curve.TANGENT_LINEAR:
						_curve.set_point_right_tangent(_selected_point, tangent)

				else:
					_curve.set_point_right_tangent(_selected_point, tangent)

					if link and _selected_point != 0 and _curve.get_point_left_mode(_selected_point) != Curve.TANGENT_LINEAR:
						_curve.set_point_left_tangent(_selected_point, tangent)

			curve_updated.emit()
			queue_redraw()

		else:
			_hover_point = get_point_at(event.position)


func add_point(pos: Vector2) -> void:
	if not _curve:
		return

	var point_pos = pos
	point_pos.y = clamp(point_pos.y, 0.0, 1.0)

	# Small trick to get the point index to feed the undo method
	var i: int = _curve.add_point(point_pos)
	_curve.remove_point(i)

	var ur = GlobalUndoRedo.get_undo_redo()
	ur.create_action("Add Curve Point")
	ur.add_do_method(add_point.bind(point_pos))
	ur.add_undo_method(_curve.remove_point.bind(i))
	ur.commit_action()
	queue_redraw()

	curve_updated.emit()


func remove_point(idx: int) -> void:
	if not _curve:
		return

	var pos = _curve.get_point_position(idx)
	var lt = _curve.get_point_left_tangent(idx)
	var rt = _curve.get_point_right_tangent(idx)
	var lm = _curve.get_point_left_mode(idx)
	var rm = _curve.get_point_right_mode(idx)

	var ur = GlobalUndoRedo.get_undo_redo()
	ur.create_action("Remove Curve Point")
	ur.add_do_method(_curve.remove_point.bind(idx))
	ur.add_undo_method(_curve.add_point.bind(pos, lt, rt, lm, rm))

	if idx == _selected_point:
		_selected_point = -1

	if idx == _hover_point:
		_hover_point = -1

	ur.commit_action()
	queue_redraw()

	curve_updated.emit()


func get_point_at(pos: Vector2) -> int:
	if not _curve:
		return -1

	for i in _curve.get_point_count():
		var p := _to_view_space(_curve.get_point_position(i))
		if p.distance_squared_to(pos) <= _hover_radius:
			return i

	return -1


func get_tangent_at(pos: Vector2) -> int:
	if not _curve or _selected_point < 0:
		return -1

	if _selected_point != 0:
		var control_pos: Vector2 = _get_tangent_view_pos(_selected_point, 0)
		if control_pos.distance_squared_to(pos) < _hover_radius:
			return 0

	if _selected_point != _curve.get_point_count() - 1:
		var control_pos = _get_tangent_view_pos(_selected_point, 1)
		if control_pos.distance_squared_to(pos) < _hover_radius:
			return 1

	return -1


func _draw() -> void:
	if not _curve:
		return

	var text_height = _font.get_height()
	var min_outer := Vector2(0, size.y)
	var max_outer := Vector2(size.x, 0)
	var min_inner := Vector2(text_height, size.y - text_height)
	var max_inner := Vector2(size.x - text_height, text_height)

	var width: float = max_inner.x - min_inner.x
	var height: float = max_inner.y - min_inner.y

	var curve_min: float = _curve.get_min_value()
	var curve_max: float = _curve.get_max_value()

	# Main area
	draw_line(Vector2(0, max_inner.y), Vector2(max_outer.x, max_inner.y), grid_color)
	draw_line(Vector2(0, min_inner.y), Vector2(max_outer.x, min_inner.y), grid_color)
	draw_line(Vector2(min_inner.x, max_outer.y), Vector2(min_inner.x, min_outer.y), grid_color)
	draw_line(Vector2(max_inner.x, max_outer.y), Vector2(max_inner.x, min_outer.y), grid_color)

	# Grid and scale
	## Vertical lines
	var x_offset = 1.0 / columns
	var margin = 4

	for i in columns + 1:
		var x = width * (i * x_offset) + min_inner.x
		draw_line(Vector2(x, max_outer.y), Vector2(x, min_outer.y), grid_color_sub)

		var pos := Vector2(x + margin, min_outer.y - margin)
		var text := var_to_str(snapped(i * x_offset, 0.01))
		draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, text_color)

	## Horizontal lines
	var y_offset = 1.0 / rows

	for i in rows + 1:
		var y = height * (i * y_offset) + min_inner.y
		draw_line(Vector2(min_outer.x, y), Vector2(max_outer.x, y), grid_color_sub)
		var y_value = i * ((curve_max - curve_min) / rows) + curve_min
		var pos := Vector2(min_inner.x + margin, y - margin)
		var text := var_to_str(snapped(y_value, 0.01))
		draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, text_color)

	# Plot _curve
	var steps = 100
	var offset = 1.0 / steps
	x_offset = width / steps

	var a: float
	var a_y: float
	var b: float
	var b_y: float

	a = _curve.sample_baked(0.0)
	a_y = remap(a, curve_min, curve_max, min_inner.y, max_inner.y)

	for i in steps - 1:
		b = _curve.sample_baked((i + 1) * offset)
		b_y = remap(b, curve_min, curve_max, min_inner.y, max_inner.y)
		draw_line(Vector2(min_inner.x + x_offset * i, a_y), Vector2(min_inner.x + x_offset * (i + 1), b_y), curve_color)
		a_y = b_y

	# Draw points
	for i in _curve.get_point_count():
		var pos: Vector2 = _to_view_space(_curve.get_point_position(i))
		if _selected_point == i:
			draw_circle(pos, point_radius, selected_point_color)
		else:
			draw_circle(pos, point_radius, point_color);

		if _hover_point == i:
			draw_arc(pos, point_radius + 4.0, 0.0, 2 * PI, 12, point_color, 1.0, true)

	# Draw tangents
	if _selected_point >= 0:
		var i: int = _selected_point
		var pos: Vector2 = _to_view_space(_curve.get_point_position(i))

		if i != 0:
			var control_pos: Vector2 = _get_tangent_view_pos(i, 0)
			draw_line(pos, control_pos, point_color)
			draw_rect(Rect2(control_pos, Vector2(1, 1)).grow(2), point_color)

		if i != _curve.get_point_count() - 1:
			var control_pos: Vector2 = _get_tangent_view_pos(i, 1)
			draw_line(pos, control_pos, point_color)
			draw_rect(Rect2(control_pos, Vector2(1, 1)).grow(2), point_color)


func _to_view_space(pos: Vector2) -> Vector2:
	var h = _font.get_height()
	pos.x = remap(pos.x, 0.0, 1.0, h, size.x - h)
	pos.y = remap(pos.y, _curve.get_min_value(), _curve.get_max_value(), size.y - h, h)
	return pos


func _to_curve_space(pos: Vector2) -> Vector2:
	var h = _font.get_height()
	pos.x = remap(pos.x, h, size.x - h, 0.0, 1.0)
	pos.y = remap(pos.y, size.y - h, h, _curve.get_min_value(), _curve.get_max_value())
	return pos


func _get_tangent_view_pos(i: int, tangent: int) -> Vector2:
	var dir: Vector2

	if tangent == 0:
		dir = -Vector2(1.0, _curve.get_point_left_tangent(i))
	else:
		dir = Vector2(1.0, _curve.get_point_right_tangent(i))

	var point_pos = _to_view_space(_curve.get_point_position(i))
	var control_pos = _to_view_space(_curve.get_point_position(i) + dir)

	return point_pos + _tangents_length * (control_pos - point_pos).normalized()


func _on_resized() -> void:
	if dynamic_row_count:
		rows = (int(size.y / custom_minimum_size.y) + 1) * 2
