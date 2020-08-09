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
func _unhandled_input(event: InputEvent) -> void:
	if not _is_visible_in_tree():
		return # Another tab is opened

	if not event is InputEventMouse:
		return # Not a mouse event

	var vx = _viewport.size.x
	var vy = _viewport.size.y
	var shift = Input.is_key_pressed(KEY_SHIFT)
	var middle = Input.is_mouse_button_pressed(BUTTON_MIDDLE)

	# If another part of the UI (like the graph node) starts panning and the mouse gets over
	# the viewport, we ignore that
	if not _captured and not _captured_from_outside and middle:
		if _is_in_viewport(event.position):
			_captured = true
		else:
			_captured_from_outside = true

	# If the user release the middle button, that means nothing is currently capturing the mouse
	if not middle:
		_captured = false
		_captured_from_outside = false

	# For when the user moves over the viewport but started pressing the middle button somewhere else
	if _captured_from_outside:
		return

	if _captured: # Handle mouse wrapping if the mouse leaves the viewport
		var new_pos: Vector2 = event.position
		if event.position.x < 0:
			new_pos.x = vx

		if event.position.x > vx:
			new_pos.x = 0

		if event.position.y < 0:
			new_pos.y = vy

		if event.position.y > vy:
			new_pos.y = 0

		if new_pos != event.position:
			_viewport.warp_mouse(new_pos + _container.get_global_transform().origin)

	# Handle zoom input when user scrolls up or down
	if event is InputEventMouseButton and _is_in_viewport(event.position):
		var dist = _camera.transform.origin.z
		if event.button_index == BUTTON_WHEEL_UP:
			_camera.transform.origin.z -= 0.2 * zoom_speed * dist
			_consume_event()

		if event.button_index == BUTTON_WHEEL_DOWN:
			_camera.transform.origin.z += 0.2 * zoom_speed * dist
			_consume_event()

	# Handle panning and orbiting
	elif event is InputEventMouseMotion:
		if abs(event.relative.x) > vx:
			event.relative.x += vx * sign(-event.relative.x)
		if abs(event.relative.y) > vy:
			event.relative.y += vy * sign(-event.relative.y)

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


func _is_in_viewport(vec: Vector2) -> bool:
	return vec.x >= 0 and vec.x < _viewport.size.x and vec.y >= 0 and vec.y < _viewport.size.y


# Custom is_visible_on_tree because the built in one doesn't work if a spatial is parented
# to a viewport or something else that's not a spatial.
func _is_visible_in_tree() -> bool:
	var s = self
	while s:
		var v = s.get("visible")
		if v != null and v == false:
			return false
		s = s.get_parent()

	return true
