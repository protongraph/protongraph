tool
class_name ConceptGraphNodeUtil


static func get_global_position3(node: Spatial) -> Vector3:
	if node.is_inside_tree():
		return node.global_transform.origin
	else:
		return node.transform.origin
