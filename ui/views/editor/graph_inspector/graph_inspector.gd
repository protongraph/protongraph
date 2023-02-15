class_name GraphInspector
extends Control


var _graph: NodeGraphEditor

@onready var _root: Control = $%PropertiesRoot
@onready var _default: Control = $%DefaultInfo


func _ready():
	clear()
	_default.visible = true


func set_graph_editor(graph: NodeGraphEditor) -> void:
	_graph = graph
	rebuild_ui()


func clear() -> void:
	NodeUtil.remove_children(_root)


func rebuild_ui() -> void:
	clear()
	var pinned := {}

	for node_ui in _graph.get_children():
		if not node_ui is ProtonNodeUi:
			continue

		var node: ProtonNode = node_ui.proton_node
		if not "pinned" in node.external_data:
			continue

		var pinned_map = node.external_data["pinned"]
		for idx in pinned_map:
			var pin_name = pinned_map[idx]
			pinned[pin_name] = {
				"idx": idx,
				"slot": node.inputs[idx],
				"ui": node_ui,
			}

	var names = pinned.keys()
	names.sort()

	for pin_path in names:
		var idx = pinned[pin_path]["idx"]
		var slot: ProtonNodeSlot = pinned[pin_path]["slot"]
		var node_ui: ProtonNodeUi = pinned[pin_path]["ui"]
		var node_component = node_ui._input_component_map[idx]
		var node: ProtonNode = node_ui.proton_node

		var component = UserInterfaceUtil.create_component(pin_path, slot.type, slot.options)
		component.set_value(node.get_local_value(idx))
		component.notify_connection_changed(false)
		_root.add_child(component)

		component.value_changed.connect(_on_inspector_value_changed.bind(idx, node_ui))
		node_component.value_changed.connect(_on_node_value_changed.bind(component))

	_default.visible = _root.get_child_count() == 0


func _on_inspector_value_changed(value, idx: String, node_ui: ProtonNodeUi) -> void:
	node_ui.set_local_value(idx, value)


func _on_node_value_changed(value, component: GraphNodeUiComponent) -> void:
	component.set_value(value)
