extends Node


var _server: IPCServer
var _node_serializer: NodeSerializer


func _ready():
	if not _node_serializer:
		_node_serializer = NodeSerializer.new()

	_start_server()
	GlobalEventBus.register_listener(self, "remote_build_completed", "_on_remote_build_completed")


func _start_server() -> void:
	if not _server:
		_server = IPCServer.new()
		add_child(_server)
		Signals.safe_connect(_server, "data_received", self, "_on_data_received")

	_server.start()


func _on_data_received(id: int , data: Dictionary) -> void:
	if not data.has("command"):
		return

	match data["command"]:
		"build":
			_on_remote_build_requested(id, data)


func _on_remote_build_requested(id, msg: Dictionary) -> void:
	if not msg.has("path"):
		return

	var path: String = msg["path"]
	var inspector: Array = msg["inspector"] if msg.has("inspector") else null
	var inputs := []
	if msg.has("inputs"):
		inputs = _node_serializer.deserialize(msg["inputs"])

	var args := {
		"inspector": inspector,
		"inputs": inputs
	}
	GlobalEventBus.dispatch("build_for_remote", [id, path, args])


func _on_remote_build_completed(id, data: Array) -> void:
	var msg = {"type": "build_completed"}
	msg["data"] = _node_serializer.serialize(data)
	_server.send(id, msg)
