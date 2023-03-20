class_name TexturePreviewComponent
extends GraphNodeUiComponent


const TexturePreviewUiScene := preload("./texture_preview_ui.tscn")


var _preview: TexturePreviewUi


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	_preview = TexturePreviewUiScene.instantiate()
	add_child(_preview)


func get_value():
	return null


func set_value(value: Variant) -> void:
	if value is Array and not value.is_empty():
		value = value[0]

	_preview.show_preview_for(value)
