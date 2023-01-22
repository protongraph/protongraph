class_name NotificationsCenter
extends Control


const NotificationScene := preload("./notification.tscn")
const DURATION_SHORT := 1.0
const DURATION_MID := 2.5
const DURATION_LONG := 5.0

@onready var _root: VBoxContainer = $%NotificationRoot


func _ready() -> void:
	GlobalEventBus.graph_saved.connect(_on_graph_saved)
	GlobalEventBus.settings_updated.connect(_on_settings_updated)


func _create(title: String, details: String, icon: Texture, delay: float) -> void:
	var n = NotificationScene.instantiate()
	_root.add_child(n)
	n.create(title, details, icon, delay)


func _on_graph_saved(graph: NodeGraph) -> void:
	var title = "Graph saved"
	var details = graph.save_file_path
	var icon = TextureUtil.get_texture("res://ui/icons/icon_save.svg")
	_create(title, details, icon, DURATION_MID)


func _on_settings_updated(_setting) -> void:
	var icon = TextureUtil.get_texture("res://ui/icons/icon_cog.svg")
	_create("User settings updated", "", icon, DURATION_SHORT)
