extends Node


var undo_redo: UndoRedo


func _ready() -> void:
	undo_redo = get_undo_redo()


func get_undo_redo() -> UndoRedo:
	if not undo_redo:
		undo_redo = UndoRedo.new()
	return undo_redo


func _input(_event: InputEvent) -> void:
	# The order matters because of how the shortcuts are defined
	if Input.is_action_just_released("redo"):
		undo_redo.redo()
	elif Input.is_action_just_released("undo"):
		undo_redo.undo()


# warning-ignore-all:return_value_discarded
