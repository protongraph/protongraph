extends Node

var _recording: Object
var _properties: Dictionary
var _is_recording: bool = false

func record(what: Object, properties: Array) -> void:
	_recording = what
	for property in properties:
		_properties[property] = []
	
func start() -> void:
	_is_recording = true
	
func stop() -> void:
	_is_recording = false
	
func _process(delta: float) -> void:
	if _is_recording:
		_capture()
	
func _capture() -> void:
	if not is_instance_valid(_recording):
		return
	for property in _properties:
		_properties[property].append(_recording.get(property))
		
func get_property_timeline(property: String):
	return _properties[property]
	
func get_property_map() -> Dictionary:
	return _properties
