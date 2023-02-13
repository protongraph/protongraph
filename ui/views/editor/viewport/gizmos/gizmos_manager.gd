class_name GizmosManager
extends Node3D


var _instanced_gizmos := {}
var _selected_node: Node3D


func clear() -> void:
	_instanced_gizmos.clear()
	NodeUtil.remove_children(self)


func set_selected(node: Node3D, _editable := false) -> void:
	_selected_node = node


func add_gizmo_for(node):
	if node is Node3D:
		_add_gizmo(node, AxisGizmo.new())

	if node is Path3D:
		_add_gizmo(node, Path3DGizmo.new())

	elif node is Polyline3D:
		_add_gizmo(node, Polyline3DGizmo.new())


func _add_gizmo(node, gizmo: AbstractGizmo) -> void:
	add_child(gizmo)
	gizmo.enable_for(node)

	if _instanced_gizmos.has(node):
		_instanced_gizmos[node].push_back(gizmo)
	else:
		_instanced_gizmos[node] = [gizmo]


func _on_node_removed(node: Node):
	if _instanced_gizmos.has(node):
		for gizmo in _instanced_gizmos[node]:
			remove_child(gizmo)
			gizmo.disable()
			gizmo.queue_free()
		_instanced_gizmos.erase(node)
