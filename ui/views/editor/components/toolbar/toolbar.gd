class_name Toolbar
extends VBoxContainer

signal create_node
signal rebuild
signal save_graph
signal toggle_graph_inspector
signal toggle_node_inspector
signal toggle_graph_editor
signal toggle_viewport


func _ready():
	$Create.pressed.connect(_on_button_pressed.bind(create_node))
	$Rebuild.pressed.connect(_on_button_pressed.bind(rebuild))
	$Save.pressed.connect(_on_button_pressed.bind(save_graph))
	$ToggleGraphInspector.pressed.connect(_on_button_pressed.bind(toggle_graph_inspector))
	$ToggleGraphEditor.pressed.connect(_on_button_pressed.bind(toggle_graph_editor))
	$ToggleNodeInspector.pressed.connect(_on_button_pressed.bind(toggle_node_inspector))
	$ToggleViewport.pressed.connect(_on_button_pressed.bind(toggle_viewport))


func _on_button_pressed(s: Signal) -> void:
	s.emit()
