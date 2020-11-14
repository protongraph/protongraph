extends Reference

var watching: Dictionary = {}
var _objects: Array = []

func watch(emitter, event: String) -> void:
	_objects.append(emitter)
	if emitter.is_connected(event, self, "_add_emit"):
		return
	emitter.set_meta("watcher", self)
	emitter.connect(event, self, "_add_emit", [emitter, event])
	watching[event] = {emit_count = 0, calls = []}


func _add_emit(a = null, b = null, c = null, d = null, e = null, f = null, g = null, h = null, i = null, j = null, k = null):
	var arguments: Array = [a, b, c, d, e, f, g, h, i, j, k]
	var event
	while not event:
		event = arguments.pop_back()
	var obj = arguments.pop_back()
	watching[event].emit_count += 1
	watching[event].calls.append({emitter = obj, args = arguments})

func unwatch(emitter, event: String) -> void:
	if emitter.is_connected(event, self, "_add_emit"):
		emitter.disconnect(event, self, "_add_emit")
		watching.erase(event)
		emitter.set_meta("watcher", null)
		
func clear() -> void:
	pass
	for object in _objects:
		if is_instance_valid(object):
			object.set_meta("watcher", null)
