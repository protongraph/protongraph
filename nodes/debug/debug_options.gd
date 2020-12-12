tool
extends ProtonNode

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
	set_input(0, "String", DataType.STRING)
	set_input(1, "File 1", DataType.STRING, opts)
	set_input(2, "File 2", DataType.STRING, opts)

	doc.add_warning("Test warning default")
	doc.add_warning("Test warning moderate", {"level": 1})
	doc.add_warning("Test warning high", {"level": 2})
	
	doc.add_parameter("String", "Some random description of what this does")
	doc.add_parameter("File 1", "Some random description of what this does", {"cost": 2})
	doc.add_parameter("File 2", 
		"""Some random description of what this does but this time longer
		and on multiple lines.""", {"cost": 3})
	
	doc.add_paragraph("""This is a boring paragraph and I don't know how it
		should be displayed on screen. Line returns and tabs inside the 
		string will be ignored. Add another paragraph if you want to force
		a line break.""")
