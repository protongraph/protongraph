class_name UnsavedChangesConfirmDialog
extends Popup

# Generic confirmation dialog with three buttons (Cancel, Discard, Confirm)

signal canceled
signal discarded
signal confirmed


var _graph: NodeGraph
var _button_clicked := false

@onready var _label: Label = $%Label
@onready var _file_label: Label = $%FileNameLabel
@onready var _cancel: Button = $%Cancel
@onready var _discard: Button = $%Discard
@onready var _confirm: Button = $%Confirm


func _ready() -> void:
	min_size *= EditorUtil.get_editor_scale()
	popup_hide.connect(_on_popup_hide)
	_cancel.pressed.connect(_on_button_pressed.bind(canceled))
	_discard.pressed.connect(_on_button_pressed.bind(discarded))
	_confirm.pressed.connect(_on_button_pressed.bind(confirmed))


func show_for(graph: NodeGraph) -> void:
	_graph = graph
	_file_label.text = graph.save_file_path.get_file()
	popup_centered()


func set_text(text: String) -> void:
	_label.text = text


func set_cancel_text(text: String) -> void:
	_cancel.text = text


func set_discard_text(text: String) -> void:
	_discard.text = text


func set_confirm_text(text: String) -> void:
	_confirm.text = text


func _on_button_pressed(s: Signal) -> void:
	_button_clicked = true
	s.emit(_graph)
	hide()


# Called either when the user clicks outside the popup, or when calling the hide()
# method after clicking any button.
# We only want the canceled signal in the first case.
func _on_popup_hide() -> void:
	if not _button_clicked:
		canceled.emit(_graph)

	_button_clicked = false
