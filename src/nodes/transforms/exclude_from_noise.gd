tool
extends ConceptNode

"""
Discard all the nodes if their corresponding noise value is above a certain threshold
"""


var _resolution := 0.2 #tmp


func _init() -> void:
	node_title = "Exclude from noise"
	category = "Nodes"
	description = "Discard all the nodes with a corresponding noise value above a given threshold"

	set_input(0, "Nodes", ConceptGraphDataType.NODE)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Threshold", ConceptGraphDataType.SCALAR, {"min": -1.0, "max": 1.0})
	set_input(3, "Invert", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Local space", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE)


func get_output(idx: int) -> Array:
	var nodes = get_input(0)
	var noise: OpenSimplexNoise = get_input(1)
	var threshold = get_input(2)
	var invert = get_input(3)
	var local = get_input(4)
	var result = []

	for node in nodes:
		#var transform = node.transform if local else node.get_global_transform()
		var n = noise.get_noise_3dv(node.transform.origin)
		if invert and n < threshold:
			result.append(node)
		if not invert and n >= threshold:
			result.append(node)

	return result
