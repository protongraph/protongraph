extends Spatial

export var camera_node: NodePath
export var viewport_node: NodePath

var camera
var viewport


func _ready() -> void:
	camera = get_node(camera_node)
	viewport = get_node(viewport_node)


func get_viewport_scale() -> float:
	return 100.0 / viewport.size.y
