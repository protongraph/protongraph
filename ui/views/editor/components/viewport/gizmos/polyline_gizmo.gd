class_name Polyline3DGizmo
extends AbstractGizmo


# Display Polyline3D objects in the viewport


var _target: Polyline3D
var _line_mesh: MeshInstance3D
var _material := preload("./materials/m_gizmo_blue.tres")


func enable_for(polyline: Polyline3D) -> void:
	_target = polyline
	_update_mesh()


func disable() -> void:
	_target = null


func _update_mesh() -> void:
	if not _target:
		return

	var points := _target.points
	var count = points.size() - 1
	transform = _target.transform

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)

	for i in count:
		st.add_vertex(points[i])
		st.add_vertex(points[i + 1])

	if not _line_mesh:
		_line_mesh = MeshInstance3D.new()
		_line_mesh.material_override = _material
		add_child(_line_mesh)

	_line_mesh.mesh = st.commit()
