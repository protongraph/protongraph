class_name IPCServer
extends Node


signal data_received(peer_id: int, data)


class ClientConnection:
	var id: int
	var socket: WebSocketPeer
	var buffer := {} # Store incomming packets before merging them.

var _tcp_server := TCPServer.new()
var _connections := {} # Key: client_id, Value: ClientConnection


func _process(_delta) -> void:
	if _tcp_server.is_listening() and _tcp_server.is_connection_available():
		# New connection request
		var connection := ClientConnection.new()
		connection.socket = WebSocketPeer.new()
		connection.socket.accept_stream(_tcp_server.take_connection())

		# Create a unique client id
		var client_id := 0
		while client_id in _connections:
			client_id += 1

		# Store it in the connections dictionary.
		connection.id = client_id
		_connections[client_id] = connection

		print_verbose("New connection: ", client_id, " - ",
			connection.socket.get_connected_host(), ":", connection.socket.get_connected_port())

	# Check the existing connections for new packets.
	for client_id in _connections:
		var client: ClientConnection = _connections[client_id]
		var socket: WebSocketPeer = client.socket
		socket.poll()

		var state = socket.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				_handle_incomming_packet(client, socket.get_packet())

		elif state == WebSocketPeer.STATE_CLOSED:
			var code = socket.get_close_code()
			var reason = socket.get_close_reason()
			print_verbose("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
			_connections.erase(client.id)


func start(address: String, port: int) -> void:
	stop()
	_tcp_server.listen(port, address)
	print_verbose("Server started. Listening to ", address, ":", port)


func stop() -> void:
	for client in _connections:
		client.socket.close()

	_connections.clear()

	if _tcp_server.is_listening():
		_tcp_server.stop()


# This method splits the data into smaller packets before sending them on the
# websocket (Godot limits WebSocket packets size to 64kb by default).
# Custom packet format:
# {0: stream_id, 1: chunk_id, 2: total_chunk_count, 2: data_chunk}
func send_data(client_id: int, data: Dictionary) -> void:
	if not client_id in _connections:
		print_debug("Could not find connection ", client_id)
		return

	var connection: ClientConnection = _connections[client_id]

	var stream_id: int = randi()
	var msg: String = var_to_str(data)

	# Calculate how many & will be sent, leave some margin for the extra
	# caracters overhead (brackets, comas, digits used for the chunk id and
	# total count and so on) this probably won't take more than 200 chars.
	var chunk_size: int = (64 * 1024) - 200
	var total_chunks_count: int = msg.length() / chunk_size + 1

	for chunk_id in total_chunks_count:
		var data_chunk = msg.substr(chunk_id * chunk_size, chunk_size)
		var packet := {
			0: stream_id,
			1: chunk_id,
			2: total_chunks_count,
			3: data_chunk
		}
		var buffer := var_to_str(packet).to_utf8_buffer()
		#print_verbose("Sending packet: ", buffer.size() / 1024.0, "kb")
		var err = connection.socket.put_packet(buffer)
		if err != OK:
			printerr("Code ", err, " while sending packet to peer ", client_id)


func _handle_incomming_packet(client: ClientConnection, packet: PackedByteArray) -> void:
	var string: String = packet.get_string_from_utf8()
	var data: Dictionary = str_to_var(string)
	var stream_id := data[0] as int
	var chunk_id := data[1] as int
	var total_chunks_count := data[2] as int
	var data_chunk : String = data[3]

	if not stream_id in client.buffer:
		client.buffer[stream_id] = {}

	client.buffer[stream_id][chunk_id] = data_chunk

	# If all the packets are there, merge them into the final data.
	if client.buffer[stream_id].size() == total_chunks_count:
		var keys: Array = client.buffer[stream_id].keys()
		keys.sort()

		var final_string := ""
		for key in keys:
			final_string += client.buffer[stream_id][key]

		var merged_data = str_to_var(final_string)
		data_received.emit(client.id, merged_data)
