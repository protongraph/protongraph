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
		print("Error ", json.error, " ", json.error_string, " at ", json.error_line)
		return
	
	var msg: Dictionary = json.result
	if not msg.has("command"):
		return
	
	match msg["command"]:
		"build":
			_on_remote_build_requested(id, msg)


func _on_remote_build_requested(id, msg: Dictionary) -> void:
	if not msg.has("path"):
		return

	var path: String = msg["path"]
	var inspector: Array = msg["inspector"] if msg.has("inspector") else null
	var inputs := []
	if msg.has("inputs"):
		inputs = NodeSerializer.deserialize_all(msg["inputs"])

	var args := {
		"inspector": inspector,
		"inputs": inputs
	}
	GlobalEventBus.dispatch("build_for_remote", [id, path, args])


func _on_remote_build_completed(id, data: Array) -> void:
	var msg = {"type": "build_completed"}
	msg["data"] = []
	for output in data:
		for node in output:
			msg["data"].append(NodeSerializer.serialize(node))
	
	_server.send(id, msg)
