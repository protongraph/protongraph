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


func get_output(idx: int) -> OpenSimplexNoise:
	var noise := OpenSimplexNoise.new()
	var input_seed = get_input(0)
	var octaves = get_input(1)
	var period = get_input(2)
	var persistence = get_input(3)
	var lacunarity = get_input(4)

	if input_seed:
		noise.seed = input_seed
	if octaves:
		noise.octaves = octaves
	if period:
		noise.period = period
	if persistence:
		noise.persistence = persistence
	if lacunarity:
		noise.lacunarity = lacunarity

	return noise
