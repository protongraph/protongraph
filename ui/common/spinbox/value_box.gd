extends HBoxContainer

signal edit_value_started
signal edit_value_ended
signal edit_value


@export var step: float

var _clicked := false
var _acc := 0.0

@onready var _label: Label = $PanelContainer/Label


func _ready():
	_label.text = str(step)


func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_clicked = event.pressed
		_acc = 0.0
		if _clicked:
			edit_value_started.emit()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			edit_value_ended.emit()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	elif event is InputEventMouseMotion and _clicked:
		if sign(_acc) != sign(event.relative.x):
			_acc = 0.0

		_acc += event.relative.x
		if abs(_acc) >= 5 * EditorUtil.get_editor_scale():
			edit_value.emit(sign(_acc) * step)
			_acc = 0.0


func _on_increase_button_pressed():
	edit_value.emit(step)


func _on_decrease_button_pressed():
	edit_value.emit(-step)
