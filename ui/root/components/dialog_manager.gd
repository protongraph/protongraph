class_name DialogManager
extends Control

# The dialog manager is the last thing in the scene tree to make sure the
# dialogs are always displayed on top of everything else.
# This is used by the ViewContainer when asking the user to select a template
# on the disk or to confirm they want to close the current tab.

# warning-ignore-all:UNUSED_SIGNAL
signal canceled
signal discarded
signal confirmed
signal file_selected


onready var _overlay: Panel = $BlackOverlay
onready var _confirm_dialog: ConfirmDialog = $ConfirmDialog
onready var _file_dialog: LoadSaveDialog = $FileDialog


func _ready():
	Signals.safe_connect(_confirm_dialog, "canceled", self, "_on_confirm_dialog_action", ["canceled"])
	Signals.safe_connect(_confirm_dialog, "discarded", self, "_on_confirm_dialog_action", ["discarded"])
	Signals.safe_connect(_confirm_dialog, "confirmed", self, "_on_confirm_dialog_action", ["confirmed"])
	Signals.safe_connect(_confirm_dialog, "popup_hide", self, "_hide_overlay")
	Signals.safe_connect(_file_dialog, "file_selected", self, "_on_file_selected")
	Signals.safe_connect(_file_dialog, "popup_hide", self, "_hide_overlay")


func show_file_dialog(type) -> void:
	_show_overlay()
	match type:
		Constants.LOAD:
			_file_dialog.load_template()
		Constants.CREATE:
			_file_dialog.create_template()
		Constants.SAVE_AS:
			_file_dialog.save_template_as()


func show_confirm_dialog() -> void:
	_show_overlay()
	_confirm_dialog.popup_centered()


func _show_overlay() -> void:
	_overlay.visible = true


func _hide_overlay() -> void:
	_overlay.visible = false


func _on_show_confirm_dialog() -> void:
	_show_overlay()
	_confirm_dialog.popup_centered()


func _on_file_selected(file) -> void:
	_hide_overlay()
	emit_signal("file_selected", file)


func _on_confirm_dialog_action(s: String) -> void:
	_hide_overlay()
	emit_signal(s)
