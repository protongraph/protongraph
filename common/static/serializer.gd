class_name NodeSerializer

# Helper to serialize and deserialize node trees to json objects.


# Takes a single node and serialize its contents and its children's content
# into a dictionary
static func serialize(root: Node) -> Dictionary:
	var res := {}
	res["name"] = root.name
	
	if root is MeshInstance:
		res["type"] = "mesh"
		res["data"] = _serialize_mesh(root)
	elif root is Spatial:
		res["type"] = "node_3d"
		res["data"] = _serialize_node_3d(root)
	
	if root.get_child_count() > 0:
		res["children"] = []
		for child in root.get_children():
			res["children"].push_back(serialize(child))

	return res


# Takes a dictionnary and recreates the Godot node tree from there. This is 
# the inverse of serialize.
static func deserialize(data: Dictionary) -> Node:
	var res
	match data["type"]:
		"node_3d":
			res = _deserialize_node_3d(data["data"])
		"mesh":
			res = _deserialize_mesh(data["data"])
	
	if data.has("children"):
		for child in data["children"]:
			res.add_child(deserialize(child))
	
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


# -- Node 3D --

static func _serialize_node_3d(node: Spatial) -> Dictionary:
	var data := {}
	var origin = node.transform.origin
	var basis = node.transform.basis
	
	data["pos"] = _vector_to_array(origin)
	data["basis"] = [
		_vector_to_array(basis.x),
		_vector_to_array(basis.y),
		_vector_to_array(basis.z)
	]
	return data


static func _deserialize_node_3d(data: Dictionary) -> Position3D:
	var node = Position3D.new()
	node.name = data["name"]
	node.transform = _extract_transform(data)
	return node


# -- Mesh --

static func _serialize_mesh(mesh_instance: MeshInstance) -> Dictionary:
	var data = _serialize_node_3d(mesh_instance)
	data["mesh"] = {}
	var mesh = mesh_instance.mesh
	
	if mesh is PrimitiveMesh:
		data["mesh"][0] = _format_array(mesh.get_mesh_arrays())
	else:
		for i in mesh.get_surface_count():
			data["mesh"][i] = _format_array(mesh.surface_get_arrays(i))
	
	return data


static func _deserialize_mesh(data: Dictionary) -> MeshInstance:
	var mi = MeshInstance.new()
	mi.transform = _extract_transform(data)
	
	var mesh = ArrayMesh.new()
	for i in data["mesh"]:
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


# -- Utility functions

static func _extract_transform(data: Dictionary) -> Transform:
	var t = Transform()
	if data.has("pos"):
		t.origin = _extract_vector(data["pos"])
	
	if data.has("basis"):
		var basis: Array = data["basis"]
		t.basis.x = _extract_vector(basis[0])
		t.basis.y = _extract_vector(basis[1])
		t.basis.z = _extract_vector(basis[2])
	
	return t


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
		res.push_back(_vector_to_array(vec))
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
		tmp.push_back(_extract_vector(vec))

	if tmp[0] is Vector2:
		return PoolVector2Array(tmp)

	return PoolVector3Array(tmp)
