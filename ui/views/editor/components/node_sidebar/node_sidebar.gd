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
	# Show the default screen and abort if no nodes are selected
	if not _current:
		_default.visible = true
		_properties.visible = false
		return

	# Show the property screen
	_default.visible = false
	_properties.visible = true
	_name.text = _current.display_name

	# Create a new SidebarProperty object for each slots. They rely on the 
	# safe GraphNodeComponents used by the ConceptNodeUi class.
	for idx in _current._inputs.keys():
		var slot = _current._inputs[idx]
		var name = slot["name"]
		var type = slot["type"]
		var opts = slot["options"]
		var hidden = slot["hidden"]
		var value = _current._get_default_gui_value(idx)
		var ui: SidebarProperty = preload("property.tscn").instance()
		_inputs.add_child(ui)
		ui.create_input(name, type, value, idx, opts)
		ui.set_property_visibility(hidden)
		Signals.safe_connect(ui, "value_changed", self, "_on_sidebar_value_changed")
		Signals.safe_connect(ui, "property_visibility_changed", self, "_on_input_property_visibility_changed", [idx])

	# Outputs are simpler and only require the name and type.
	for idx in _current._outputs.keys():
		var slot: Dictionary = _current._outputs[idx]
		var name = slot["name"]
		var type = slot["type"]
		var hidden = slot["hidden"]
		var ui: SidebarProperty = preload("property.tscn").instance()
		_outputs.add_child(ui)
		ui.create_generic(name, type)
		ui.set_property_visibility(hidden)
		Signals.safe_connect(ui, "property_visibility_changed", self, "_on_output_property_visibility_changed", [idx])


func _on_node_selected(node) -> void:
	if not node:
		return
	
	if _current:
		Signals.safe_disconnect(_current, "gui_value_changed", self, "_on_node_value_changed")
		
	clear()
	_current = node
	_rebuild_ui()
	Signals.safe_connect(_current, "gui_value_changed", self, "_on_node_value_changed")


func _on_node_deleted(node) -> void:
	if node == _current:
		clear()


# Sync changes from the graph node to the side bar
func _on_node_value_changed(value, idx: int) -> void:
	for child in _inputs.get_children():
		if child is SidebarProperty and child.get_index() == idx:
			child.set_value(value)
			return


# Sync changes from the sidebar to the graphnode
func _on_sidebar_value_changed(value, idx: int) -> void:
	if not _current:
		return # Should not happen
	
	_current.set_default_gui_value(idx, value)


func _on_input_property_visibility_changed(visible: bool, index: int) -> void:
	_current.set_input_visibility(index, visible)


func _on_output_property_visibility_changed(visible: bool, index: int) -> void:
	_current.set_output_visibility(index, visible)
