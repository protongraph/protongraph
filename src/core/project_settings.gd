tool
class_name ConceptGraphSettings

"""
Call initialize() to add options in the Project Settings panel. If the option is already there,
it won't erase the existing values.
"""

const MULTITHREAD_ENABLED = "concept_graph/generation/enable_multithreading"
const GENERATION_DELAY = "concept_graph/generation/delay_before_generation"
const INLINE_VECTOR_FIELDS = "concept_graph/user_interface/inline_vector_fields"
const GROUP_NODES_BY_TYPE = "concept_graph/user_interface/group_nodes_by_type"


static func initialize() -> void:
	_clear_old_options()
	_enable_option(MULTITHREAD_ENABLED, TYPE_BOOL, true)
	_enable_option(GENERATION_DELAY, TYPE_REAL, 75, \
		"How long it waits before regenerating the result after an input was changed. (In milliseconds)")
	_enable_option(INLINE_VECTOR_FIELDS, TYPE_BOOL, false)
	_enable_option(GROUP_NODES_BY_TYPE, TYPE_BOOL, false)


static func _clear_old_options() -> void:
	# Old settings names. Clear them to avoid duplication in the ProjectSettings panel
	var old_settings := [
		"concept_graph/enable_multithreading",
		"concept_graph/inline_vector_fields",
	]
	for name in old_settings:
		if ProjectSettings.has_setting(name):
			ProjectSettings.clear(name)


static func _enable_option(name, type, default, hint := "") -> void:
	if ProjectSettings.has_setting(name):
		return

	ProjectSettings.set(name, default)
	var property_info = {
		"name": name,
		"type": type,
		"hint_string": hint
	}
	ProjectSettings.add_property_info(property_info)
