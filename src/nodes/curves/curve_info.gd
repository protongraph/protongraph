"""
Returns the maximum width, length and height of the curve and the center position averaged from
each points
"""

tool
extends ConceptNode


var _resolution := 0.1 # TMP
var _size: Vector3
var _center: Vector3
var _calculated = false


func _init() -> void:
	unique_id = "expose_curve_info"
	display_name = "Curve Info"
	category = "Curves"
	description = "Exposes the BoundingBox and the Center position of a curve"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_output(0, "Size", ConceptGraphDataType.VECTOR)
	set_output(1, "Center", ConceptGraphDataType.VECTOR)


func _generate_output(idx: int) -> Vector3:
	var paths = get_input(0)
	if not paths or paths.size() == 0:
		return Vector3.ZERO

	if not _calculated:
		_calculate_info(paths)

	match idx:
		0:
			return _size
		1:
			return _center

	return Vector3.ZERO


func _calculate_info(paths: Array) -> void:
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
			var coords = curve.interpolate_baked((j / (steps-2)) * length) + path.translation

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

	_size = Vector3(_max.x - _min.x, _max.y - _min.y, _max.z - _min.z)
	_center = Vector3((_min.x + _max.x) / 2, (_min.y + _max.y) / 2, (_min.z + _max.z) / 2)


func _clear_cache() -> void:
	_calculated = false
