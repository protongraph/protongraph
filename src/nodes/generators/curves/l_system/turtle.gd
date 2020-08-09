extends Node
class_name Turtle


var angle := 45.0
var step_size := 1.0


var _rng := RandomNumberGenerator.new()
var _states: Array
var _curves: Array
var _path: Path
var _turtle: Spatial


class Command:
	var name: String
	var param_a: float


func set_seed(custom_seed: int) -> void:
	_rng.set_seed(custom_seed)


func draw(system: String) -> Array:
	clear()
	
	while system.length() != 0:
		var data = _read(system)
		var cmd = data[0]
		system = data[1]
		
		match cmd.name:
			"[": # Push state
				var new_transform = Transform(_turtle.transform.basis, _turtle.transform.origin)
				_states.push_back(_turtle.transform)
				_turtle.transform = new_transform
	
			"]": # Pop state
				_turtle.transform = _states.pop_back()
				_new_path()
			
			"F": # Forward draw
				_turtle.translate_object_local(Vector3.FORWARD * step_size)
				_add_point_to_path()
			
			"+": # Turn right
				_turtle.rotate_object_local(Vector3.UP, deg2rad(angle))

			"-": # Turn left
				_turtle.rotate_object_local(Vector3.UP, -deg2rad(angle))
	
			"&": # Pitch up
				_turtle.rotate_object_local(Vector3.RIGHT, deg2rad(angle))
				
			"^": # Pitch down
				_turtle.rotate_object_local(Vector3.RIGHT, -deg2rad(angle))
				
			"\\": # Roll clockwise
				_turtle.rotate_object_local(Vector3.FORWARD, deg2rad(angle))
				
			"/": # Roll counter clockwise
				_turtle.rotate_object_local(Vector3.FORWARD, -deg2rad(angle))
	
	if _path.curve.get_point_count() > 1:
		_curves.append(_path)
	
	return _curves


func clear() -> void:
	_states = []
	_curves = []
	_turtle = Spatial.new()
	add_child(_turtle)
	_turtle.look_at(Vector3.UP, Vector3.BACK)
	_new_path()


func _read(system: String) -> Array:
	var command = Command.new()
	command.name = system[0]

	system = system.right(1)

	return [command, system]


func _new_path() -> void:
	if _path:
		_curves.push_back(_path)
	
	_path = Path.new()
	_path.curve = Curve3D.new()
	_path.transform = _turtle.transform
	
	_path.curve.add_point(Vector3.ZERO)


func _add_point_to_path() -> void:
	var local = _path.transform.xform_inv(_turtle.transform.origin)
	_path.curve.add_point(local)
