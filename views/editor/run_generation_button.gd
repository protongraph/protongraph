extends Button

export var normal_icon: Texture
export var animated_icon: Texture


func _on_simulation_started() -> void:
	icon = animated_icon


func _on_simulation_completed() -> void:
	icon = normal_icon
