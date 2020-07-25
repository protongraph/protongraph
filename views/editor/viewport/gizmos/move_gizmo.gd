extends Spatial


signal gizmo_changed


export var gizmo_scale := 1.0

export var arrow_x: NodePath
export var arrow_y: NodePath
export var arrow_z: NodePath
export var quad_x: NodePath
export var quad_y: NodePath
export var quad_z: NodePath


var _ax: Area
var _ay: Area
var _az: Area
var _qx: Area
var _qy: Area
var _qz: Area

var _is_dragging := false
var _selected_axis := -1
var _selected_node: Spatial
var _camera


func _ready() -> void:
	_ax = get_node(arrow_x)
	_ay = get_node(arrow_y)
	_az = get_node(arrow_z)

	_ax.connect("input_event", self, "_on_input_event", [0])
	_ay.connect("input_event", self, "_on_input_event", [1])
	_az.connect("input_event", self, "_on_input_event", [2])


func _process(delta: float) -> void:
	if not visible:
		return

	if not _camera:
		_camera = get_parent().camera

	var dist = _camera.global_transform.origin.distance_to(global_transform.origin)
	var viewport_scale = get_parent().get_viewport_scale()
	scale = Vector3.ONE * dist * viewport_scale * gizmo_scale


func activate(node: Spatial) -> void:
	_clear_state()
	_selected_node = node
	Signals.safe_connect(node, "input_changed", self, "_on_selected_node_changed")
	transform.origin = node.transform.origin
	visible = true


func deactivate() -> void:
	_clear_state()
	visible = false


func _clear_state() -> void:
	if _selected_node:
		Signals.safe_disconnect(_selected_node, "input_changed", self, "_on_selected_node_changed")
		_selected_node = null


func _on_input_event(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int, axis_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_is_dragging = true
			_selected_axis = axis_idx
			_camera = camera


func _unhandled_input(event: InputEvent) -> void:
	if not _is_dragging or not is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == false:
			_is_dragging = false
			_selected_axis = -1
			# TODO : handle undo redo
			return

	if event is InputEventMouseMotion:
		var global_inverse: Transform = transform.affine_inverse()
		var point = event.position

		var ray_from = _camera.project_ray_origin(point)
		var ray_dir = _camera.project_ray_normal(point)


		var axis: Vector3
		axis[_selected_axis] = 1.0

		var p1 = axis * 4096
		var p2 = -p1
		var g1 = global_inverse.xform(ray_from)
		var g2 = global_inverse.xform(ray_from + ray_dir * 4096)

		var points = Geometry.get_closest_points_between_segments(p1, p2, g1, g2)
		var d = points[0][_selected_axis] - 1.0

		translate_object_local(axis * d)
		_selected_node.transform.origin = transform.origin
		emit_signal("gizmo_changed")


func _on_selected_node_changed(_node) -> void:
	if not _is_dragging: # Node changed from the graph editor
		transform.origin = _selected_node.transform.origin
