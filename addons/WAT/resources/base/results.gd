tool
extends Resource

export(Array, String) var failures: Array = []
export(Array, Dictionary) var _list: Array = []

func deposit(results: Array) -> void:
	_list = results
	_add_failures(results)
	ResourceSaver.save(resource_path, self)
	
func _add_failures(results) -> void:
	failures = []
	for result in results:
		if not result.success:
			failures.append(result.path)
	
func withdraw() -> Array:
	var deep_copy: bool = true
	var results: Array = _list.duplicate(deep_copy)
	_list.clear()
	ResourceSaver.save(resource_path, self)
	return results
	
func exist() -> bool:
	return not _list.empty()
