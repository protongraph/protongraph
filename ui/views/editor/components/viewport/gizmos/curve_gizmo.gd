extends BaseGizmo
class_name CurveGizmo


var editable := false
var use_immediate_geometry := false

var _target: Path
var _immediate_geometry: ImmediateGeometry
var _static_mesh: MeshInstance
var _material: SpatialMaterial = load("res://ui/views/editor/components/viewport/gizmos/material_blue.tres")
var _handles := []


func _ready() -> void:
	_immediate_geometry = ImmediateGeometry.new()
	_immediate_geometry.material_override = _material
	add_child(_immediate_geometry)


func _process(delta):
	if not visible or not _target:
		return
	
	_draw_curve()
	if editable:
		_draw_handles()


func enable_for(curve: Spatial) -> void:
	_target = curve as Path
	Signals.safe_connect(_target, "curve_changed", self, "_on_curve_changed")
	_update_mesh()


func disable() -> void:
	Signals.safe_disconnect(_target, "curve_changed", self, "_on_curve_changed")
	_target = null


func _draw_curve():
	_static_mesh.visible = not use_immediate_geometry
	if use_immediate_geometry:
		_draw_curve_immediate_mode()


func _draw_curve_immediate_mode():
	var ig = _immediate_geometry
	var points = _target.curve.tessellate()
	var size = points.size() - 1
	transform = _target.transform
	
	ig.clear()
	ig.begin(Mesh.PRIMITIVE_LINES)

	for i in size:
		ig.add_vertex(points[i])
		ig.add_vertex(points[i + 1])

	ig.end()


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
	
	if not _static_mesh:
		_static_mesh = MeshInstance.new()
		_static_mesh.material_override = _material
		add_child(_static_mesh)
	
	_static_mesh.mesh = st.commit()


func _draw_handles():
	pass


func _on_curve_changed() -> void:
	if not use_immediate_geometry:
		_update_mesh()
