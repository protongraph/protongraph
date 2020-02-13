tool
class_name ConceptNodeTransformRotate
extends ConceptNode


func _init() -> void:
	node_title = "Rotate"
	category = "Nodes"
	description = "Applies a random rotation to a set of nodes"

	set_input(0, "Nodes", ConceptGraphDataType.NODE)
	set_input(1, "Amount", ConceptGraphDataType.VECTOR)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_output(0, "", ConceptGraphDataType.NODE)


func get_output(idx: int) -> Spatial:
	var nodes = get_input(0)
	var amount = get_input(1)
	var input_seed = get_input(2)

	if not nodes:
		return null
	if not amount:
		amount = Vector3.ONE
	if not input_seed:
		input_seed = 0

	var rand = RandomNumberGenerator.new()
	rand.seed = input_seed

	for i in range(nodes.size()):
		var rotation = Vector3.ZERO
		rotation.x = deg2rad(rand.randf_range(-1.0, 1.0) * amount.x)
		rotation.y = deg2rad(rand.randf_range(-1.0, 1.0) * amount.y)
		rotation.z = deg2rad(rand.randf_range(-1.0, 1.0) * amount.z)
		nodes[i].rotation = rotation

	return nodes
