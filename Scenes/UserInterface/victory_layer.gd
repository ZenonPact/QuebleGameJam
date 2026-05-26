extends Control


var timer := 0.0

@export var gate: Area3D

@onready var star_1: TextureRect = %Star1
@onready var star_2: TextureRect = %Star2
@onready var star_3: TextureRect = %Star3
@onready var one_survived_label: Label = %OneSurvivedLabel
@onready var all_survived_label: Label = %AllSurvivedLabel
@onready var on_time_label: Label = %OnTimeLabel
@onready var victory_label: Label = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/VictoryLabel
@onready var next_level_button: Button = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/VBoxContainer/NextLevelButton


func _process(delta: float) -> void:
	timer += delta
	var sheep_remaining = get_tree().get_nodes_in_group("sheeps")
	if sheep_remaining.size() == 0:
		if timer < 120 and gate.score >= 5:
			star_3.modulate = Color.WHITE
			on_time_label.visible = true
		elif gate.score >= 1 and gate.score < 5:
			star_1.modulate = Color.WHITE
			one_survived_label.visible = true
		elif gate.score >= 5:
			star_2.modulate = Color.WHITE
			all_survived_label.visible = true
		elif gate.score == 0:
			victory_label.text = "Defeat"
			one_survived_label.text = "All sheeps died :(, try again"
			one_survived_label.visible = true
		if get_tree().current_scene.scene_file_path == "res://Scenes/Main/main_level.tscn":
			next_level_button.visible = true
		elif get_tree().current_scene.scene_file_path == "res://Scenes/Main/level2.tscn":
			next_level_button.text = "Main Menu"
			next_level_button.visible = true
		visible = true
		get_tree().paused = true

func restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func exit_game() -> void:
	get_tree().quit()


func next_level() -> void:
	get_tree().paused = false
	if get_tree().current_scene.scene_file_path == "res://Scenes/Main/main_level.tscn":
		get_tree().change_scene_to_file("res://Scenes/Main/level2.tscn")
	elif get_tree().current_scene.scene_file_path == "res://Scenes/Main/level2.tscn":
		get_tree().change_scene_to_file("res://Scenes/UserInterface/home.tscn")
