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
	$ToggleGraphInspector.toggled.connect(_on_button_toggled.bind(toggle_graph_inspector))
	$ToggleGraphEditor.toggled.connect(_on_button_toggled.bind(toggle_graph_editor))
	$ToggleNodeInspector.toggled.connect(_on_button_toggled.bind(toggle_node_inspector))
	$ToggleViewport.toggled.connect(_on_button_toggled.bind(toggle_viewport))


func _on_button_pressed(s: Signal) -> void:
	s.emit()


func _on_button_toggled(enabled: bool, s: Signal) -> void:
	s.emit(enabled)
