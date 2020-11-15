extends Node

# Listen for remote requests and run the builds locally before sending back
# the results.

var templates := {}


func _ready():
	GlobalEventBus.register_listener(self, "build_requested", "_on_build_requested")


func _on_build_requested(id: int, path: String, args: Array) -> void:
	var tpl: Template
	if templates.has(id):
		tpl = templates[id]
	else:
		tpl = Template.new()
		templates[id] = tpl
	
	if tpl._loaded_template_path != path:
		tpl.load_from_file(path)
	
	tpl.generate(true)
	yield(tpl, "build_completed")
	
	GlobalEventBus.dispatch("remote_build_complete", [id, tpl.get_remote_output()])
