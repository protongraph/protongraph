extends Spatial


export var orbit_speed := 0.5
export var pan_speed := 0.75
export var zoom_speed := 0.5

var _camera: Camera
var _orbit_motion: Vector2
var _pan_motion: Vector2
var _zoom: float


func _ready() -> void:
	_camera = get_node("Camera")


func _process(delta: float) -> void:
	if not _orbit_motion == Vector2.ZERO:
		_orbit_camera(delta)
	if not _pan_motion == Vector2.ZERO:
		_pan_camera(delta)


func on_input(event: InputEvent):
	if event is InputEventMouseButton:
		var dist = _camera.transform.origin.z
		if event.button_index == BUTTON_WHEEL_UP:
			_camera.transform.origin.z -= 0.2 * zoom_speed * dist
		if event.button_index == BUTTON_WHEEL_DOWN:
			_camera.transform.origin.z += 0.2 * zoom_speed * dist

	elif event is InputEventMouseMotion:
		var shift = Input.is_key_pressed(KEY_SHIFT)
		var middle = Input.is_mouse_button_pressed(BUTTON_MIDDLE)

		if shift and middle:
			_pan_motion = event.relative
		elif middle:
			_orbit_motion = event.relative


func reset_camera() -> void:
	transform.origin = Vector3.ZERO
	rotation_degrees = Vector3(-40.0, 45.0, 0.0)


func _pan_camera(delta: float) -> void:
	translate_object_local(Vector3(-_pan_motion.x, _pan_motion.y, 0.0) * delta * pan_speed)
	_pan_motion = Vector2.ZERO


func _orbit_camera(delta: float) -> void:
	rotation.x += -_orbit_motion.y * delta * orbit_speed
	rotation.y += -_orbit_motion.x * delta * orbit_speed
	_orbit_motion = Vector2.ZERO

	if rotation.x < -PI/2:
		rotation.x = -PI/2
	if rotation.x > PI/2:
		rotation.x = PI/2
