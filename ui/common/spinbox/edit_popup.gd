extends Popup

signal edit_value_started
signal edit_value_ended
signal edit_value


var delta := 0.0

@onready var label: Label = $%Label


func _ready():
	size = Vector2.ZERO

	var boxes = []
	boxes.resize(6)

	boxes[0] = $%e100
	boxes[1] = $%e10
	boxes[2] = $%e1
	boxes[3] = $%ep1
	boxes[4] = $%ep01
	boxes[5] = $%ep001

	for box in boxes:
		box.edit_value_started.connect(_on_edit_value_started)
		box.edit_value_ended.connect(_on_edit_value_ended)
		box.edit_value.connect(_on_edit_value)

	about_to_popup.connect(_on_about_to_popup)


func _on_about_to_popup() -> void:
	# Force the popup to always use as little space as possible because the
	# control size flags don't work in this case
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
