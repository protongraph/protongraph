class_name ConfirmDialog
extends Popup

# Generic confirmation dialog with three buttons (Cancel, Discard, Confirm)

signal cancelled
signal discarded
signal confirmed


@onready var _label: Label = $%Label
@onready var _cancel: Button = $%Cancel
@onready var _discard: Button = $%Discard
@onready var _confirm: Button = $%Confirm


func _ready() -> void:
	min_size *= EditorUtil.get_editor_scale()
	popup_hide.connect(_on_button_pressed.bind(cancelled))
	_cancel.pressed.connect(_on_button_pressed.bind(cancelled))
	_discard.pressed.connect(_on_button_pressed.bind(discarded))
	_confirm.pressed.connect(_on_button_pressed.bind(confirmed))


func set_text(text: String) -> void:
	_label.text = text


func set_cancel_text(text: String) -> void:
	_cancel.text = text


func set_discard_text(text: String) -> void:
	_discard.text = text


func set_confirm_text(text: String) -> void:
	_confirm.text = text


func _on_button_pressed(s: Signal) -> void:
	s.emit()
	hide()
