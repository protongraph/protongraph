tool
extends ConceptNode

"""
DEBUG NODE : Show all input colors at once
"""


func _init() -> void:
	unique_id = "debug_input_options"
	display_name = "Options"
	category = "Debug"
	description = "Show all input colors at once"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_SAVE_FILE,
			"filters": ["*.scn", "*.tscn"]
		}
	}
	set_input(0, "String", ConceptGraphDataType.STRING)
	set_input(1, "File 1", ConceptGraphDataType.STRING, opts)
	set_input(2, "File 2", ConceptGraphDataType.STRING, opts)

