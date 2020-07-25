extends Spatial


export var arrow_x: NodePath
export var arrow_y: NodePath
export var arrow_z: NodePath
export var quad_x: NodePath
export var quad_y: NodePath
export var quad_z: NodePath

var _ax: Area
var _ay: Area
var _az: Area
var _qx: Area
var _qy: Area
var _qz: Area


func _ready() -> void:
	_ax = get_node(arrow_x)
	_ay = get_node(arrow_y)
	_az = get_node(arrow_z)

	_ax.connect("input_event", self, "_on_input_event", [0])
	_ay.connect("input_event", self, "_on_input_event", [1])
	_az.connect("input_event", self, "_on_input_event", [2])


func _on_input_event(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int, axis: int):
	print("On axis ", axis)
	print(event)
	print(click_position)
	print("\n")
