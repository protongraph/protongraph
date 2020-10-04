extends Node
class_name ConceptGraphClient


var _ws := WebSocketClient.new()
var _url := "ws://127.0.0.1:636763"
var _retry_delay := 2.0
var _retry_timer := Timer.new()


func _ready():
	_retry_timer.autostart = false
	_retry_timer.one_shot = true
	add_child(_retry_timer)
	
	Signals.safe_connect(_retry_timer, "timeout", self, "_try_to_connect")
	_ws.connect("connection_error", self, "_on_connection_error")
	_ws.connect("connection_established", self, "_on_connection_etablished")
	_ws.connect("data_received", self, "_on_data_received")
	
	start()


func _process(delta) -> void:
	_ws.poll()


func start():
	print("Attempting to connect to ", _url)
	stop()
	_try_to_connect()


func _try_to_connect() -> void:
	var error = _ws.connect_to_url(_url)
	if error != OK:
		print("Connection failed: ", error)
		_retry_timer.start(_retry_delay)
	else:
		print("No error, connexion succeded?")


func stop() -> void:
	_ws.disconnect_from_host()


func _on_connection_error() -> void:
	print("Connection error to the server")


func _on_connection_etablished(protocol: String) -> void:
	print("Connection etablished ", protocol)


func _on_data_received() -> void:
	print("Data received")
