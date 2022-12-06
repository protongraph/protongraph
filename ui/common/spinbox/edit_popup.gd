extends Popup

signal edit_value_started
signal edit_value_ended
signal edit_value


@export var e100: NodePath
@export var e10: NodePath
@export var e1: NodePath
@export var ep1: NodePath
@export var ep01: NodePath
@export var ep001: NodePath

var delta := 0.0

@onready var label: Label = $VBoxContainer/Label


func _ready():
	size = Vector2.ZERO

	var boxes = []
	boxes.resize(6)

	boxes[0] = get_node(e100)
	boxes[1] = get_node(e10)
	boxes[2] = get_node(e1)
	boxes[3] = get_node(ep1)
	boxes[4] = get_node(ep01)
	boxes[5] = get_node(ep001)

	for box in boxes:
		box.edit_value_started.connect(_on_edit_value_started)
		box.edit_value_ended.connect(_on_edit_value_ended)
		box.edit_value.connect(_on_edit_value)

	about_to_popup.connect(_on_about_to_popup)


func _on_about_to_popup() -> void:
	# Force the popup to always use as little space as possible because the
	# control size flags doesn't work in this case
	size = Vector2.ZERO
	delta = 0.0
	label.text = str(delta)


func _on_edit_value_started() -> void:
	edit_value_started.emit()


func _on_edit_value_ended() -> void:
	edit_value_ended.emit()


func _on_edit_value(step) -> void:
	edit_value.emit(step)
	delta += step
	delta = snapped(delta, 0.001)
	if delta >= 0:
		label.text = "+" + str(delta)
	else:
		label.text = str(delta)
