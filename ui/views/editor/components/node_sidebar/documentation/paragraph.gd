class_name Paragraph
extends MarginContainer


onready var _label: Label = $Label


func set_paragraph_text(t: String) -> void:
	_label.text = t
