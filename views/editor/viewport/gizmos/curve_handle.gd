extends Spatial


var _move_gizmo: Spatial
var _sphere: Spatial
var _selected := false


func _ready():
	_sphere = get_node("Sphere")
	_move_gizmo = get_node("MoveGizmo")
	_move_gizmo.enable_for(_sphere)
	_move_gizmo.visible = false
