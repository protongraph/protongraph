class_name NodeSerializer
extends Node

# Helper to serialize and deserialize node trees to json objects.


# Takes a single node and serialize its contents and its children's content
# into a dictionary
static func serialize(root: Node) -> Dictionary:
	var res := {}
	if not root:
		return res

	res["name"] = root.name

	if root is MeshInstance:
		res["type"] = "mesh"
		res["data"] = _serialize_mesh_instance(root)
	elif root is MultiMeshInstance:
		res["type"] = "multi_mesh"
		res["data"] = _serialize_multi_mesh(root)
	elif root is Path:
		res["type"] = "curve_3d"
		res["data"] = _serialize_curve_3d(root)
	elif root is Spatial or root is Position3D:
		res["type"] = "node_3d"
		res["data"] = _serialize_node_3d(root)

	if root.get_child_count() > 0:
		res["children"] = []
		for child in root.get_children():
			res["children"].append(serialize(child))

	return res


# Takes a dictionnary and recreates the Godot node tree from there. This is
# the inverse of serialize.
static func deserialize(data: Dictionary) -> Node:
	var res
	match data["type"]:
		"node_3d":
			res = _deserialize_node_3d(data["data"])
		"mesh":
			res = _deserialize_mesh_instance(data["data"])
		"multi_mesh":
			res = _deserialize_multi_mesh(data["data"])
		"curve":
			res = _deserialize_curve_3d(data["data"])
		_:
			print("Type ", data["type"], " is not supported")
			return null

	if data.has("children"):
		for child in data["children"]:
			res.add_child(deserialize(child))

	if "name" in data:
		res.name = data["name"]

	return res


static func serialize_all(nodes: Array) -> Array:
	var res = []
	for node in nodes:
		res.push_back(serialize(node))
	return res


static func deserialize_all(nodes: Array) -> Array:
	var res = []
	for node in nodes:
		res.push_back(deserialize(node))
	return res


# -- Transform --

static func _serialize_transform(t: Transform) -> Dictionary:
	var data := {}
	var origin = t.origin
	var basis = t.basis

	data["pos"] = _vector_to_array(origin)
	data["basis"] = [
		_vector_to_array(basis.x),
		_vector_to_array(basis.y),
		_vector_to_array(basis.z)
	]
	return data


static func _deserialize_transform(data: Dictionary) -> Transform:
	var t = Transform()
	if "pos" in data:
		t.origin = _extract_vector(data["pos"])

	if "basis" in data:
		var basis: Array = data["basis"]
		t.basis.x = _extract_vector(basis[0])
		t.basis.y = _extract_vector(basis[1])
		t.basis.z = _extract_vector(basis[2])

	return t


# -- Node 3D --

static func _serialize_node_3d(node: Spatial) -> Dictionary:
	var data := {}
	data["transform"] = _serialize_transform(node.transform)
	return data


static func _deserialize_node_3d(data: Dictionary) -> Position3D:
	var node = Position3D.new()
	node.transform = _deserialize_transform(data)
	return node


# -- Mesh --

static func _serialize_mesh_instance(mesh_instance: MeshInstance) -> Dictionary:
	var data = _serialize_node_3d(mesh_instance)
	data["mesh"] = {}
	var mesh = mesh_instance.mesh

	if mesh is PrimitiveMesh:
		data["mesh"][0] = _format_array(mesh.get_mesh_arrays())
	else:
		for i in mesh.get_surface_count():
			data["mesh"][i] = _format_array(mesh.surface_get_arrays(i))

	return data


