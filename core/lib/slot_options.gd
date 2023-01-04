class_name SlotOptions
extends RefCounted


# Options that can be passed when creating a new input. The UI can use these
# value when generating the appropriate controls.
#
# It's not guaranteed that a flag will be accounted for in every situation though,
# this is only for autocompletion and early error detection.


# Generic options
var show_type_icon := true
var value: Variant

# Scaling options
var expand := false
var compact_display := false

# Number options
var step: int = 1
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

# Spinbox options
var rounded := false

# String options
class DropdownItem:
	var label: String
	var id: int

var dropdown_items: Array[DropdownItem]
var placeholder := "Text"

# File options
class DialogOptions:
	var mode: FileDialog.FileMode
	var filters: PackedStringArray

var dialog_options: DialogOptions = null

# Custom UI
var custom_ui: Control


# Helper methods
func get_default_value(default = null) -> Variant:
	if value != null:
		return value
	return default


func get_vector_index_options(index: String) -> SlotOptions:
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


func has_dropdown() -> bool:
	return not dropdown_items.is_empty()


func add_dropdown_item(id, label: String) -> void:
	var item = DropdownItem.new()
	item.id = id
	item.label = label
	dropdown_items.push_back(item)
	show_type_icon = false
