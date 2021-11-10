class_name LoadSaveManager
extends Control

# The dialog manager is the last thing in the scene tree to make sure the
# dialogs are always displayed on top of everything else.
# This is used by the ViewContainer when asking the user to select a template
# on the disk or to confirm they want to close the current tab.

signal cancelled
signal discarded
signal confirmed
signal file_selected


@onready var _overlay: Panel = $BlackOverlay
@onready var _confirm_dialog: ConfirmDialog = $ConfirmDialog
@onready var _file_dialog: SaveLoadDialog = $SaveLoadDialog


func _ready():
	_confirm_dialog.cancelled.connect(_on_confirm_dialog_action.bind(cancelled))
	_confirm_dialog.discarded.connect(_on_confirm_dialog_action.bind(discarded))
	_confirm_dialog.confirmed.connect(_on_confirm_dialog_action.bind(confirmed))
	_confirm_dialog.popup_hide.connect(_hide_overlay)
	_file_dialog.file_selected.connect(_on_file_selected)
	_file_dialog.close_requested.connect(_hide_overlay)
	_file_dialog.cancelled.connect(_hide_overlay)


func show_file_dialog(mode) -> void:
	_show_overlay()
	_file_dialog.dialog_mode = mode
	_file_dialog.show_dialog()


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
	file_selected.emit(file)


func _on_confirm_dialog_action(s: Signal) -> void:
	_hide_overlay()
	s.emit()
