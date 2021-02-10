class_name StringUtil


static func remove_line_breaks(text: String) -> String:
	# Remove line breaks
	text = text.replace("\n", " ")
	# Remove occasional double space caused by the line above
	return text.replace("  ", " ")
