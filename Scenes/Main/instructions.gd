extends Control


func _ready() -> void:
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		get_tree().paused = false
		visible = false
