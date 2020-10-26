extends Node

var test_directors: Dictionary = {}

func register(director) -> void:
	# This probably doesn't need to exist as a singleton?
	# We could likely store a cache within each test
	# This way we can isolate it from other caches
	# (We could even probably store it directly within the factory)
	if director.get_instance_id() in test_directors:
		push_warning("Director Object is already registered")
		return
	test_directors[director.get_instance_id()] = director
	
func method(instance_id: int, method: String) -> Object:
	return test_directors[instance_id].methods[method]
	
func clear() -> void:
	var directors = test_directors.values()
	while not directors.empty():
		var director = directors.pop_back()
		director.clear()
