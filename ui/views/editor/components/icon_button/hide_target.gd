extends Button


export var target: NodePath

var _target


func _ready():
	_target = get_node(target)
	Signals.safe_connect(self, "pressed", self, "_on_pressed")
	

func _on_pressed() -> void:
	if _target:
		_target.visible = !_target.visible
