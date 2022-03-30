class_name NodeSerializer
extends Node

# Helper to serialize and deserialize node trees to json objects.


var _resources: Array
var _serialized_resources: Array

# _node_metadata consists of an array of Dictionaries of the form [ { fence_planks: <fence_planks_node_path> }, { Path: <Path_node_path> }]
var _node_metadata: Array
# _serialized_node_metadata consists of an output Dictionary of Dictionaries looking something like (tbc)
# {
#	fence_planks: { callback: { fence_planks: <fence_planks_node_path> }, generated_nodes: [ fence_plank_1, fence_plank_2, fence_plank_3 ]},
#   Path: { ... }
# }
# The purpose of the structure of this data is so that the client can then render meshes based on the callback at the generated_nodes
# associated to said input node in { fence_planks, Path } per this example.
var _serialized_node_metadata: Dictionary

# -- Public API --

# Takes data of the form
#[{nodes:[list_of_nodes], resources:[list_of_resource_references]}]
# where a resource_reference is of the form {child_transversal:[node_traversal_sequence], remote_resource_path:path_to_resource_in_client}
# and serializes it into a dictionary.
#
# ## Example data:
# [{nodes:[fence_planks:[Position3D:5697], fence_planks:[Position3D:5701], fence_planks:[Position3D:5705]], resource_references:[{child_transversal:[fence_planks, tmpParent, fence_planks], remote_resource_path:res://assets/fences/models/fence_planks.glb::2}]
# ## Example output:
# {
#	"resources": []
#	"nodes": [fence_planks:[Position3D:5697], fence_planks:[Position3D:5701], fence_planks:[Position3D:5705]]
#   "resource_references": [{child_transversal:[fence_planks, tmpParent, fence_planks], remote_resource_path:res://assets/fences/models/fence_planks.glb::2}]
# }
func serialize(nodes_with_references: Array) -> Dictionary:
	var _resources = []
	var _serialized_resources = []

	var result: Dictionary = {
		"resources": [],
		"resource_references": [],
		"nodes": []
	}

	for node in nodes_with_references[0]["nodes"]:
		result["nodes"].push_back(_serialize_recursive(node))
	
	result["resource_references"].push_back(nodes_with_references[0]["resource_references"][0])
	return result


# Inverse of serialize, takes a dictionary and returns a list of Godot nodes.
func deserialize(data: Dictionary) -> Array:
	var result: Array = []
	_resources = []
	_serialized_resources = data["resources"]
	# Deserialize resources here?

	for node in data["node"]:
		_node_metadata.append(node.node_path_input)
		result.append(_deserialize_recursive(node, _resources))
	return result


# -- Private API --

func _serialize_recursive(node: Node) -> Dictionary:
	var dict := {}
	if not node:
		return dict

	dict["name"] = node.name

	if node is MeshInstance:
		dict["type"] = "mesh"
		dict["data"] = _serialize_node_mesh_instance(node)

	elif node is MultiMeshInstance:
		dict["type"] = "multi_mesh"
		dict["data"] = _serialize_node_multi_mesh(node)

	elif node is Path:
		dict["type"] = "curve_3d"
		dict["data"] = _serialize_node_curve_3d(node)

	elif node is Spatial or node is Position3D:
		dict["type"] = "node_3d"
		dict["data"] = _serialize_node_3d(node)

	if node.get_child_count() > 0:
		dict["children"] = []
		for child in node.get_children():
			var serialized_child: Dictionary = _serialize_recursive(child)
			if not serialized_child.empty():
				dict["children"].push_back(serialized_child)

	return dict

func _deserialize_recursive(data: Dictionary, resource_parent: Array) -> Node:
	var node
	var resource = {}
	resource["name"] = data["name"]
	resource["children"] = []
	match data["type"]:
		"node_3d":
			node = _deserialize_node_3d(data["data"])
		"mesh":
			resource["resource_path"] = data["data"]["resource_path"]
			node = _deserialize_mesh_instance(data["data"])
		"multi_mesh":
			node = _deserialize_multi_mesh(data["data"])
		"curve_3d":
			node = _deserialize_curve_3d(data["data"])
		_:
			print("Type ", data["type"], " is not supported")
			return null

	# Important for callback within Godot Client after procedural generation
	# of scenetree for associated Protongraph template.
	resource_parent.append(resource)

	if data.has("children"):
		for serialized_child in data["children"]:
			var child = _deserialize_recursive(serialized_child, resource["children"])
			if child:
				node.add_child(child)

	if "name" in data:
		node.name = data["name"]

	return node



# -- Transform --

func _serialize_transform(t: Transform) -> Dictionary:
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


func _deserialize_transform(data: Dictionary) -> Transform:
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

func _serialize_node_3d(node: Spatial) -> Dictionary:
	var data := {}
	data["transform"] = _serialize_transform(node.transform)
	return data


func _deserialize_node_3d(data: Dictionary) -> Position3D:
	var node = Position3D.new()
	node.transform = _deserialize_transform(data["transform"])
	return node


# -- Mesh --

