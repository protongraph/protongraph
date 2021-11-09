extends Node

# Listen for remote requests and run the builds locally before sending back
# the results.


var _peers := {}


func _ready():
	GlobalEventBus.register_listener(self, "build_for_remote", "_on_build_requested")
	GlobalEventBus.register_listener(self, "template_saved", "_on_template_saved")


func get_peers() -> Dictionary:
	return _peers


func _set_inspector_values(tpl: Template, values: Array) -> void:
	if not values:
		return

	if not tpl.inspector:
		var remote_inspector = RemoteInspector.new()
		tpl.inspector = remote_inspector

	tpl.inspector.update_variables(values)


func _set_inputs(tpl: Template, inputs: Array) -> void:
	if not inputs:
		return
	for input in inputs:
		if input:
			tpl.set_remote_input(input.name, input)

# resource_references: [{children:[], name:Path}, {children:[{children:[{children:[], name:fence_planks, resource_path:res://assets/fences/models/fence_planks.glb}], name:tmpParent}], name:fence_planks}]
# inputs: [Path:[Path:3492], fence_planks:[Position3D:3494]]
func _set_resource_references(tpl: Template, inputs: Array, resource_references: Array, child_transversal: Array = []) -> void:
	if not inputs:
		return
	if not resource_references:
		return
	for input in inputs:
		if input:
			for resource_reference in resource_references:
				if resource_reference && resource_reference["name"] == input.name && resource_reference["resource_path"]:
					tpl.set_remote_resource(input.name, child_transversal + [resource_reference.name], resource_reference["resource_path"])
				else:
					# Why "else" condition here at present? Decided a maximum of only one resource_reference per top level input for now (which is admittedly potentially unrealistic for advanced usecases); can be revised later.
					_set_resource_references(tpl, inputs, resource_reference["children"], child_transversal + [resource_reference.name])


func _on_build_requested(id: int, path: String, args: Dictionary) -> void:
	#print("in the remote_manager#_on_build_requested function")
	#print(args)
	var tpl: Template
	if _peers.has(id):
		tpl = _peers[id]["template"]
	else:
		tpl = Template.new()
		add_child(tpl)
		_peers[id] = {}
		_peers[id]["template"] = tpl

	if tpl._loaded_template_path != path:
		tpl.load_from_file(path)

	if not tpl._template_loaded:
		return

	_set_inspector_values(tpl, args["inspector"])
	# select the first generator in the relevant array
	_set_inputs(tpl, args["generator_payload_data_array"][0])
	_set_resource_references(tpl, args["generator_payload_data_array"][0], args["generator_resources_data_array"][0])

	GlobalEventBus.dispatch("remote_build_started", [id])
	tpl.generate(true)
	yield(tpl, "build_completed")
	GlobalEventBus.dispatch("remote_build_completed", [id, tpl.get_remote_output()])


# Refresh the loaded templates if they were modified
# TODO: what happens when we reload something in the middle of a rebuild?
func _on_template_saved(path: String) -> void:
	for peer in _peers.values():
		var tpl = peer["template"]
		if tpl.get_template_path() == path:
			tpl.load_from_file(path)
