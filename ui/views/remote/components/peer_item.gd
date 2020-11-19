class_name PeerItem
extends PanelContainer


onready var peer: Label = $HBoxContainer/VBoxContainer/PeerLabel
onready var template: Label = $HBoxContainer/VBoxContainer/TemplateLabel
onready var status: Label = $HBoxContainer/HBoxContainer/StatusLabel


func _ready():
	pass # Replace with function body.


func set_peer_name(name) -> void:
	peer.text = String(name)


func set_template_path(path: String) -> void:
	template.text = path


func set_status(s: String) -> void:
	status.text = s
