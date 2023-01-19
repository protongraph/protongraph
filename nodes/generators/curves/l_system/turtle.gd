extends Node
class_name Turtle

# L-System component

var default_angle := 45.0
var step_size := 1.0


var _rng := RandomNumberGenerator.new()
var _states: Array
var _curves: Array
var _path: Path3D
var _turtle: Node3D


class Command:
	var name: String
	var args: Array


func set_seed(custom_seed: int) -> void:
	_rng.set_seed(custom_seed)


func draw(system: String) -> Array:
	clear()

	while system.length() != 0:
		var data = _read(system)
		var cmd = data[0]
		system = data[1]

		var angle: float = _get_parameter(cmd, 0, default_angle)
		var size: float = _get_parameter(cmd, 0, step_size)

		match cmd.name:
			"[": # Push state
				var new_transform = Transform3D(_turtle.transform.basis, _turtle.transform.origin)
				_states.push_back(_turtle.transform)
				_turtle.transform = new_transform

			"]": # Pop state
				if not _states.is_empty():
					_turtle.transform = _states.pop_back()
				_new_path()

			"F": # Forward draw
				_turtle.translate_object_local(Vector3.FORWARD * size)
				_add_point_to_path()

			"f": # Forward no draw
				_turtle.translate_object_local(Vector3.FORWARD * size)

			"H": # Half forward draw
				_turtle.translate_object_local(Vector3.FORWARD * size * 0.5)
				_add_point_to_path()

			"h": # Half forward no draw
				_turtle.translate_object_local(Vector3.FORWARD * size * 0.5)

			"+": # Turn right
				_turtle.rotate_object_local(Vector3.UP, -deg_to_rad(angle))

			"-": # Turn left
				_turtle.rotate_object_local(Vector3.UP, deg_to_rad(angle))

			"|": # Turn 180 degrees
				_turtle.rotate_object_local(Vector3.UP, deg_to_rad(180))

			"&": # Pitch up
				_turtle.rotate_object_local(Vector3.RIGHT, deg_to_rad(angle))

			"^": # Pitch down
				_turtle.rotate_object_local(Vector3.RIGHT, -deg_to_rad(angle))

			"\\": # Roll clockwise
				_turtle.rotate_object_local(Vector3.FORWARD, -deg_to_rad(angle))

			"/": # Roll counter clockwise
				_turtle.rotate_object_local(Vector3.FORWARD, deg_to_rad(angle))

			"*": # Roll 180 degrees
				_turtle.rotate_object_local(Vector3.FORWARD, deg_to_rad(180))

			"~": # Random Pitch, Roll and Turn, default 180
				pass

			"%": # Remove the end of the branch
				pass

	if _path.curve.get_point_count() > 1:
		_curves.push_back(_path)

	return _curves


func clear() -> void:
	_states = []
	_curves = []

	if not is_instance_valid(_turtle):
		_turtle = Node3D.new()
		add_child(_turtle)

	_turtle.transform = Transform3D()
	#_turtle.look_at(Vector3.UP, Vector3.BACK) # TODO: Check later

	_new_path()


func _read(system: String) -> Array:
	var command = Command.new()

	# TODO : Make sure the first character actually belongs to the system alphabet
	command.name = system[0]
	command.args = []
	system = system.right(-1)

	# Check if there's additionnal parameters
	if system.length() > 0 and system[0] == "(":
		system = system.right(-1)
		var tokens = system.split(")")
		var param_tokens = tokens[0].split(",")

		# Each parameters are delimited by "," with a maximum of four for each command
		for i in param_tokens.size():
			var param: String = param_tokens[i]
			if not param.is_valid_float() and not param.is_valid_int():
				continue

			command.args.push_back(param.to_float())

		# Remove the parameters from the string
		var pos = system.find(")")
		system = system.right(-(pos + 1))

	return [command, system]


func _get_parameter(cmd: Command, idx: int, default: float) -> float:
	if cmd.args.size() > idx:
		return cmd.args[idx]

	return default


func _new_path() -> void:
	if _path:
		_curves.push_back(_path)

	_path = Path3D.new()
	_path.curve = Curve3D.new()
	_path.transform = _turtle.transform

	_path.curve.add_point(Vector3.ZERO)


func _add_point_to_path() -> void:
	# var local = _path.transform.xform_inv(_turtle.transform.origin)
	var local = _path.transform * _turtle.transform.origin # TODO: check if right order
	_path.curve.add_point(local)
