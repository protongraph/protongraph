extends ProtonNode

"""
Discard all the nodes if their corresponding noise value is above a certain threshold
"""


var _resolution := 0.2 #tmp


func _init() -> void:
	unique_id = "exclude_points_from_noise"
	display_name = "Exclude From Noise"
	category = "Modifiers/Nodes"
	description = "Discard all the points with a corresponding noise value above a given threshold"

	set_input(0, "Nodes", DataType.NODE_3D)
	set_input(1, "Noise", DataType.NOISE)
	set_input(2, "Threshold", DataType.SCALAR, {"min": -1.0, "max": 1.0})
	set_input(3, "Invert", DataType.BOOLEAN)
	set_input(4, "Local space", DataType.BOOLEAN)
	set_output(0, "", DataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var noise: Noise = get_input_single(1)
	var threshold: float = get_input_single(2, 0.0)
	var invert: bool = get_input_single(3, false)
	var local: bool = get_input_single(4, false)

	for node in nodes:
		var n = noise.get_noise_3dv(node.transform.origin)
		if invert and n < threshold:
			output[0].push_back(node)
		elif not invert and n >= threshold:
			output[0].push_back(node)
