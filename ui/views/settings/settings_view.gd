class_name SettingsView
extends Node


const ParametersViewScene := preload("./components/parameters_view.tscn")


@onready var _tabs: Control = $%TabRoot
@onready var _tab_container: Control = $%TabContainer


func _ready():
	for setting in Settings.get_list():
		var panel: SettingsParametersView = _get_or_create_category(setting.category)[1]
		panel.add_parameter(setting)

	if _tabs.get_child_count() > 0:
		_tabs.get_child(0).button_pressed = 1


func _get_or_create_category(category: String) -> Array:
	var button: Button
	var panel: SettingsParametersView

	if not _tabs.has_node(category):
		# Button setup
		button = Button.new()
		button.toggle_mode = true
		button.text = category.capitalize()
		button.name = category
		_tabs.add_child(button, true)

		# Panel setup
		panel = ParametersViewScene.instantiate()
		panel.name = category
		_tab_container.add_child(panel)

		button.toggled.connect(_on_tab_toggled.bind(panel))
	else:
		button = _tabs.get_node(category)
		panel = _tab_container.get_node(category)

	return [button, panel]


func _on_tab_toggled(enabled: bool, panel: Control) -> void:
	if enabled:
		for c in _tab_container.get_children():
			c.visible = false

		panel.visible = true
