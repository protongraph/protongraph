extends PanelContainer
class_name UserInterfaceRoot


export var view_container: NodePath

var _view_container: ViewContainer
var _is_quitting := false


func _ready() -> void:
	# Prevent the application to close automatically
	get_tree().set_auto_accept_quit(false)
	GlobalEventBus.register_listener(self, "quit", "_quit")

	# Scale the theme according to the editor scale (for high dpi screens)
	theme = EditorUtil.get_scaled_theme(theme)
	EditorUtil.scale_all_ui_resources()
	update()

	_view_container = get_node(view_container)
	Signals.safe_connect(_view_container, "ready_to_quit", self, "_on_ready_to_quit")
	Signals.safe_connect(_view_container, "quit_canceled", self, "_on_quit_canceled")


func _notification(event):
	if (event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		_quit()


func _quit() -> void:
	_is_quitting = true
	_view_container.save_all_and_close()


func _on_ready_to_quit() -> void:
	get_tree().quit()


func _on_quit_canceled() -> void:
	_is_quitting = false
