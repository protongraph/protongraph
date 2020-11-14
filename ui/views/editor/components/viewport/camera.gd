extends Spatial


export var orbit_speed := 0.5
export var pan_speed := 0.75
export var zoom_speed := 0.5

var _camera: Camera
var _orbit_motion: Vector2
var _pan_motion: Vector2
var _zoom: float
var _viewport: Viewport
var _container: ViewportContainer
var _captured := false
var _captured_from_outside := false
var _margin := 5 # Margin in pixels. Warp the mouse before it actually leaves.


func _ready() -> void:
	_camera = get_node("Camera")
	_viewport = get_parent()
	_container = _viewport.get_parent()


func _process(delta: float) -> void:
	if not _orbit_motion == Vector2.ZERO:
		_orbit_camera(delta)
	if not _pan_motion == Vector2.ZERO:
		_pan_camera(delta)


"""
Handles the zoom, panning and orbiting in the viewport.
"""
func _unhandled_input(event) -> void:
	if not event is InputEventMouse:
		return # Not a mouse event

	var vx = _viewport.size.x
	var vy = _viewport.size.y
	var shift = Input.is_key_pressed(KEY_SHIFT)
	var middle = Input.is_mouse_button_pressed(BUTTON_MIDDLE)

	# If another part of the UI (like the graph node) starts panning and the
	# mouse gets over the viewport, we ignore that
	_captured = middle

	if _captured: # Handle mouse wrapping if the mouse leaves the viewport
		var new_pos: Vector2 = event.position


		if event.position.x < 0 + _margin:
			new_pos.x = vx - _margin

		if event.position.x > vx - _margin:
			new_pos.x = 0 + _margin

		if event.position.y < 0 + _margin:
			new_pos.y = vy - _margin

		if event.position.y > vy - _margin:
			new_pos.y = 0 + _margin

		if new_pos != event.position:
			_viewport.warp_mouse(new_pos + _container.get_global_transform().origin)

	# Handle zoom input when user scrolls up or down
	if event is InputEventMouseButton:
		var dist = _camera.transform.origin.z
		if event.button_index == BUTTON_WHEEL_UP:
			_camera.transform.origin.z -= 0.2 * zoom_speed * dist
			_consume_event()

		if event.button_index == BUTTON_WHEEL_DOWN:
			_camera.transform.origin.z += 0.2 * zoom_speed * dist
			_consume_event()

	# Handle panning and orbiting
	elif event is InputEventMouseMotion:
		# If the mouse cursor was just warped, ignore this event.
		if abs(event.relative.x) > vx - (_margin * 2):
			return
		if abs(event.relative.y) > vy - (_margin * 2):
			return

		if shift and middle:
			_pan_motion = event.relative
			_consume_event()

		elif middle:
			_orbit_motion = event.relative
			_consume_event()


func _consume_event() -> void:
	get_tree().set_input_as_handled()


func reset_camera() -> void:
	transform.origin = Vector3.ZERO
	rotation_degrees = Vector3(-40.0, 45.0, 0.0)
	_camera.transform.origin.z = 3.0


func _pan_camera(delta: float) -> void:
	var zoom_level = _camera.transform.origin.z * 0.25
	translate_object_local(Vector3(-_pan_motion.x, _pan_motion.y, 0.0) * delta * pan_speed * zoom_level)
	_pan_motion = Vector2.ZERO


func _orbit_camera(delta: float) -> void:
	rotation.x += -_orbit_motion.y * delta * orbit_speed
	rotation.y += -_orbit_motion.x * delta * orbit_speed
	_orbit_motion = Vector2.ZERO

	if rotation.x < -PI/2:
		rotation.x = -PI/2
	if rotation.x > PI/2:
		rotation.x = PI/2
