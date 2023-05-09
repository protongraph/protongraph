class_name RemoteSync
extends Plugin


var _ipc_server := IPCServer.new()


func _ready():
	super()
	title = "Remote Sync"
	description = "Sends results to other applications over a websocket."
	version = "0.1"

	_ipc_server.data_received.connect(_on_data_received)
	add_child(_ipc_server)


func enable() -> void:
	var address := "127.0.0.1"
	var port := 9123

	# Load address and port from config.cfg
	var config_file := ConfigFile.new()
	var err = config_file.load("res://plugins/remote_sync/config.cfg")
	if err == OK:
		address = config_file.get_value("host", "address", address)
		port = config_file.get_value("host", "port", port)

	_ipc_server.start(address, port)


func disable() -> void:
	_ipc_server.stop()


# TODO: notify errors to peer
func _on_data_received(peer_id: int, data: Variant) -> void:
	if not "type" in data:
		printerr("Missing type field from incomming message ", data)
		return

	var msg_type: String = data["type"]
	if msg_type != "build_request":
		printerr("Unsupported message type: ", msg_type)
		return

	var id: int = data["id"]
	var file_path: String = data["graph_path"]

	var graph := SaveLoadManager.load_graph(file_path)
	if not graph:
		printerr("Failed to load graph: ", file_path)
		return

	# Update pinned variables with the remote values
	var parameters: Dictionary = str_to_var(data["parameters"])
	graph.override_pinned_variables_values(parameters)

	# Update input nodes
	# TODO

	graph.rebuild()
	await graph.rebuild_completed

	var packed_scene := PackedScene.new()
	packed_scene.pack(graph.output_tree)

	graph.clear()
	MemoryUtil.safe_free(graph)

	var response := {
		"id": id,
		"type": "build_result",
		"scene_tree": packed_scene,
	}
	_ipc_server.send_data(peer_id, response)
