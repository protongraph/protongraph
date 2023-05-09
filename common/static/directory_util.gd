class_name DirectoryUtil
extends RefCounted


static func get_all_files_in(path: String, recursive := false) -> Array[String]:
	var files: Array[String] = []

	var dir := DirAccess.open(path)
	if not dir:
		printerr("Could not open ", path)
		return files

	dir.include_hidden = false
	dir.include_navigational = false
	dir.list_dir_begin()

	while true:
		var file := dir.get_next()
		var file_path := path.path_join(file)

		if file == "":
			break

		if not dir.current_is_dir():
			files.push_back(file_path)

		elif recursive: # Search files in the newly found folder
			files.append_array(get_all_files_in(file_path, recursive))

	dir.list_dir_end()

	return files


static func get_all_valid_scripts_in(path: String, recursive := false) -> Array[GDScript]:
	var files := get_all_files_in(path, recursive)
	var scripts: Array[GDScript] = []

	for file in files:
		if not file.ends_with(".gd") and not file.ends_with(".gdc"):
			continue

		var script := load(file)
		if script == null:
			print("Error: Failed to load script ", file)
			continue

		scripts.push_back(script)

	return scripts
