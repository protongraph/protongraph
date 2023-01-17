extends Button
class_name HistoryFileEntry


var _path

@onready var _label_name: Label = $%FileNameLabel
@onready var _label_path: Label = $%FilePathLabel
@onready var _close_button: Button = $%CloseButton
@onready var _margin_container: MarginContainer = $%MarginContainer


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

	_close_button.pressed.connect(_on_close_button_pressed)
	_close_button.visible = false

	# Workaround because button isn't a container so it doesn't scale to fit
	# its children automatically.
	custom_minimum_size.y = _margin_container.size.y


func set_path(path: String) -> void:
	_path = path
	_label_name.text = path.get_file()
	_label_path.text = path


func _shorten_path(path: String) -> String:
	var max_path_length := 120
	if path.length() < max_path_length:
		return path

	var tokens = path.split("/", false)
	var total_size = path.length()

	while total_size > max_path_length and tokens.size() > 3:
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
	GlobalEventBus.load_graph.emit(_path)


func _on_close_button_pressed() -> void:
	GlobalEventBus.remove_from_file_history.emit(_path)
