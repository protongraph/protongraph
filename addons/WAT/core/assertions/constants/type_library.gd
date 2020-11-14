extends Reference

static func get_type_string(property_id: int) -> String:
	match property_id:
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "bool"
		TYPE_INT:
			return "int"
		TYPE_REAL:
			return "float"
		TYPE_STRING:
			return "String"
		TYPE_VECTOR2:
			return "Vector2"
		TYPE_RECT2:
			return "Rect2"
		TYPE_VECTOR3:
			return "Vector3"
		TYPE_TRANSFORM2D:
			return "Transform2D"
		TYPE_PLANE:
			return "Plane"
		TYPE_QUAT:
			return "Quat"
		TYPE_AABB:
			return "AABB"
		TYPE_BASIS:
			return "Basis"
		TYPE_TRANSFORM:
			return "Transform"
		TYPE_COLOR:
			return "Color"
		TYPE_NODE_PATH:
			return "NodePath"
		TYPE_RID:
			return "RID"
		TYPE_OBJECT:
			return "Object"
		TYPE_DICTIONARY:
			return "Dictionary"
		TYPE_ARRAY:
			return "Array"
		TYPE_RAW_ARRAY:
			return "PoolByteArray"
		TYPE_INT_ARRAY:
			return "PoolIntArray"
		TYPE_REAL_ARRAY:
			return "PoolRealArray"
		TYPE_STRING_ARRAY:
			return "PoolStringArray"
		TYPE_VECTOR2_ARRAY:
			return "PoolVector2Array"
		TYPE_VECTOR3_ARRAY:
			return "PoolVector3Array"
		TYPE_COLOR_ARRAY:
			return "PoolColorArray"
	return "OutOfBounds"
