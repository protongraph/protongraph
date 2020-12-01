extends Control
class_name NodeSidebar


# The Node sidebar is a panel shown on the left side of the graph editor.
# From there you can change the node locals value but also decide to hide or
# show individual parts of the graph UI. This is useful for nodes having 
# a lot of parameters (like the noises nodes) but you don't connect them to
# anything. Hiding them makes the node appear smaller and saves space on the
# graph. This is purely visual, the node keeps behaving exactly the same way.


var _current: ProtonNode

onready var _default: Control = $MarginContainer/DefaultContent
onready var _properties: Control = $MarginContainer/Properties
onready var _name: Label = $MarginContainer/Properties/NameLabel
onready var _input_label: Label = $MarginContainer/Properties/InputLabel
onready var _output_label: Label = $MarginContainer/Properties/OutputLabel
onready var _extra_label: Label = $MarginContainer/Properties/ExtraLabel
onready var _documentation_label: Label = $MarginContainer/Properties/DocumentationLabel
onready var _inputs: Control = $MarginContainer/Properties/Inputs
onready var _outputs: Control = $MarginContainer/Properties/Outputs
onready var _extras: Control = $MarginContainer/Properties/Extras
onready var _documentation: DocumentationPanel = $MarginContainer/Properties/Documentation


func clear() -> void:
	clear_ui()
	_current = null
	_name.text = ""
	_default.visible = true
	_properties.visible = false


func clear_ui() -> void:
	NodeUtil.remove_children(_inputs)
	NodeUtil.remove_children(_outputs)
	NodeUtil.remove_children(_extras)


func _rebuild_ui() -> void:
	# Show the default screen and abort if no nodes are selected
	if not _current:
		_default.visible = true
		_properties.visible = false
		return
	
	clear_ui()

	# Show the property screen
	_default.visible = false
	_properties.visible = true
	_name.text = _current.display_name

	# Create a new SidebarProperty object for each slots. They rely on the 
	# safe GraphNodeComponents used by the ProtonNodeUi class.
	for idx in _current._inputs:
		var slot = _current._inputs[idx]
		var name = slot["name"]
		var type = slot["type"]
		var opts = slot["options"]
		var hidden = slot["hidden"]
		var value = _current._get_default_gui_value(idx)
		var ui: SidebarProperty = preload("property.tscn").instance()
		_inputs.add_child(ui)
		if slot["mirror"].empty():
			ui.create_input(name, type, value, idx, opts)
		else:
			ui.create_generic(name, type)
		ui.set_property_visibility(hidden)
		Signals.safe_connect(ui, "value_changed", self, "_on_sidebar_value_changed")
		Signals.safe_connect(ui, "property_visibility_changed", self, "_on_input_property_visibility_changed", [idx])

	# Outputs are simpler and only require the name and type.
	for idx in _current._outputs:
		var slot: Dictionary = _current._outputs[idx]
		var name = slot["name"]
		var type = slot["type"]
		var hidden = slot["hidden"]
		var ui: SidebarProperty = preload("property.tscn").instance()
		_outputs.add_child(ui)
		ui.create_generic(name, type)
		ui.set_property_visibility(hidden)
		Signals.safe_connect(ui, "property_visibility_changed", self, "_on_output_property_visibility_changed", [idx])
	
	# For custom components (like 2D preview or other things that don't fall in
	# the previous categories. We just display a name.
	for idx in _current._extras:
		var extra = _current._extras[idx]
		var name = Constants.get_readable_name(extra["type"])
		var hidden = extra["hidden"]
		var ui: SidebarProperty = preload("property.tscn").instance()
		_extras.add_child(ui)
		ui.create_generic(name, -1)
		ui.set_property_visibility(hidden)
		Signals.safe_connect(ui, "property_visibility_changed", self, "_on_extra_property_visibility_changed", [idx])
	
	_documentation.rebuild(_current.doc)
	
	_input_label.visible = _inputs.get_child_count() != 0
	_output_label.visible = _outputs.get_child_count() != 0
	_extra_label.visible = _extras.get_child_count() != 0
	_documentation_label.visible = _documentation.get_child_count() != 0
	


func _on_node_selected(node) -> void:
	if not node:
		return
	
	if _current:
		Signals.safe_disconnect(_current, "gui_value_changed", self, "_on_node_value_changed")
		Signals.safe_disconnect(_current, "connection_changed", self, "_on_node_connection_changed")
		
	clear()
	_current = node
	_rebuild_ui()
	Signals.safe_connect(_current, "gui_value_changed", self, "_on_node_value_changed")
	Signals.safe_connect(_current, "connection_changed", self, "_on_node_connection_changed")


func _on_node_deleted(node) -> void:
	if node == _current:
		clear()


# Sync changes from the graph node to the side bar
func _on_node_value_changed(value, idx: int) -> void:
	for child in _inputs.get_children():
		if child is SidebarProperty and child.get_index() == idx:
			child.set_value(value)
			return


# Rebuild the UI the next frame. Useful when a node has inputs mirroring
# other sockets. Don't call it immediately or the slots data in the node
# won't be up to date yet.
func _on_node_connection_changed() -> void:
	call_deferred("_rebuild_ui")


# Sync changes from the sidebar to the graphnode
func _on_sidebar_value_changed(value, idx: int) -> void:
	if not _current:
		return
	_current.set_default_gui_value(idx, value)


func _on_input_property_visibility_changed(visible: bool, index: int) -> void:
	_current.set_input_visibility(index, visible)


func _on_output_property_visibility_changed(visible: bool, index: int) -> void:
	_current.set_output_visibility(index, visible)


func _on_extra_property_visibility_changed(visible: bool, index: int) -> void:
	_current.set_extra_visibility(index, visible)
