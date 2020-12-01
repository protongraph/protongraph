extends Node
class_name NodePool

# TODO : Do NOT use until this is thread safe

var _pools := {}


func _exit_tree() -> void:
	clear()


"""
Search in the node pools for a node that's not already used. If no nodes are found, create one
with the proper type and store in in the pool.
The 'type' variable is a GDScripNativeClass object, which means you can call this method like this

	get_or_create(Position3D)

And it will take care of calling new() only if necessary.
"""
func get_or_create(type: GDScriptNativeClass) -> Node:
	var node
	if _pools.has(type):
		var available_nodes: Array = _pools[type]["free"]
		if available_nodes.size() == 0:
			node = type.new()
			_pools[type]["used"].push_back(node)
		else:
			node = available_nodes.pop_front()
			_pools[type]["used"].push_back(node)
	else:
		node = type.new()
		_pools[type] = {
			"free": [],
			"used": [node]
		}

	return node


"""
Once you don't need the node anymore, call this method to release it. Next time get_or_create will
be called with the matching type, it will reuse that node instead of creating a new one.
I can't find a way to convert a Node to a GDScriptNativeClass object so for now, manually specify
the node type when calling this method.

var node = pool.get_or_create(Position3D) # Or any other type
pool.release_node(Position3D, node)
"""
func release_node(type: GDScriptNativeClass, node) -> void:
	# TODO find a way to convert Node to GDScriptNativeClass or use something else to use as a key
	if not _pools.has(type):
		node.queue_free()
		return

	var used = _pools[type]["used"]
	var index = used.find(node)
	if index == -1:
		return

	node = used[index]
	used.remove(index)

	if node.get_parent():
		node.get_parent().remove_child(node)
	if node is Spatial:
		node.transform = Transform()
	var script = node.get_script()
	if script:
		script._init()	#TODO : not sure that's enough

	_pools[type]["free"].push_back(node)


"""
Release all nodes
"""
func release_all_nodes() -> void:
	for type in _pools:
		for node in _pools[type]["used"]:
			release_node(type, node)


"""
Loop through the dictionary and free every object that doesn't have a parent. If an object is in
the scene tree, it will no longer be managed by the pool node.
"""
func clear() -> void:
	for key in _pools:
		for key2 in _pools[key]:
			var p = _pools[key][key2]
			while p.size() > 0:
				var node = p.pop_front()
				if not node.get_parent():
					node.queue_free()
	_pools = {}
