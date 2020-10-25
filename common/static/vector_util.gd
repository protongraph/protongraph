class_name VectorUtil


# TODO : Find someone who understands maths to make this generic
static func project(pos: Vector3, axis: Vector3) -> Vector2:
	var coords: Vector2
	if axis.y > 0:
		coords = Vector2(pos.x, pos.z)
	elif axis.x > 0:
		coords = Vector2(pos.z, pos.y)
	elif axis.z > 0:
		coords = Vector2(pos.x, pos.y)

	return coords
