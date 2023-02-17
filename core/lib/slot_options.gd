class_name SlotOptions
extends RefCounted


# Options that can be passed when creating a new input. The UI can use these
# value when generating the appropriate controls.
#
# It's not guaranteed that a flag will be accounted for in every situation though,
# this is mostly for autocompletion and early error detection.

func _init(val = null):
	if val:
		value = val


# Generic options
var value: Variant
var show_type_icon := true
var label_override := ""
var ignored := false

# Connections options
var allow_multiple_connections := false

# Scaling options
var expand := true
var compact_display := false

# Number options
var step: float = 1
var min_value: float = 0.0
var max_value: float = 100.0
var allow_lesser := true
var allow_greater := true
var exp_edit := false

# Vector options
var vec_x: SlotOptions
var vec_y: SlotOptions
var vec_z: SlotOptions
var vec_w: SlotOptions
var force_vertical := false

# Spinbox options
var rounded := false

# String options
class DropdownItem:
	var label: String
	var id: int

var dropdown_items: Array[DropdownItem]
var placeholder := "Text"

# File options
var is_file := false
var file_mode: FileDialog.FileMode
var file_filters: PackedStringArray

# Custom UI
var custom_ui: Control


# Helper methods
func get_default_value(default = null) -> Variant:
	if value != null:
		return value
	return default


func get_vector_options(index: String) -> SlotOptions:
	match index:
		"x":
			if vec_x != null:
				return vec_x
		"y":
			if vec_y != null:
				return vec_y
		"z":
			if vec_z != null:
				return vec_z
		"w":
			if vec_w != null:
				return vec_w
	return self


func override_vector_options_with_current() -> void:
	var copy = get_copy()
	vec_x = copy.get_copy()
	vec_y = copy.get_copy()
	vec_z = copy.get_copy()
	vec_w = copy.get_copy()


func has_dropdown() -> bool:
	return not dropdown_items.is_empty()


func add_dropdown_item(id, label: String) -> void:
	var item = DropdownItem.new()
	item.id = id
	item.label = label
	dropdown_items.push_back(item)
	show_type_icon = false


func get_copy() -> SlotOptions:
	var copy = SlotOptions.new()

	var p_value: Variant
	for property in get_property_list():
		p_value = get(property.name)
		copy.set(property.name, p_value)

	return copy
