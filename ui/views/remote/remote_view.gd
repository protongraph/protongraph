extends Control
class_name RemoteView


var _peer_item = load("res://ui/views/remote/components/peer_item.tscn")
var _peers = {}

onready var _root: Control = $MarginContainer/VBoxContainer/ScrollContainer/Peers
onready var _info: Control = $MarginContainer/VBoxContainer/InfoContainer


func _ready():
	GlobalEventBus.register_listener(self, "peer_connected", "_on_peer_connected")
	GlobalEventBus.register_listener(self, "peer_disconnected", "_on_peer_disconnected")
	GlobalEventBus.register_listener(self, "remote_build_started", "_on_build_started")
	GlobalEventBus.register_listener(self, "remote_build_completed", "_on_build_completed")
	rebuild_ui()


func rebuild_ui() -> void:
	_info.visible = false
	NodeUtil.remove_children(_root)

	if _peers.empty():
		_info.visible = true
		return

	for id in _peers:
		_create_item(id)


func _create_item(id: int) -> void:
	var item = _peer_item.instance()
	_root.add_child(item)
	item.set_peer_name(id)
	_peers[id]["ui"] = item


func _on_peer_connected(id: int) -> void:
	_peers[id] = {
		"build": false
	}
	_create_item(id)
	_info.visible = false


func _on_peer_disconnected(id: int) -> void:
	if not _peers.has(id):
		return

	if _peers[id].has("ui"):
		_root.remove_child(_peers[id]["ui"])

	_peers.erase(id)


func _on_build_started(id: int) -> void:
	print("in the _on_build_started function")
	pass # Update peer status


func _on_build_completed(id: int, _res) -> void:
	print("in the _on_build_completed function")
	print(_res)
	pass # Update peer status
