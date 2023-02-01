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
	var gizmo: AbstractGizmo

	if node is Path3D:
		gizmo = Path3DGizmo.new()

	elif node is Polyline3D:
		gizmo = Polyline3DGizmo.new()

	else:
		return

	gizmo.enable_for(node)
	add_child(gizmo)

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
