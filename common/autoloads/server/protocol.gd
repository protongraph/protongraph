extends Node


var _server: IPCServer


func _ready():
	_start_server()
	GlobalEventBus.register_listener(self, "remote_build_completed", "_on_remote_build_completed")


func _start_server() -> void:
	if not _server:
		_server = IPCServer.new()
		add_child(_server)
		Signals.safe_connect(_server, "data_received", self, "_on_data_received")
		
	_server.start()


func _on_data_received(id: int , data: String) -> void:
	var json = JSON.parse(data)
	if json.error != OK:
		print("Data was not a valid json object")
		print("error ", json.error, " ", json.error_string, " at ", json.error_line)
		return
	
	var msg: Dictionary = json.result
	if not msg.has("command"):
		return
	
	match msg["command"]:
		"generate":
			_on_remote_build_requested(id, msg)


func _on_remote_build_requested(id, msg: Dictionary) -> void:
	print("External process requested a rebuild")
	if not msg.has("path"):
		return
	
	var path: String = msg["path"]
	var args := []
	if msg.has("args"):
		args = msg["args"]
	
	GlobalEventBus.dispatch("generation_requested", [id, path, args])


# TODO: Figure out how to serialize the data and pass it to the Sync plugin
func _on_remote_build_completed(id, data: Array) -> void:
	var msg = {"type": "build_completed"}
	msg["data"] = data
	_server.send(id, msg)


func _serialize_node_trees(roots) -> Array:
	var res := []
	for node in roots:
		
		pass
	return res
