tool
extends ConceptNode


func _init() -> void:
	unique_id = "simplex_noise"
	display_name = "Simplex Noise"
	category = "Noise"
	description = "Create an OpenSimplexNoise to be used by other nodes"

	set_input(0, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(1, "Octaves", ConceptGraphDataType.SCALAR, {"step": 1, "value": 3})
	set_input(2, "Period", ConceptGraphDataType.SCALAR, {"value": 64})
	set_input(3, "Persistence", ConceptGraphDataType.SCALAR, {"value": 0.5})
	set_input(4, "Lacunarity", ConceptGraphDataType.SCALAR, {"value": 2})
	set_output(0, "Noise", ConceptGraphDataType.NOISE)


# TODO : Make a super class ConceptGraphNoise with a common api in case we introduce more noise types
func _generate_outputs() -> void:
	var input_seed: int = get_input_single(0, 0)
	var octaves: int = get_input_single(1, 3)
	var period: float = get_input_single(2, 64.0)
	var persistence: float = get_input_single(3, 0.5)
	var lacunarity: float = get_input_single(4, 2.0)

	var noise := OpenSimplexNoise.new()
	noise.seed = input_seed
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity

	output[0] = noise
