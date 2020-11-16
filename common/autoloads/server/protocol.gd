extends Node


var _server: IPCServer


func _ready():
	_start_server()
	GlobalEventBus.register_listener(self, "remote_build_completed", "_on_remote_build_completed")


func _start_server() -> void:
	if not _server:
		_server = IPCServer.new()
		add_child(_server)
		Signals.safe_connect(_server, "data_received", self, "_on_data_received")
		
	_server.start()


func _on_data_received(id: int , data: String) -> void:
	var json = JSON.parse(data)
	if json.error != OK:
		print("Data was not a valid json object")
		print("Error ", json.error, " ", json.error_string, " at ", json.error_line)
		return
	
	var msg: Dictionary = json.result
	if not msg.has("command"):
		return
	
	match msg["command"]:
		"build":
			_on_remote_build_requested(id, msg)


func _on_remote_build_requested(id, msg: Dictionary) -> void:
	if not msg.has("path"):
		return
	
	var path: String = msg["path"]
	var args := []
	if msg.has("args"):
		args = msg["args"]
	
	GlobalEventBus.dispatch("build_for_remote", [id, path, args])


func _on_remote_build_completed(id, data: Array) -> void:
	var msg = {"type": "build_completed"}
	msg["data"] = []
	for output in data:
		for node in output:
			msg["data"].append(_serialize_node_tree(node))
	
	_server.send(id, msg)


func _serialize_node_tree(root: Node) -> Dictionary:
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
			res["children"].append(_serialize_node_tree(child))

	return res


func _serialize_node_3d(node: Spatial) -> Dictionary:
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


func _serialize_mesh(mesh_instance: MeshInstance) -> Dictionary:
	var data = _serialize_node_3d(mesh_instance)
	data["mesh"] = {}
	var mesh = mesh_instance.mesh
	
	if mesh is PrimitiveMesh:
		data["mesh"][0] = _format_array(mesh.get_mesh_arrays())
	else:
		for i in mesh.get_surface_count():
			data["mesh"][i] = _format_array(mesh.surface_get_arrays(i))
	
	return data


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
