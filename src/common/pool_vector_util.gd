tool
class_name PoolVectorUtil
extends Reference

"""
Utility tools for PoolVectorXArray operations
"""

 # Assumes Y axis is ignored. TODO : Find a more generic way
static func to_vector2(vectors: PoolVector3Array) -> PoolVector2Array:
	var res = PoolVector2Array()
	for v in vectors:
		res.append(Vector2(v.x, v.z))
	return res
