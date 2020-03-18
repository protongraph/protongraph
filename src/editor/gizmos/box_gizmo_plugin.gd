extends EditorSpatialGizmoPlugin


func _init():
	create_material("lines", Color(1, 1, 1), false, true)
	create_handle_material("handles")


func has_gizmo(node):
	return node is ConceptBoxInput


func redraw(gizmo):
	gizmo.clear()

	var box := gizmo.get_spatial_node() as ConceptBoxInput
	var lines := _get_box_lines(box)
	var handles := _get_box_handles(box)

	gizmo.add_lines(lines, get_material("lines", gizmo), false)
	gizmo.add_handles(handles, get_material("handles", gizmo))


"""
Returns all the points that make up the box lines.
"""
func _get_box_lines(box: ConceptBoxInput) -> PoolVector3Array:
	var lines = PoolVector3Array()
	var c = _get_box_corners(box)

	lines.push_back(c[0])
	lines.push_back(c[1])
	lines.push_back(c[1])
	lines.push_back(c[2])
	lines.push_back(c[2])
	lines.push_back(c[3])
	lines.push_back(c[3])
	lines.push_back(c[0])
	lines.push_back(c[0])
	lines.push_back(c[5])
	lines.push_back(c[1])
	lines.push_back(c[6])
	lines.push_back(c[2])
	lines.push_back(c[7])
	lines.push_back(c[3])
	lines.push_back(c[4])
	lines.push_back(c[4])
	lines.push_back(c[5])
	lines.push_back(c[5])
	lines.push_back(c[6])
	lines.push_back(c[6])
	lines.push_back(c[7])
	lines.push_back(c[7])
	lines.push_back(c[4])

	return lines


"""
Returns the position of each handles. One on each corner, one at the center of each faces.
"""
func _get_box_handles(box: ConceptBoxInput) -> PoolVector3Array:
	var handles := _get_box_corners(box)

	var c: Vector3 = box.get_global_transform().origin
	var hs := box.size / 2.0

	handles.append(Vector3(0.0, 0.0, c.z + hs.z))
	handles.append(Vector3(c.x + hs.x, 0.0, 0.0))
	handles.append(Vector3(0.0, 0.0, c.z - hs.z))
	handles.append(Vector3(c.x - hs.x, 0.0, 0.0))
	handles.append(Vector3(0.0, c.y + hs.y, 0.0))
	handles.append(Vector3(0.0, c.y - hs.y, 0.0))

	return handles


"""
Calculate the position of each corners of the box.
"""
func _get_box_corners(box: ConceptBoxInput) -> PoolVector3Array:
	var corners = PoolVector3Array()

	var c: Vector3 = box.get_global_transform().origin
	var hs := box.size / 2.0

	var left := c.x - hs.x
	var right := c.x + hs.x
	var top := c.y + hs.y
	var bottom := c.y - hs.y
	var front := c.z + hs.z
	var back := c.z - hs.z

	corners.append(Vector3(left, top, front))
	corners.append(Vector3(right, top, front))
	corners.append(Vector3(right, bottom, front))
	corners.append(Vector3(left, bottom, front))
	corners.append(Vector3(left, bottom, back))
	corners.append(Vector3(left, top, back))
	corners.append(Vector3(right, top, back))
	corners.append(Vector3(right, bottom, back))

	return corners
