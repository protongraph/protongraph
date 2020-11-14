tool
extends ProtonNode

"""
Returns the maximum width, length and height of the curve and the center position averaged from
each points
"""

var _resolution := 0.1 # TMP

func _init() -> void:
	unique_id = "expose_curve_info"
	display_name = "Break Curve"
	category = "Generators/Vectors"
	description = "Exposes the BoundingBox and the Center position of a curve"

	set_input(0, "Curve", DataType.CURVE_3D)
	set_output(0, "Size", DataType.VECTOR3)
	set_output(1, "Center", DataType.VECTOR3)


func _generate_outputs() -> void:
	var paths := get_input(0)
	if not paths or paths.size() == 0:
		return

	var _min: Vector3
	var _max: Vector3

	for i in range(paths.size()):
		var path = paths[i]
		var curve = path.curve
		var length = curve.get_baked_length()
		var steps = round(length / _resolution)

		if steps == 0:
			return

		for j in range(steps):
			# Get a point on the curve
			var coords = path.transform.xform(curve.interpolate_baked((j / (steps-2)) * length))

			# Check for bounds
			if i == 0 and j == 0:
				_min = coords
				_max = coords
			else:
				if coords.x > _max.x:
					_max.x = coords.x
				if coords.x < _min.x:
					_min.x = coords.x
				if coords.y > _max.y:
					_max.y = coords.y
				if coords.y < _min.y:
					_min.y = coords.y
				if coords.z > _max.z:
					_max.z = coords.z
				if coords.z < _min.z:
					_min.z = coords.z

	output[0] = Vector3(_max.x - _min.x, _max.y - _min.y, _max.z - _min.z)
	output[1] = _min + output[0] / 2.0

