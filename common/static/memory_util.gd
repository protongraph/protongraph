class_name MemoryUtil
extends RefCounted


static func safe_free(any) -> void:
	if any is Node:
		any.queue_free()

	elif any is Object:
		any.free()

	# Other types don't need specific attention.


# TODO: Might not belong here
static func is_equal(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false

	return a == b


static func is_vector(a: Variant) -> bool:
	return a is Vector2 or a is Vector3 or a is Vector3
