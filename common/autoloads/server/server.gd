extends Node
class_name IPCServer


signal data_received


var _ws := WebSocketServer.new()
var _port := -1
var _clients := []


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


func send(client_id: int, message: String) -> void:
	if _ws.has_peer(client_id):
		return	# No connected clients
	
	var packet = message.to_utf8()
	print("Sending packet: ", packet.size() / 1024.0, "kb")
	var err = _ws.get_peer(client_id).put_packet(packet)
	if err != OK:
		print("Error ", err, " when sending packet to peer ", client_id)


# Return all the possible ports on which the server could try to listen
func _get_possible_ports() -> Array:
	var port_from_cmd = CommandLine.get_arg("port")
	if port_from_cmd:
		return [port_from_cmd] # Port from the command line has priority
	
	return [434743, 636763] # Return the default ports


func _on_client_connected(id: int, protocol: String) -> void:
	print("Client connected ", id, " ", protocol)
	if not _clients.has(id):
		_clients.append(id)


func _on_client_disconnected(id: int, clean_close := false) -> void:
	print("Client disconnected ", id, " ", clean_close)
	_clients.erase(id)


func _on_data_received(id: int) -> void:
	print("Data received from client ", id)
	var packet: PoolByteArray = _ws.get_peer(id).get_packet()
	print("packet received: ", packet)
	var msg = packet.get_string_from_utf8()
	print("string from packet: ", msg)
	emit_signal("data_received", id, msg)


func _on_client_close_request(id: int, reason: String) -> void:
	print("Client clean request ", id, " reason: ", reason)
