tool
extends ConceptNode

"""
Discard all the nodes if their corresponding noise value is above a certain threshold
"""


var _resolution := 0.2 #tmp


func _init() -> void:
	unique_id = "exclude_points_from_noise"
	display_name = "Exclude from noise"
	category = "Nodes/Operations"
	description = "Discard all the points with a corresponding noise value above a given threshold"

	set_input(0, "Nodes", ConceptGraphDataType.NODE)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Threshold", ConceptGraphDataType.SCALAR, {"min": -1.0, "max": 1.0})
	set_input(3, "Invert", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Local space", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func _generate_output(idx: int) -> Array:
	var nodes = get_input(0)
	var noise: OpenSimplexNoise = get_input_single(1)
	var threshold: float = get_input_single(2, 0.0)
	var invert: bool = get_input_single(3, false)
	var local: bool = get_input_single(4, false)
	var result = []

	for node in nodes:
		#var transform = node.transform if local else node.get_global_transform()
		var n = noise.get_noise_3dv(node.transform.origin)
		if invert and n < threshold:
			result.append(node)
		if not invert and n >= threshold:
			result.append(node)

	return result
