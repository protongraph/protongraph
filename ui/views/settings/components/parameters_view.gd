class_name SettingsParametersView
extends Control


const ParameterScene := preload("./parameter.tscn")


@onready var _root: VBoxContainer = $%ParameterRoot


func clear() -> void:
	NodeUtil.remove_children(_root)


func add_parameter(setting: Dictionary) -> void:
	var p := ParameterScene.instantiate()
	_root.add_child(p)

	p.set_title(setting.title)
	p.set_description(setting.description)

	var value = Settings.get_setting(setting)

	if value is bool:
		p.mark_as_bool()
		p.set_value(value)

	else:
		p.mark_as_float()
		p.set_value(value)

	p.value_changed.connect(_on_value_changed.bind(setting))


func _on_value_changed(value, setting) -> void:
	Settings.update_setting(setting, value)

