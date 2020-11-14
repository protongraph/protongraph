extends HBoxContainer

signal edit_value_started
signal edit_value_ended
signal edit_value


export var step: float

var _label
var _clicked := false
var _acc := 0.0


func _ready():
	_label = get_node("PanelContainer/Label")
	_label.text = String(step)


func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_clicked = event.pressed
		_acc = 0.0
		if _clicked:
			emit_signal("edit_value_started")
		else:
			emit_signal("edit_value_ended")

	elif event is InputEventMouseMotion and _clicked:
		if sign(_acc) != sign(event.relative.x):
			_acc = 0.0

		_acc += event.relative.x
		if abs(_acc) >= 5 * EditorUtil.get_editor_scale():
			emit_signal("edit_value", sign(_acc) * step)
			_acc = 0.0


func _on_increase_button_pressed():
	emit_signal("edit_value", step)


func _on_decrease_button_pressed():
	emit_signal("edit_value", -step)
