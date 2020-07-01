extends Node


var undo_redo: UndoRedo


func _ready() -> void:
	undo_redo = get_undo_redo()


func get_undo_redo() -> UndoRedo:
	if not undo_redo:
		undo_redo = UndoRedo.new()
	return undo_redo
