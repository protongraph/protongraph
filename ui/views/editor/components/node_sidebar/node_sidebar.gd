extends Control
class_name NodeSidebar


var _current: ConceptNode


onready var _default: Control = $MarginContainer/DefaultContent
onready var _properties: Control = $MarginContainer/Properties
onready var _name: Label = $MarginContainer/Properties/NameLabel
onready var _inputs: Control = $MarginContainer/Properties/Inputs
onready var _outputs: Control = $MarginContainer/Properties/Outputs


func clear() -> void:
	for c in _inputs.get_children():
		c.queue_free()
		
	for c in _outputs.get_children():
		c.queue_free()
	
	_current = null
	_name.text = ""
	_default.visible = true
	_properties.visible = false


func _rebuild_ui() -> void:
	if not _current:
		_default.visible = true
		_properties.visible = false
		return

	_default.visible = false
	_properties.visible = true
	_name.text = _current.display_name

	for index in _current._inputs.keys():
		var slot = _current._inputs[index]
		var name = slot["name"]
		var type = slot["type"]
		var value = _current._get_default_gui_value(index)
		var ui: SidebarProperty = preload("property.tscn").instance()
		_inputs.add_child(ui)
		ui.create_input(name, type, value)

	for slot in _current._outputs.values():
		var name = slot["name"]
		var type = slot["type"]
		var ui: SidebarProperty = preload("property.tscn").instance()
		_outputs.add_child(ui)
		ui.create_generic(name, type)


func _on_node_selected(node) -> void:
	if not node:
		return
		
	clear()
	_current = node
	_rebuild_ui()


func _on_node_deleted(node) -> void:
	if node == _current:
		clear()
