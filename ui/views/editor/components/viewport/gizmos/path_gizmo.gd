class_name Path3DGizmo
extends AbstractGizmo

# Display Path3D objects in the viewport
# TODO: edit handle support


var editable := false
var use_immediate_geometry := false

var _target: Path3D
var _curve_mesh: MeshInstance3D
var _material := preload("./materials/m_gizmo_blue.tres")
var _handles := []


func _ready() -> void:
	pass


func _process(delta):
	if not visible or not _target:
		return

	if editable:
		_draw_handles()


func enable_for(path: Path3D) -> void:
	_target = path
	_target.curve_changed.connect(_on_curve_changed)
	_update_mesh()


func disable() -> void:
	if is_instance_valid(_target):
		_target.curve_changed.disconnect(_on_curve_changed)
	_target = null


func _update_mesh() -> void:
	if not _target:
		return

	var points = _target.curve.tessellate()
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
		add_child(_curve_mesh)

	_curve_mesh.mesh = st.commit()


func _draw_handles():
	pass


func _on_curve_changed() -> void:
	_update_mesh()
