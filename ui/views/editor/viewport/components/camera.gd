class_name ViewportCamera
extends Node3D


@export var orbit_speed := 0.5
@export var pan_speed := 0.75
@export var zoom_speed := 0.5

var _camera: Camera3D
var _orbit_motion: Vector2
var _pan_motion: Vector2
var _viewport: Viewport
var _container: SubViewportContainer
var _captured := false


func _ready() -> void:
	_viewport = get_parent()
	_container = _viewport.get_parent()
	_camera = Camera3D.new()
	add_child(_camera)
	reset_camera()


func _process(delta: float) -> void:
	if not _orbit_motion == Vector2.ZERO:
		_orbit_camera(delta)

	if not _pan_motion == Vector2.ZERO:
		_pan_camera(delta)


# Handles the zoom, panning and orbiting in the viewport.
func process_input(event) -> void:
	if not event is InputEventMouse:
		return # Not a mouse event

	var shift = Input.is_key_pressed(KEY_SHIFT)
	_captured = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)

	# Handle zoom input when user scrolls up or down
	if event is InputEventMouseButton:
		var dist = _camera.transform.origin.z
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera.transform.origin.z -= 0.2 * zoom_speed * dist

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera.transform.origin.z += 0.2 * zoom_speed * dist

	# Handle panning and orbiting
	elif event is InputEventMouseMotion:
		if _captured and shift:
			_pan_motion = event.relative

		elif _captured:
			_orbit_motion = event.relative


func reset_camera() -> void:
	position = Vector3.ZERO
	rotation_degrees = Vector3(-40.0, 45.0, 0.0)
	_camera.position = Vector3(0.0, 0.0, 3.0)


func is_input_captured() -> bool:
	return _captured


func _pan_camera(delta: float) -> void:
	var zoom_level = _camera.transform.origin.z * 0.25
	translate_object_local(Vector3(-_pan_motion.x, _pan_motion.y, 0.0) * delta * pan_speed * zoom_level)
	_pan_motion = Vector2.ZERO


func _orbit_camera(delta: float) -> void:
	rotation.x += -_orbit_motion.y * delta * orbit_speed
	rotation.x = clamp(rotation.x, -PI / 2.0, PI / 2.0)
	rotation.y += -_orbit_motion.x * delta * orbit_speed
	_orbit_motion = Vector2.ZERO
