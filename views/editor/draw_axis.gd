extends Viewport


var _x_axis: MeshInstance
var _y_axis: MeshInstance
var _z_axis: MeshInstance
var _length = 10000


func _ready() -> void:
	_x_axis = _create_axis(Color.red)
	_y_axis = _create_axis(Color.green)
	_z_axis = _create_axis(Color.blue)

	_y_axis.rotate_z(PI / 2.0)
	_z_axis.rotate_y(PI / 2.0)


func _input(event) -> void:
	# Treat input events as unhandled input, otherwise _unhandled_input will never be called on
	# objects in this viewport. Since object picking is handled in the unhandled_input by the engine
	# this allows the runtime 3D gizmos to work.
	unhandled_input(event)


func _create_axis(color: Color) -> MeshInstance:
	var surface_tool := SurfaceTool.new()
	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_LINES);

	surface_tool.add_vertex(Vector3(-_length / 2.0, 0, 0))
	surface_tool.add_vertex(Vector3(_length / 2.0, 0, 0))

	var mi = MeshInstance.new()
	mi.mesh = surface_tool.commit()

	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.albedo_color = color

	mi.material_override = mat

	add_child(mi)

	return mi
