extends ProtonNode


func _init() -> void:
	type_id = "comment"
	title = "Comment"
	category = "Helpers"
	description = "Insert a comment in the graph editor"
	comment = true

	var opts := SlotOptions.new()
	opts.accept_connections = false
	opts.show_header = false
	create_input("comment", "", DataType.STRING, opts)
