extends BaseGizmo


var _is_dragging := false
var _selected_axis := -1
var _selected_plane := -1
var _selected_node: Spatial
var _click_position
var _initial_position
var _camera

onready var _ax: Area = $Arrows/ArrowX
onready var _ay: Area = $Arrows/ArrowY
onready var _az: Area = $Arrows/ArrowZ
onready var _qx: Area = $Quads/X
onready var _qy: Area = $Quads/Y
onready var _qz: Area = $Quads/Z


func _ready() -> void:
	Signals.safe_connect(_ax, "input_event", self, "_on_input_event", [0])
	Signals.safe_connect(_ay, "input_event", self, "_on_input_event", [1])
	Signals.safe_connect(_az, "input_event", self, "_on_input_event", [2])
	Signals.safe_connect(_qx, "input_event", self, "_on_input_event", [3])
	Signals.safe_connect(_qy, "input_event", self, "_on_input_event", [4])
	Signals.safe_connect(_qz, "input_event", self, "_on_input_event", [5])


func _process(delta: float) -> void:
	if not visible:
		return

	if not _camera:
		_camera = get_parent().camera

	var dist = _camera.global_transform.origin.distance_to(global_transform.origin)
	var viewport_scale = get_parent().get_viewport_scale()
	scale = Vector3.ONE * dist * viewport_scale * gizmo_scale


func enable_for(node: Spatial) -> void:
	_clear_state()
	_selected_node = node
	Signals.safe_connect(node, "input_changed", self, "_on_selected_node_changed")
	transform.origin = node.transform.origin
	visible = true


func disable() -> void:
	_clear_state()
	visible = false


func _clear_state() -> void:
	if _selected_node:
		Signals.safe_disconnect(_selected_node, "input_changed", self, "_on_selected_node_changed")
		_selected_node = null


func _on_input_event(camera: Node, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int, handle_idx: int):
	print("On input event")
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_is_dragging = true
			_camera = camera
			_click_position = click_position
			_initial_position = global_transform.origin
			if handle_idx < 3:
				_selected_axis = handle_idx
			else:
				_selected_plane = handle_idx % 3


func _unhandled_input(event: InputEvent) -> void:
	if not _is_dragging or not is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == false:
			_is_dragging = false
			_selected_axis = -1
			_selected_plane = -1
			# TODO : handle undo redo
			return

	if event is InputEventMouseMotion:
		var point = event.position
		var ray_from = _camera.project_ray_origin(point)
		var ray_dir = _camera.project_ray_normal(point)

		# User dragged an arrow
		if _selected_axis != -1:
			var global_inverse: Transform = transform.affine_inverse()

			var axis: Vector3
			axis[_selected_axis] = 1.0

			var p1 = axis * 4096
			var p2 = -p1
			var g1 = global_inverse.xform(ray_from)
			var g2 = global_inverse.xform(ray_from + ray_dir * 4096)

			var points = Geometry.get_closest_points_between_segments(p1, p2, g1, g2)
			var d = points[0][_selected_axis] - 1.0

			translate_object_local(axis * d)

		# User dragged a quad
		elif _selected_plane != -1:
			var plane = _get_plane(_selected_plane)
			var ray_hit_pos = plane.intersects_ray(ray_from, ray_dir)

			if not ray_hit_pos:
				return

			var ignore_vec = Vector3.ZERO
			ignore_vec[_selected_plane] = 1.0
			ignore_vec = Vector3.ONE - ignore_vec

			global_transform.origin = _initial_position + (ray_hit_pos - _click_position) * ignore_vec

		_selected_node.transform.origin = transform.origin
		emit_signal("gizmo_changed")


func _get_plane(idx: int) -> Plane:
	var o = get_global_transform().origin
	var d
	var n
	match idx:
		0:
			n = Vector3.RIGHT
			d = o.x
		1:
			n = Vector3.UP
			d = o.y
		2:
			n = Vector3.BACK
			d = o.z

	return Plane(n, d)


func _on_selected_node_changed(_node) -> void:
	if not _is_dragging: # Node changed from the graph editor
		transform.origin = _selected_node.transform.origin
