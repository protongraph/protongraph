class_name NodeInspector
extends Control

# The Node sidebar displays the selected node inputs, outputs and documentation.
# From there you can change the node's local values and hide or show individual
# parts of the graph UI.
#
# Hiding parts of the UI is useful for nodes havinga lot of parameters not
# connected them to anything. Hiding them makes the node appear smaller and
# saves space on the graph, while still being able to edit the local values.


const PropertyScene = preload("property.tscn")

var _proton_node_ui: ProtonNodeUi
var _proton_node: ProtonNode

@onready var _default: Control = $"%DefaultContent"
@onready var _properties: Control = $"%Properties"
@onready var _name_label: Label = $"%NameLabel"
@onready var _input_label: Label = $"%InputsLabel"
@onready var _output_label: Label = $"%OutputsLabel"
@onready var _extra_label: Label = $"%ExtrasLabel"
@onready var _documentation_label: Label = $"%DocumentationLabel"
@onready var _inputs: Control = $"%Inputs"
@onready var _outputs: Control = $"%Outputs"
@onready var _extras: Control = $"%Extras"
# @onready var _documentation: DocumentationPanel = $"%Documentation


func clear() -> void:
	_clear_ui()
	_proton_node_ui = null
	_proton_node = null
	_name_label.text = ""
	_default.visible = true
	_properties.visible = false


func display_node(node: ProtonNodeUi) -> void:
	clear()

	if not node:
		return

	if is_instance_valid(_proton_node_ui):
		_proton_node_ui.value_changed.disconnect(_on_node_value_changed)
		_proton_node_ui.connection_changed.disconnect(_on_node_connection_changed)

	_proton_node_ui = node
	_proton_node = node.proton_node
	_rebuild_ui()
	_proton_node_ui.value_changed.connect(_on_node_value_changed)
	_proton_node_ui.connection_changed.connect(_on_node_connection_changed)


func _clear_ui() -> void:
	NodeUtil.remove_children(_inputs)
	NodeUtil.remove_children(_outputs)
	NodeUtil.remove_children(_extras)


func _rebuild_ui() -> void:
	_clear_ui()

	# Show the default screen and abort if no nodes are selected
	if not _proton_node_ui:
		_default.visible = true
		_properties.visible = false
		return

	# Show the property screen
	_default.visible = false
	_properties.visible = true
	_name_label.text = _proton_node.title

	# Create a new SidebarProperty object for each slots. They rely on the
	# same GraphNodeComponents used by the ProtonNodeUi class.
	for idx in _proton_node.inputs:
		var input: ProtonNodeSlot = _proton_node.inputs[idx]
		var ui: SidebarProperty = PropertyScene.instantiate()
		_inputs.add_child(ui)

		# Don't display the local value if something is connected to the input slot
		if _proton_node_ui.is_input_slot_connected(idx):
			ui.create_generic(input.name, input.type)
		else:
			ui.create_input(input.name, input.type, input.local_value, idx, input.options)

		ui.set_property_visibility(input.visible)
		ui.value_changed.connect(_on_sidebar_value_changed)
		ui.property_visibility_changed.connect(_on_input_property_visibility_changed.bind(idx))

	# Outputs are simpler and only require the name and type.
	for idx in _proton_node.outputs:
		var output: ProtonNodeSlot = _proton_node.outputs[idx]
		var ui: SidebarProperty = PropertyScene.instantiate()
		_outputs.add_child(ui)
		ui.create_generic(output.name, output.type)
		ui.set_property_visibility(output.visible)
		ui.property_visibility_changed.connect(_on_output_property_visibility_changed.bind(idx))

	# For custom components (like 2D preview or other things that don't fall in
	# the previous categories. We just display a name.
	for idx in _proton_node.extras:
		var extra = _proton_node.extras[idx]
		var ui: SidebarProperty = PropertyScene.instantiate()
		_extras.add_child(ui)
		ui.create_generic(extra.name, -1)
		ui.set_property_visibility(extra.visible)
		ui.property_visibility_changed.connect(_on_extra_property_visibility_changed.bind(idx))

	#_documentation.rebuild(_selected_node.doc)

	_input_label.visible = _inputs.get_child_count() != 0
	_output_label.visible = _outputs.get_child_count() != 0
	_extra_label.visible = _extras.get_child_count() != 0
	#_documentation_label.visible = _documentation.get_child_count() != 0


func _on_node_deleted(node) -> void:
	if node == _proton_node_ui:
		clear()


# Sync changes from the graph node to the side bar
func _on_node_value_changed(value, idx: int) -> void:
	for child in _inputs.get_children():
		if child is SidebarProperty and child.get_slot_index() == idx:
			child.set_value(value)
			return


# Rebuild the UI the next frame. Useful when a node has inputs mirroring
# other sockets. Don't call it immediately or the slots data in the node
# won't be up to date yet.
func _on_node_connection_changed() -> void:
	call_deferred("_rebuild_ui")


# Sync changes from the sidebar to the graphnode
func _on_sidebar_value_changed(value, idx: int) -> void:
	if not _proton_node:
		return
	_proton_node.inputs[idx].local_value = value


func _on_input_property_visibility_changed(visible: bool, index: int) -> void:
	_proton_node.set_input_slot_visibility(index, visible)


func _on_output_property_visibility_changed(visible: bool, index: int) -> void:
	_proton_node.set_output_slot_visibility(index, visible)


func _on_extra_property_visibility_changed(visible: bool, index: int) -> void:
	_proton_node.set_extra_slot_visibility(index, visible)
