class_name VectorUtil
extends Node


static func is_vector(a: Variant) -> bool:
	return _get_count(a) > 0


static func min_f(vec, val: float):
	for i in _get_count(vec):
		vec[i] = min(vec[i], val)
	return vec


static func min_v(vec, val):
	if not _check_validity(vec, val):
		return

	for i in _get_count(vec):
		vec[i] = min(vec[i], val[i])
	return vec


static func max_f(vec, val: float):
	for i in _get_count(vec):
		vec[i] = max(vec[i], val)
	return vec


static func max_v(vec, val):
	if not _check_validity(vec, val):
		return

	for i in _get_count(vec):
		vec[i] = max(vec[i], val[i])
	return vec


static func clamp_f(vec, min_val: float, max_val: float):
	for i in _get_count(vec):
		vec[i] = clamp(vec[i], min_val, max_val)
	return vec


static func clamp_v(vec, min_val, max_val):
	if not _check_validity(vec, min_val) or not _check_validity(vec, max_val):
		return

	for i in _get_count(vec):
		vec[i] = clamp(vec[i], min_val[i], max_val[i])
	return vec


static func _get_count(vec) -> int:
	match typeof(vec):
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return 2

		TYPE_VECTOR3, TYPE_VECTOR3I:
			return 3

		TYPE_VECTOR4, TYPE_VECTOR4I:
			return 4

	return 0


static func _check_validity(v1, v2) -> bool:
	if typeof(v1) != typeof(v2):
		print_debug("Warning: Incompatible vector types")
		return false

	return true
