"""
Discard all the transforms if their corresponding noise value is above a certain threshold
"""

tool
class_name ConceptNodeExcludeTransformsFromNoise
extends ConceptNode


var _resolution := 0.2 #tmp


func _init() -> void:
	set_input(0, "Transforms", ConceptGraphDataType.TRANSFORM)
	set_input(1, "Noise", ConceptGraphDataType.NOISE)
	set_input(2, "Threshold", ConceptGraphDataType.SCALAR, {"min": -1.0, "max": 1.0})
	set_input(3, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.TRANSFORM)


func get_node_name() -> String:
	return "Exclude from noise"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Discard all the transforms if their corresponding noise value is above a certain threshold"


func get_output(idx: int) -> Array:
	var transforms = get_input(0)
	var noise: OpenSimplexNoise = get_input(1)
	var threshold = get_input(2)
	var invert = get_input(3)
	var result = []

	for transform in transforms:
		var n = noise.get_noise_3dv(transform.origin)
		if invert and n < threshold:
			result.append(transform)
		if not invert and n >= threshold:
			result.append(transform)

	return result
