tool
class_name ConceptGraphSettings

"""
Call initialize() to add options in the Project Settings panel. If the option is already there,
it won't erase the existing values.
"""

const MULTITHREAD_ENABLED = "concept_graph/enable_multithreading"


static func initialize() -> void:
	_enable_multithreading_option()
	# Add a new function here for every option we may need


static func _enable_multithreading_option() -> void:
	if ProjectSettings.has_setting(MULTITHREAD_ENABLED):
		return

	ProjectSettings.set(MULTITHREAD_ENABLED, true)
	var property_info = {
		"name": MULTITHREAD_ENABLED,
		"type": TYPE_BOOL,
	}
	ProjectSettings.add_property_info(property_info)
