class_name DocumentationPanel
extends VBoxContainer


func _ready():
	pass


func clear():
	NodeUtil.remove_children(self)


func rebuild(doc: NodeDocumentation) -> void:
	clear()
	
	# Create warnings
	
	# Create parameters doc
	for p in doc.get_parameters():
		var ui = preload("parameter.tscn").instance()
		add_child(ui)
		ui.set_parameter_name(p["name"])
		ui.set_parameter_description(p["text"])
		ui.set_parameter_cost(p["cost"])

	
	# Create additional paragraphs
