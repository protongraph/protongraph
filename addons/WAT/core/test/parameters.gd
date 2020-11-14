extends Reference


var _keys: Array = []
var _values: Array = []

var parameters: Dictionary = {}
#parameters([["a", "b", "expected"], [2, 2, 4], [5, 5, 10], [7, 7, 14]])
func parameters(list: Array) -> bool:
	if _keys.empty() or _values.empty():
		# Keys aren't empty, so we'll be updating this implicilty every time a call is made instead
		_keys = list.pop_front()
		_values = list
	return _update()

func _update() -> bool:
	parameters.clear()
	var values = _values.pop_front()
	for i in _keys.size():
		parameters[_keys[i]] = values[i]
	return not _values.empty()
