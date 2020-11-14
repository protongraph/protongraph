extends WindowDialog
class_name ConfirmDialog

# Generic confirmation dialog with three buttons (Cancel, Discard, Confirm)


signal canceled
signal discarded
signal confirmed


onready var _label: Label = $MarginContainer/VBoxContainer/Label
onready var _cancel: Button = $MarginContainer/VBoxContainer/HBoxContainer/Cancel
onready var _discard: Button = $MarginContainer/VBoxContainer/HBoxContainer/Discard
onready var _confirm: Button = $MarginContainer/VBoxContainer/HBoxContainer/Confirm


func _ready() -> void:
	rect_min_size *= EditorUtil.get_editor_scale()
	Signals.safe_connect(self, "popup_hide", self, "_on_cancel")
	Signals.safe_connect(_cancel, "pressed", self, "_on_cancel")
	Signals.safe_connect(_discard, "pressed", self, "_on_discard")
	Signals.safe_connect(_confirm, "pressed", self, "_on_confirm")
	

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
	emit_signal("canceled")
	hide()


func _on_discard() -> void:
	emit_signal("discarded")
	hide()


func _on_confirm() -> void:
	emit_signal("confirmed")
	hide()
