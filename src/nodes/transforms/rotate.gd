tool
class_name ConceptNodeTransformRotate
extends ConceptNode


func _init() -> void:
	set_input(0, "Transforms", ConceptGraphDataType.TRANSFORM)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_output(0, "", ConceptGraphDataType.TRANSFORM)


func get_node_name() -> String:
	return "Rotate"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Applies a random rotation to a set of transforms"


func get_output(idx: int) -> Spatial:
	var transforms = get_input(0)
	var amount = get_input(1)
	var input_seed = get_input(2)

	if not transforms:
		return null
	if not amount:
		amount = Vector3.ONE
	if not input_seed:
		input_seed = 0

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for i in range(transforms.size()):
		var t = transforms[i]
		var origin = t.origin
		t.origin = Vector3.ZERO
		t = t.rotated(Vector3.RIGHT, deg2rad(rand.randf_range(-1.0, 1.0) * amount.x))
		t = t.rotated(Vector3.UP, deg2rad(rand.randf_range(-1.0, 1.0) * amount.y))
		t = t.rotated(Vector3.BACK, deg2rad(rand.randf_range(-1.0, 1.0) * amount.z))
		t.origin = origin
		transforms[i] = t

	return transforms
