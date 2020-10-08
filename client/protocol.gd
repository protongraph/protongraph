extends Node


var _client: ConceptGraphClient


func _ready():
	_start_client()
	
	#TMP
	var msg = JSON.print({"command": "get_node_list"})
	print("Sending message ", msg)
	_client.send(msg)


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
	
	var msg: Dictionary = json.result
	print("Message received : ", msg)


func _on_node_list_requested() -> void:
	print("external process requested the node list")
	GlobalEventBus.dispatch("node_list_requested")


func _on_node_list_received(nodes: Dictionary) -> void:
	print("node list received: ", nodes)


func _on_generation_completed(path := "") -> void:
	print("Generation completed, results at ", path)
