tool
extends ConceptNode

"""
Generates a curve following a random path above physical geometry
"""

var _rng: RandomNumberGenerator
var _space: PhysicsDirectSpaceState
var _reference: Transform

func _init() -> void:
	unique_id = "curve_generator_ivy_1"
	display_name = "Grow ivy curve"
	category = "Generators/Curves/3D"
	description = "Generates a curve following a random path above physical geometry"

	var opts = {"value": 1.0, "min": 0, "allow_lesser": false}
	set_input(0, "Starting point", ConceptGraphDataType.VECTOR3)
	set_input(1, "Branches", ConceptGraphDataType.SCALAR, {"step": 1, "min": 1, "value": 1})
	set_input(2, "Length", ConceptGraphDataType.SCALAR, opts)
	set_input(3, "Step length", ConceptGraphDataType.SCALAR, opts)
	set_input(4, "Angle max", ConceptGraphDataType.SCALAR)
	set_input(5, "Seed", ConceptGraphDataType.SCALAR, {"step": 1, "value": 0})
	#opts["step"] = 1

	#set_input(5, "Recursion", ConceptGraphDataType.SCALAR, opts)
	#set_input(6, "Attenuation %", ConceptGraphDataType.SCALAR,
	#	{"min": 0, "max": 100, "allow_lesser": false, "allow_higher": false, "value": 50})

	set_output(0, "", ConceptGraphDataType.CURVE_3D)


func _generate_outputs() -> void:
	var start_pos: Vector3 = get_input_single(0, Vector3.ZERO)
	var branches: int = get_input_single(1, 1)
	var dist: float = get_input_single(2, 1.0)
	var step_length: float = get_input_single(3, 1.0)
	var angle_max: float = get_input_single(4, 10)
	var custom_seed: int = get_input_single(5, 0)
	#var recursion_level = get_input_single(4, 0) + 1
	#var attenuation = get_input_single(5, 50)

	_rng = RandomNumberGenerator.new()
	_rng.set_seed(custom_seed)
	_reference = get_concept_graph().transform
	_space = get_concept_graph().get_world().direct_space_state

	for i in range(branches):	# How many branches start from the origin
		var path = Path.new()
		path.translation = start_pos

		var curve = Curve3D.new()
		curve.add_point(Vector3.ZERO)

		var steps = round(dist / step_length)
		var previous_pos = null
		var current_pos = start_pos

		for j in range(steps):
			var pos = _get_next_pos(previous_pos, current_pos, step_length, angle_max)
			previous_pos = current_pos
			current_pos = pos
			curve.add_point(pos - start_pos)

		path.curve = curve
		output[0].append(path)


func _get_next_pos(prev, start: Vector3, length: float, angle_max: float) -> Vector3:
	var gravity = 0.75
	var pos := start + _random_vector(gravity) * length
	var max_retry := 1000
	var retry := 0
	var valid = false

	while not valid:
		while not _is_aligned(prev, start, pos, angle_max):
			pos = start + _random_vector(gravity / (retry + 1)) * length
			retry += 1

		var hit = _space.intersect_ray(_reference.xform(start), _reference.xform(pos))
		if hit.size() > 0:
			var to_hit = _reference.xform_inv(hit.position)# - start
			print("Hit found at ", hit.position)
			print("Local : ", to_hit)
			return _reference.xform_inv(hit.position)

			if to_hit.length_squared() >= ((prev - start).length_squared() * 0.5):
				pos = to_hit + start
				valid = true
		else:
			return pos

	return pos


func _random_vector(gravity: float) -> Vector3:
	var v = Vector3.ZERO
	v.x = _rng.randf_range(-1.0, 1.0)
	v.y = _rng.randf_range(-1.0, 1.0) - gravity
	v.z = _rng.randf_range(-1.0, 1.0)
	return v.normalized()


func _is_aligned(prev, start: Vector3, pos: Vector3, angle_max: float):
	if prev == null:
		return true

	var a = prev - start
	var b = pos - start
	var angle = rad2deg(a.angle_to(b))
	return (180 - angle) <= (angle_max * 0.5)

