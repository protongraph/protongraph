extends Node


var _client: ConceptGraphClient


func _ready():
	_start_client()

	GlobalEventBus.register_listener(self, "generate", "_on_generate_request")
	GlobalEventBus.register_listener(self, "request_node_list", "_on_node_list_request")


func _start_client() -> void:
	if not _client:
		_client = ConceptGraphClient.new()
		add_child(_client)
		Signals.safe_connect(_client, "data_received", self, "_on_data_received")
	_client.start()


func _on_data_received(data: String) -> void:
	var json = JSON.parse(data)
	if json.error != OK:
		print("Data was not a valid json object")
		print("error ", json.error, " ", json.error_string, " at ", json.error_line)
		return
	
	var msg: Dictionary = DictUtil.fix_types(json.result)
	if not msg.has("type"):
		return
	
	match msg["type"]:
		"node_list":
			_on_node_list_received(msg["data"])
		
		"generation_completed":
			var path = msg["path"] if msg.has("path") else ""
			_on_generation_completed(path)


func _on_node_list_request() -> void:
	var msg = JSON.print({"command": "get_node_list"})
	_client.send(msg)


func _on_node_list_received(nodes: Dictionary) -> void:
	GlobalEventBus.dispatch("node_list_received", nodes)


func _on_generate_request(opts: Dictionary) -> void:
	var cmd := {}
	cmd["command"] = "generate"
	if opts.has("path"):
		cmd["path"] = opts["path"]
	if opts.has("args"):
		cmd["args"] = opts["args"] 
	var msg = JSON.print(cmd)
	_client.send(msg)


func _on_generation_completed(path := "") -> void:
	print("Generation completed, results at ", path)
	GlobalEventBus.dispatch("generation_completed", path)