func _serialize_node_mesh_instance(mesh_instance: MeshInstance) -> Dictionary:
	var data = _serialize_node_3d(mesh_instance)
	data["mesh"] = _serialize_resource_mesh(mesh_instance.mesh)
	return data


func _deserialize_mesh_instance(data: Dictionary) -> MeshInstance:
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

		if source[Mesh.ARRAY_INDEX]:
			surface_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(source[Mesh.ARRAY_INDEX])

		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)

	mi.mesh = _deserialize_resource_mesh(data["mesh"])
	return mi


# -- MultiMesh --

func _serialize_node_multi_mesh(mmi: MultiMeshInstance) -> Dictionary:
	var data: Dictionary = _serialize_node_3d(mmi)
	var multimesh: MultiMesh = mmi.multimesh

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = multimesh.mesh
	data["mesh"] = _serialize_node_mesh_instance(mesh_instance)

	var count: int = multimesh.instance_count
	data["count"] = count
	data["instances"] = []
	for i in count:
		var transform: Transform = multimesh.get_instance_transform(i)
		data["instances"].push_back(_serialize_transform(transform))

	return data


func _deserialize_multi_mesh(data: Dictionary) -> Dictionary:
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

func _serialize_node_curve_3d(path: Path) -> Dictionary:
	var data = _serialize_node_3d(path)
	data["points"] = []

	var curve: Curve3D = path.curve
	for i in curve.get_point_count():
		var point = {}
		point["pos"] = _vector_to_array(curve.get_point_position(i))
		point["in"] = _vector_to_array(curve.get_point_in(i))
		point["out"] = _vector_to_array(curve.get_point_out(i))
		point["tilt"] = curve.get_point_tilt(i)
		data["points"].push_back(point)

	return data


func _deserialize_curve_3d(data: Dictionary) -> Path:
	var curve = Curve3D.new()
	for i in data["points"].size():
		var point = data["points"][i]
		var p_pos = _extract_vector(point["pos"]) if "pos" in point else Vector3.ZERO
		var p_in = _extract_vector(point["in"]) if "in" in point else Vector3.ZERO
		var p_out = _extract_vector(point["out"]) if "out" in point else Vector3.ZERO
		var tilt = point["tilt"] if "tilt" in point else 0.0
		curve.add_point(p_pos, p_in, p_out)
		curve.set_point_tilt(i, tilt)

	var path = Path.new()
	path.transform = _deserialize_transform(data)
	path.curve = curve
	return path


# -- Resources --

func _serialize_resource_mesh(mesh: Mesh) -> Dictionary:
	var data = {}
	if "resource_name" in mesh:
		data = {
			"surfaces": [],
			"name": mesh.resource_name
		}

		if mesh is PlaceholderMesh:
			data["placeholder_id"] = mesh.id
		elif mesh is PrimitiveMesh:
			data["surfaces"].push_back({
				"material": null,
				"geometry": _format_array(mesh.get_mesh_arrays())
			})
		else:
			for i in mesh.get_surface_count():
				data["surfaces"].push_back({
				"material": null,
				"geometry": _format_array(mesh.surface_get_arrays(i))
			})
	else:
		print("WARNING: Mesh resource is missing resource name")

	return data


func _deserialize_resource_mesh(data: Dictionary) -> Mesh:
	var mesh = ArrayMesh.new()
	mesh.resource_name = data["name"] if "name" in data else ""

	if "surfaces" in data:
		for surface in data["surfaces"]:
			var geometry = surface["geometry"]
			var surface_arrays = []
			surface_arrays.resize(Mesh.ARRAY_MAX)
			surface_arrays[Mesh.ARRAY_VERTEX] = _to_pool(geometry[Mesh.ARRAY_VERTEX])
			surface_arrays[Mesh.ARRAY_NORMAL] = _to_pool(geometry[Mesh.ARRAY_NORMAL])
			surface_arrays[Mesh.ARRAY_TEX_UV] = _to_pool(geometry[Mesh.ARRAY_TEX_UV])

			if geometry[Mesh.ARRAY_INDEX]:
				surface_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(geometry[Mesh.ARRAY_INDEX])

			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
	else:
		print("WARNING: No surfaces in mesh")

	return mesh


# -- Utility functions

func _extract_vector(data: Array) -> Vector3:
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


func _format_array(array: Array) -> Array:
	for i in array.size():
		if array[i] is PoolVector2Array or array[i] is PoolVector3Array:
			array[i] = _format_pool_vector_array(array[i])
	return array


func _format_pool_vector_array(array) -> Array:
	var res = []
	for vec in array:
		res.append(_vector_to_array(vec))
	return res


func _vector_to_array(vec) -> Array:
	if vec is Vector3:
		return [vec.x, vec.y, vec.z]
	if vec is Vector2:
		return [vec.x, vec.y]
	return []


func _to_pool(array: Array):
	var tmp = []
	for vec in array:
		tmp.append(_extract_vector(vec))

	if tmp[0] is Vector2:
		return PoolVector2Array(tmp)

	return PoolVector3Array(tmp)
