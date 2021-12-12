class_name ConfirmDialog
extends Popup

# Generic confirmation dialog with three buttons (Cancel, Discard, Confirm)

signal cancelled
signal discarded
signal confirmed


@onready var _label: Label = $MarginContainer/VBoxContainer/Label
@onready var _cancel: Button = $MarginContainer/VBoxContainer/HBoxContainer/Cancel
@onready var _discard: Button = $MarginContainer/VBoxContainer/HBoxContainer/Discard
@onready var _confirm: Button = $MarginContainer/VBoxContainer/HBoxContainer/Confirm


func _ready() -> void:
	min_size *= EditorUtil.get_editor_scale()
	popup_hide.connect(_on_cancel)
	_cancel.connect("pressed", _on_cancel)
	_discard.connect("pressed", _on_discard)
	_confirm.connect("pressed", _on_confirm)


func set_text(text: String) -> void:
	_label.text = text


func set_cancel_text(text: String) -> void:
	_cancel.text = text


func set_discard_text(text: String) -> void:
	_discard.text = text


func set_confirm_text(text: String) -> void:
	_confirm.text = text


func hide() -> void:
	visible = false


func _on_cancel() -> void:
	cancelled.emit()
	hide()


func _on_discard() -> void:
	discarded.emit()
	hide()


func _on_confirm() -> void:
	confirmed.emit()
	hide()
