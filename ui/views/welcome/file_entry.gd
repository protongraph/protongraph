extends Button
class_name HistoryFileEntry

var _path

onready var _label_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/Name
onready var _label_path: Label = $MarginContainer/VBoxContainer/Path
onready var _close_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/CloseButton
onready var _margin_container: MarginContainer = $MarginContainer


func _ready():
	# Workaround because button isn't a container so it doesn't scale to fit
	# its children automatically.
	rect_min_size.y = _margin_container.rect_size.y

	Signals.safe_connect(self, "mouse_entered", self, "_on_mouse_entered")
	Signals.safe_connect(self, "mouse_exited", self, "_on_mouse_exited")
	Signals.safe_connect(self, "pressed", self, "_on_pressed")
	Signals.safe_connect(_close_button, "pressed", self, "_on_close_button_pressed")


func set_path(path: String) -> void:
	_path = path
	_label_name.text = path.get_file()
	_label_path.text = path


func _shorten_path(path: String) -> String:
	if path.length() < 80:
		return path

	var tokens = path.split("/", false)
	var total_size = path.length()

	while total_size > 80 and tokens.size() > 4:
		tokens.remove(2)
		total_size = tokens.size()
		for token in tokens:
			total_size += token.length()

	tokens.insert(2, "...")
	var res = ""

	for token in tokens:
		res += "/" + token
	return res


func _on_mouse_entered():
	_close_button.visible = true


func _on_mouse_exited():
	_close_button.visible = false


func _on_pressed() -> void:
	GlobalEventBus.dispatch("load_template", _path)


func _on_close_button_pressed() -> void:
	GlobalEventBus.dispatch("remove_from_file_history", _path)
