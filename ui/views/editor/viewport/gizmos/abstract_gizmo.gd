class_name AbstractGizmo
extends Node3D

signal gizmo_changed


@export var gizmo_scale := 1.0

var editable := false

var _point_mesh: PointMesh
var _points: Array[RID] = []


func enable_for(_node) -> void:
	pass


func disable() -> void:
	pass


# Draw points using the rendering server directly. Useful when the number of
# points can quickly go up and there's no need for a full node based setup.
func add_point_at(pos: Vector3) -> void:
	if not _point_mesh:
		_point_mesh = PointMesh.new()
		_point_mesh.material = preload("./materials/m_gizmo_point.tres")

	var instance = RenderingServer.instance_create()
	var scenario = get_tree().get_root().get_world_3d().scenario
	RenderingServer.instance_set_scenario(instance, scenario)
	RenderingServer.instance_set_base(instance, _point_mesh)
	var t = Transform3D(Basis(), pos)
	RenderingServer.instance_set_transform(instance, t)
	RenderingServer.instance_geometry_set_cast_shadows_setting(instance, RenderingServer.SHADOW_CASTING_SETTING_OFF)
	_points.push_back(instance)


func clear_points() -> void:
	for rid in _points:
		RenderingServer.free_rid(rid)
