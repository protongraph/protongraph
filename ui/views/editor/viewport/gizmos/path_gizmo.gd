class_name Path3DGizmo
extends AbstractGizmo

# Display Path3D objects in the viewport
# TODO: edit handle support


var use_immediate_geometry := false

var _target: Path3D
var _curve_mesh: MeshInstance3D
var _material := preload("./materials/m_gizmo_blue.tres")


func enable_for(path: Path3D) -> void:
	_target = path
	_target.curve_changed.connect(_update_mesh)
	_update_mesh()


func disable() -> void:
	if is_instance_valid(_target):
		_target.curve_changed.disconnect(_update_mesh)
	_target = null


func _update_mesh() -> void:
	if not _target:
		return

	var curve := _target.curve
	var points = curve.tessellate()
	var size = points.size() - 1
	transform = _target.transform

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)

	for i in size:
		st.add_vertex(points[i])
		st.add_vertex(points[i + 1])

	if not _curve_mesh:
		_curve_mesh = MeshInstance3D.new()
		_curve_mesh.material_override = _material
		_curve_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_curve_mesh)

	_curve_mesh.mesh = st.commit()

	clear_points()
	for i in curve.get_point_count():
		add_point_at(transform * curve.get_point_position(i))
