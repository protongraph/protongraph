extends Spatial

export var camera_node: NodePath
export var viewport_node: NodePath
export var input_root: NodePath
export var output_root: NodePath

var camera
var viewport

var _input_root: Spatial
var _move_gizmo: Spatial
var _selected_node: Spatial

var _instanced_gizmos := {}


func _ready() -> void:
	camera = get_node(camera_node)
	viewport = get_node(viewport_node)
	_input_root = get_node(input_root)
	_move_gizmo = get_node("MoveGizmo")


func get_viewport_scale() -> float:
	return 100.0 / viewport.size.y


func _on_node_selected(node: Spatial) -> void:
	if node and node.get_parent() == _input_root:
		_move_gizmo.enable_for(node)
	else:
		_move_gizmo.disable()


func _on_node_added(node: Node):
	if node is Path:
		var gizmo = CurveGizmo.new()
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
