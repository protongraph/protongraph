class_name DocumentationPanel
extends VBoxContainer


func clear():
	NodeUtil.remove_children(self)


func rebuild(doc: NodeDocumentation) -> void:
	clear()

	# Create warnings
	for w in doc.get_warnings():
		var ui = preload("warning.tscn").instance()
		add_child(ui)
		ui.set_warning_text(w["text"])
		ui.set_warning_level(w["level"])

	add_child(VSeparator.new())

	# Create additional paragraphs
	for p in doc.get_paragraphs():
		var ui = preload("paragraph.tscn").instance()
		add_child(ui)
		ui.set_paragraph_text(p["text"])

	add_child(VSeparator.new())

	# Create parameters doc
	for p in doc.get_parameters():
		var ui = preload("parameter.tscn").instance()
		add_child(ui)
		ui.set_parameter_name(p["name"])
		ui.set_parameter_description(p["text"])
		ui.set_parameter_cost(p["cost"])