static func _deserialize_mesh_instance(data: Dictionary) -> MeshInstance:
	var mi = MeshInstance.new()
	mi.transform = _deserialize_transform(data)

	var mesh = ArrayMesh.new()
	for i in data["mesh"].keys():
		var source = data["mesh"][i]
		var surface_arrays = []
		surface_arrays.resize(Mesh.ARRAY_MAX)
		surface_arrays[Mesh.ARRAY_VERTEX] = _to_pool(source[Mesh.ARRAY_VERTEX])
		surface_arrays[Mesh.ARRAY_NORMAL] = _to_pool(source[Mesh.ARRAY_NORMAL])
		surface_arrays[Mesh.ARRAY_TEX_UV] = _to_pool(source[Mesh.ARRAY_TEX_UV])
		surface_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(source[Mesh.ARRAY_INDEX])

		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)

	mi.mesh = mesh
	return mi


# -- MultiMesh --

static func _serialize_multi_mesh(mmi: MultiMeshInstance) -> Dictionary:
	var data: Dictionary = _serialize_node_3d(mmi)
	var multimesh: MultiMesh = mmi.multimesh

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = multimesh.mesh
	data["mesh"] = _serialize_mesh_instance(mesh_instance)

	var count: int = multimesh.instance_count
	data["count"] = count
	data["instances"] = []
	for i in count:
		var transform: Transform = multimesh.get_instance_transform(i)
		data["instances"].push_back(_serialize_transform(transform))

	return data


static func _deserialize_multi_mesh(data: Dictionary) -> Dictionary:
	var count = data["count"]

	var multimesh := MultiMesh.new()
	multimesh.instance_count = 0 # Set this to zero or you can't change the other values
	multimesh.mesh = _deserialize_mesh_instance(data["mesh"]).mesh
	multimesh.transform_format = 1
	multimesh.instance_count = count

	for i in count:
		var transform_data: Dictionary = data["instances"][i]
		var transform = _deserialize_transform(transform_data)
		multimesh.set_instance_transform(i, transform)

	var mmi = MultiMeshInstance.new()
	mmi.transform = _deserialize_transform(data["transform"])
	mmi.multimesh = multimesh
	return mmi


# -- Curve 3D --

static func _serialize_curve_3d(path: Path) -> Dictionary:
	var data = _serialize_node_3d(path)
	data["points"] = []

	var curve: Curve3D = path.curve
	for i in curve.get_point_count():
		var point = {}
		point["pos"] = _vector_to_array(curve.get_point_position(i))
		point["in"] = _vector_to_array(curve.get_point_in(i))
		point["out"] = _vector_to_array(curve.get_point_out(i))
		point["tilt"] = curve.get_point_tilt(i)

	return data


static func _deserialize_curve_3d(data: Dictionary) -> Path:
	var curve = Curve3D.new()
	for i in data["points"].size():
		var point = data["points"][i]
		var p_pos = _extract_vector(point["pos"])
		var p_in = _extract_vector(point["in"])
		var p_out = _extract_vector(point["out"])
		curve.add_point(p_pos, p_in, p_out)
		curve.set_point_tilt(i, data["tilt"])

	var path = Path.new()
	path.transform = _deserialize_transform(data)
	path.curve = curve
	return path


# -- Utility functions

static func _extract_vector(data: Array) -> Vector3:
	var v = null
	if data.size() == 3:
		v = Vector3.ZERO
		v.x = data[0]
		v.y = data[1]
		v.z = data[2]

	elif data.size() == 2:
		v = Vector2.ZERO
		v.x = data[0]
		v.y = data[1]

	return v


static func _format_array(array: Array) -> Array:
	for i in array.size():
		if array[i] is PoolVector2Array or array[i] is PoolVector3Array:
			array[i] = _format_pool_vector_array(array[i])
	return array


static func _format_pool_vector_array(array) -> Array:
	var res = []
	for vec in array:
		res.append(_vector_to_array(vec))
	return res


static func _vector_to_array(vec) -> Array:
	if vec is Vector3:
		return [vec.x, vec.y, vec.z]
	if vec is Vector2:
		return [vec.x, vec.y]
	return []


static func _to_pool(array: Array):
	var tmp = []
	for vec in array:
		tmp.append(_extract_vector(vec))

	if tmp[0] is Vector2:
		return PoolVector2Array(tmp)

	return PoolVector3Array(tmp)
