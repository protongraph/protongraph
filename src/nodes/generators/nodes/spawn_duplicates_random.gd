tool
extends ConceptNode


func _init() -> void:
	unique_id = "duplicate_nodes_random"
	display_name = "Create Duplicates (Random)"
	category = "Generators/Nodes"
	description = "Spawns multiple copies of a random node at the given positions"

	set_input(0, "Sources", ConceptGraphDataType.NODE_3D)
	set_input(1, "Transforms", ConceptGraphDataType.NODE_3D)
	set_input(2, "Seed", ConceptGraphDataType.SCALAR)
	set_output(0, "Duplicates", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var sources := get_input(0)
	var transforms := get_input(1)
	var random_seed: int = get_input_single(2, 0)

	if not sources or sources.size() == 0 or \
		not transforms or transforms.size() == 0:
		return

	var count = sources.size()
	var rng = RandomNumberGenerator.new()
	rng.set_seed(random_seed)

	for t in transforms:
		var i = rng.randi_range(0, count - 1)
		var n = sources[i].duplicate() as Spatial
		n.transform = t.transform
		output[0].append(n)
