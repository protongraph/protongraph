extends Popup

signal edit_value_started
signal edit_value_ended
signal edit_value


export var e100: NodePath
export var e10: NodePath
export var e1: NodePath
export var ep1: NodePath
export var ep01: NodePath
export var ep001: NodePath


func _ready():
	rect_size = Vector2.ZERO
	
	var boxes = []
	boxes.resize(6)
	
	boxes[0] = get_node(e100)
	boxes[1] = get_node(e10)
	boxes[2] = get_node(e1)
	boxes[3] = get_node(ep1)
	boxes[4] = get_node(ep01)
	boxes[5] = get_node(ep001)
	
	for box in boxes:
		Signals.safe_connect(box, "edit_value_started", self, "_on_edit_value_started")
		Signals.safe_connect(box, "edit_value_ended", self, "_on_edit_value_ended")
		Signals.safe_connect(box, "edit_value", self, "_on_edit_value")


func popup(bounds := Rect2(0, 0, 0, 0)) -> void:
	# Force the popup to always use as little space as possible because the 
	# control size flags doesn't work in this case
	rect_size = Vector2.ZERO
	.popup(bounds)


func _on_edit_value_started() -> void:
	emit_signal("edit_value_started")


func _on_edit_value_ended() -> void:
	emit_signal("edit_value_ended")


func _on_edit_value(step) -> void:
	emit_signal("edit_value", step)
