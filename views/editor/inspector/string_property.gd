extends Control


signal value_changed


var label: Label
var line_edit: LineEdit


func init(name: String, value: String):
	label = get_node("Label")
	label.text = name

	line_edit = get_node("LineEdit")
	line_edit.text = value

	line_edit.connect("text_changed", self, "_on_text_changed")


func set_value(text: String) -> void:
	line_edit.text = text


func get_value(_storage := false) -> String:
	return line_edit.text


func _on_text_changed(_text) -> void:
	emit_signal("value_changed")
