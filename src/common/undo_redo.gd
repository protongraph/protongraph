extends Node


var undo_redo: UndoRedo


func _ready() -> void:
	undo_redo = get_undo_redo()


func get_undo_redo() -> UndoRedo:
	if not undo_redo:
		undo_redo = UndoRedo.new()
	print("In get undo redo ", undo_redo)
	return undo_redo
