extends Node
class_name IPCServer


signal data_received


var _ws := WebSocketServer.new()
var _port := -1
var _incoming = {}


func _ready() -> void:
	_ws.set_bind_ip("127.0.0.1")
	Signals.safe_connect(_ws, "client_connected", self, "_on_client_connected")
	Signals.safe_connect(_ws, "client_disconnected", self, "_on_client_disconnected")
	Signals.safe_connect(_ws, "client_close_request", self, "_on_client_close_request")
	Signals.safe_connect(_ws, "data_received", self, "_on_data_received")


func _process(_delta) -> void:
	if _ws.is_listening():
		_ws.poll()


func start() -> void:
	stop()
	var possible_ports = _get_possible_ports()
	var error = FAILED
	while error != OK and possible_ports.size() != 0:
		_port = possible_ports.pop_front()
		error = _ws.listen(_port)

	if error != OK:
		print("Failed to start a local server on any of these ports: ", [possible_ports])
	else:
		print("Local server started on port ", _port)


func stop() -> void:
	if _ws.is_listening():
		_ws.stop()


# By default, Godot limits the packet size to 64kb. We can't ask the users to
# manually raise that limit in their project settings so we split the packet
# in smaller chunks to make sure it's always under 64kb. Format is as follow:
# {0: stream_id, 1: chunk_id, 2: total_chunk_count, 2: chunk_data}
func send(client_id: int, data: Dictionary) -> void:
	var id: int = randi()
	var msg: String = JSON.print(data)

	# Calculate how many chunks will be sent, leave some margin for the extra
	# caracters overhead (brackets, comas, digits used for the chunk id and
	# total count and so on) this probably won't take more than 200 chars.
	var chunk_size: int = (64 * 1024) - 200
	var total_chunks: int = msg.length() / chunk_size + 1

	for chunk_id in total_chunks:
		var chunk = msg.substr(chunk_id * chunk_size, chunk_size)
		var packet = {
			0: id,
			1: chunk_id,
			2: total_chunks,
			3: chunk
		}
		packet = JSON.print(packet).to_utf8()
		print("Sending packet: ", packet.size() / 1024.0, "kb")
		var err = _ws.get_peer(client_id).put_packet(packet)
		if err != OK:
			print("Error ", err, " when sending packet to peer ", client_id)


# Return all the possible ports on which the server could try to listen
func _get_possible_ports() -> Array:
	var port_from_cmd = CommandLine.get_arg("port")
	if port_from_cmd:
		return [port_from_cmd] # Port from the command line has priority

	return [4347, 6367] # Return the default ports


func _on_client_connected(id: int, protocol: String) -> void:
	print("Client connected ", id, " ", protocol)
	GlobalEventBus.dispatch("peer_connected", [id])


func _on_client_disconnected(id: int, clean_close := false) -> void:
	print("Client disconnected ", id, " ", clean_close)
	GlobalEventBus.dispatch("peer_disconnected", [id])


func _on_data_received(client_id: int) -> void:
	var packet: PoolByteArray = _ws.get_peer(client_id).get_packet()
	var string = packet.get_string_from_utf8()

	var json = JSON.parse(string)
	if json.error != OK:
		print("Data was not a valid json object")
		print("error ", json.error, " ", json.error_string, " at ", json.error_line)
		return

	var data = DictUtil.fix_types(json.result)

	#print("received data")
	#print(data)
	var id = int(data[0])
	var chunk_id = int(data[1])
	var total_chunks = int(data[2])
	var chunk = data[3]

	if not id in _incoming:
		_incoming[id] = {}

	_incoming[id][chunk_id] = chunk
	if _incoming[id].size() == total_chunks:
		_decode(id, client_id)


func _decode(id: int, client_id: int) -> void:
	var keys: Array = _incoming[id].keys()
	keys.sort()

	var string = ""
	for chunk_id in keys:
		string += _incoming[id][chunk_id]

	var json = JSON.parse(string)
	if json.error != OK:
		print("Data was not a valid json object")
		print("error ", json.error, " ", json.error_string, " at ", json.error_line)
		return

	var data = DictUtil.fix_types(json.result)
	emit_signal("data_received", client_id, data)


func _on_client_close_request(id: int, code: int, reason: String) -> void:
	print("Client close request ", id, " reason: ", reason)
