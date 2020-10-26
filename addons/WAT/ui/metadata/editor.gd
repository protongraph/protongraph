tool
extends EditorInspectorPlugin

func _enter_tree() -> void:
	add_setting()
	
func add_setting() -> void:
	if ProjectSettings.has_setting("WAT/Tags"):
		return
	var tags: PoolStringArray = []
	var property_info: Dictionary = {
		"name": "WAT/Tags",
		"type": TYPE_STRING_ARRAY,
		"hint_string": "Defines Tags to group Tests"
	}
	ProjectSettings.set("WAT/Tags", tags)
	ProjectSettings.add_property_info(property_info)

func can_handle(object):
	if object is GDScript and object.get("TEST"):
		add_property_editor_for_multiple_properties("Tags", [], TagList.new(object))
		return true
		
class TagList extends EditorProperty:
	
	const Metadata: PackedScene = preload("res://addons/WAT/ui/metadata/Metadata.tscn")
	var metadata: Control = Metadata.instance()
	var test: Script
	
	func _init(_test: Script) -> void:
		test = _test
		metadata.test = _test
		add_child(metadata)
		set_bottom_editor(metadata)
		
		
