@tool
extends MarginContainer


@export_file("*.tpgn") var graph_path: String
@export var title: String
@export var description: String
@export var thumbnail: Texture2D


func _ready():
	$%Button.pressed.connect(_on_pressed)
	$%TitleLabel.set_text(title)
	$%DescriptionLabel.set_text(description)

	if thumbnail:
		$%Thumbnail.set_texture(thumbnail)


func _on_pressed() -> void:
	if not graph_path.is_empty():
		GlobalEventBus.load_graph.emit(graph_path)
