extends BaseGizmo
class_name CurveGizmo


var editable := false

var _target: Path
var _geometry: ImmediateGeometry


func _ready() -> void:
	_geometry = ImmediateGeometry.new()
	_geometry.material_override = load("res://views/editor/viewport/gizmos/material_blue.tres")
	add_child(_geometry)


func _process(delta):
	if not visible or not _target:
		return
	
	_draw_curve()
	if editable:
		_draw_handles()


func enable_for(curve: Spatial) -> void:
	_target = curve as Path


func disable() -> void:
	pass
	

func _draw_curve():
	var ig = _geometry
	var points = _target.curve.tessellate()
	var size = points.size() - 1
	transform = _target.transform
	
	ig.clear()
	ig.begin(Mesh.PRIMITIVE_LINES)

	for i in size:
		ig.add_vertex(points[i])
		ig.add_vertex(points[i + 1])

	ig.end()


func _draw_handles():
	pass
