extends EditorSpatialGizmoPlugin


var editor_plugin: EditorPlugin
var _previous_size


func _init():
	create_material("lines", Color(1, 1, 1))
	create_material("box", Color(1.0, 1.0, 1.0, 0.1))
	create_handle_material("handles")


func get_name() -> String:
	return "ConceptBoxInput"


func has_gizmo(node):
	return node is ConceptBoxInput


func get_handle_name(gizmo: EditorSpatialGizmo, index: int) -> String:
	return "Handle " + String(index)


func get_handle_value(gizmo: EditorSpatialGizmo, index: int):
	var box = gizmo.get_spatial_node()
	return box.size


"""
Automatically called when a handle is moved around.
"""
func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, point: Vector2) -> void:
	var box: ConceptBoxInput = gizmo.get_spatial_node()

	if not _previous_size:
		_previous_size = box.size

	var global_transform: Transform = box.get_global_transform()
	var global_inverse: Transform = global_transform.affine_inverse()

	var ray_from = camera.project_ray_origin(point)
	var ray_dir = camera.project_ray_normal(point)

	if index < 6:
		# Face handle
		var i := index % 3
		var axis: Vector3
		axis[i] = 1.0

		var p1 = axis * 4096
		var p2 = -p1
		var g1 = global_inverse.xform(ray_from)
		var g2 = global_inverse.xform(ray_from + ray_dir * 4096)

		var points = Geometry.get_closest_points_between_segments(p1, p2, g1, g2)
		var d = points[0][i]

		# TODO : Add snap support (when holding ctrl)
		# TODO : Add symetric edition (when holding shift)
		if index > 2:
			d *= -1.0

		box.size[i] = d + (_previous_size[i] / 2.0)
		box.center[i] = (box.size[i] * 0.5) - d
		if index < 3:
			box.center[i] *= -1.0

		redraw(gizmo)

	else:
		# Corner handle
		print("Not implemented yet")

	box.property_list_changed_notify()


"""
Handle Undo / Redo after a handle was moved. Manually called from EditorSpatialGizmo.
"""
func commit_handle(gizmo: EditorSpatialGizmo, index: int, restore, cancel: bool = false) -> void:
	var box = gizmo.get_spatial_node()

	var ur = editor_plugin.get_undo_redo()
	ur.create_action("Resize Box Input")
	ur.add_do_property(box, "center", Vector3.ZERO)
	ur.add_do_property(box, "size", box.size)
	ur.add_do_method(box, "translate", box.center)

	ur.add_undo_property(box, "size", restore)
	ur.add_undo_method(box, "translate", -box.center)
	ur.add_undo_method(box, "property_list_changed_notify")	# TMP hack, find why the inspector does not refresh automatically on undo
	ur.commit_action()

	_previous_size = null
	redraw(gizmo)


func redraw(gizmo: EditorSpatialGizmo):
	gizmo.clear()

	var box := gizmo.get_spatial_node() as ConceptBoxInput

	# TMP: force the gizmo to redraw everytime we change a parameter. This should probably
	# happen automatically but for some reason, it doesn't
	if not box.is_connected("property_changed", self, "redraw"):
		box.connect("property_changed", self, "redraw", [gizmo])

	var lines := _get_box_lines(box)
	var handles := _get_box_handles(box)

	gizmo.add_handles(handles, get_material("handles", gizmo))
	gizmo.add_lines(lines, get_material("lines", gizmo))
	gizmo.add_collision_segments(lines)


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
	var handles := PoolVector3Array()
	var hs := box.size / 2.0

	# Ordered on purpose so their (index % 3) matches the associated Vector3 axis
	handles.append(Vector3(hs.x, 0.0, 0.0) + box.center)
	handles.append(Vector3(0.0, hs.y, 0.0) + box.center)
	handles.append(Vector3(0.0, 0.0, hs.z) + box.center)
	handles.append(Vector3(-hs.x, 0.0, 0.0) + box.center)
	handles.append(Vector3(0.0, -hs.y, 0.0) + box.center)
	handles.append(Vector3(0.0, 0.0, -hs.z) + box.center)

	# Append _get_box_corners(box) there once we figure out the math to move corners
	return handles


"""
Calculate the position of each corners of the box.
"""
func _get_box_corners(box: ConceptBoxInput) -> PoolVector3Array:
	var corners = PoolVector3Array()
	var hs := box.size / 2.0

	var left := -hs.x
	var right := hs.x
	var top := hs.y
	var bottom := -hs.y
	var front := hs.z
	var back := - hs.z

	corners.append(Vector3(left, top, front) + box.center)
	corners.append(Vector3(right, top, front) + box.center)
	corners.append(Vector3(right, bottom, front) + box.center)
	corners.append(Vector3(left, bottom, front) + box.center)
	corners.append(Vector3(left, bottom, back) + box.center)
	corners.append(Vector3(left, top, back) + box.center)
	corners.append(Vector3(right, top, back) + box.center)
	corners.append(Vector3(right, bottom, back) + box.center)

	return corners
