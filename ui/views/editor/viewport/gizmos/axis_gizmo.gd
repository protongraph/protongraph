class_name AxisGizmo
extends AbstractGizmo


# Displays the 3D node transform in the viewport.


var use_immediate_geometry := false

var _target: Node3D
var _axis_mesh: MeshInstance3D
var _material := preload("./materials/m_gizmo_color.tres")


func enable_for(node: Node3D) -> void:
	_target = node
	_update_mesh()


func disable() -> void:
	_target = null


func _update_mesh() -> void:
	if not _target:
		return

	transform = _target.transform

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)

	st.set_color(Color.RED)
	st.add_vertex(Vector3.ZERO)
	st.add_vertex(Vector3.RIGHT)

	st.set_color(Color.GREEN)
	st.add_vertex(Vector3.ZERO)
	st.add_vertex(Vector3.UP)

	st.set_color(Color.BLUE)
	st.add_vertex(Vector3.ZERO)
	st.add_vertex(Vector3.BACK)

	if not _axis_mesh:
		_axis_mesh = MeshInstance3D.new()
		_axis_mesh.material_override = _material
		_axis_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_axis_mesh)

	_axis_mesh.mesh = st.commit()
