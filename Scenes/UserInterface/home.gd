extends Control


func start_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/main_level.tscn")


func quit_game() -> void:
	get_tree().quit()
