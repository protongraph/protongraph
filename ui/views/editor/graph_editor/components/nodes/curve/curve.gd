class_name CurveComponent
extends GraphNodeUiComponent


const CurveEditorScene := preload("./curve_editor.tscn")


var _editor: CurveEditor


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	var col := VBoxContainer.new()
	add_child(col)

	var header_box := HBoxContainer.new()
	header_box.add_child(icon_container)
	header_box.add_child(label)
	col.add_child(header_box)

	_editor = CurveEditorScene.instantiate()
	col.add_child(_editor)

	if opts.value is Curve:
		_editor.set_curve(opts.value)
	else:
		var default_curve = Curve.new()
		default_curve.add_point(Vector2.ZERO)
		default_curve.add_point(Vector2.ONE)
		_editor.set_curve(default_curve)

	_editor.curve_changed.connect(_on_value_changed)



func get_value() -> Curve:
	return _editor.get_curve()


func set_value(value: Curve) -> void:
	_editor.set_curve(value)


func notify_connection_changed(connected: bool) -> void:
	_editor.visible = !connected


func _on_value_changed(val: Curve) -> void:
	super(val)
