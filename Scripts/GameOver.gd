extends Control


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
