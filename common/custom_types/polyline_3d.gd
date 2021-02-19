extends Spatial
class_name Polyline


export var points: Array


# Take the points array (Vector3) and project it to a plane defined by the
# normal axis. Returns an array of Vector2.
func to_pool_vector_2(axis: Vector3, global = true) -> Array:
	# TODO : Ask the god of Maths to fix this whole mess
	axis = axis.normalized()
	var t_axis = Transform()
	var up = Vector3.UP

	if axis == Vector3.UP or axis == Vector3.DOWN:
		up = Vector3.BACK

	if axis != Vector3.ZERO:
		t_axis = t_axis.looking_at(axis, up)

	# T2 is the same transform but without translation so the projection rotation is right
	# when using it in extrude straight but eeeeh this should be more generic and optional I guess
	# That's a problem for later
	var t2 = transform
	t2.origin = Vector3.ZERO
	var res = []
	for v in points:
		if global:
			v = t2.xform(v)

		v = t_axis.xform_inv(v)
		res.push_back(Vector2(v.x, v.y))
	return res


func add_point(position: Vector3, index: int) -> void:
	points.insert(index, position)


func get_point_count() -> int:
	return points.size()
