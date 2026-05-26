extends Node3D


@export var target_player: CharacterBody3D
@export var deadzone_radius := 2.0
@export var follow_speed := 5.0


func _physics_process(delta: float) -> void:
	if not target_player:
		return
	
	var target_position = target_player.global_position
	var current_position = global_position
	
	var distance_to_player: Vector2 = Vector2(target_position.x - position.x, target_position.z - position.z)
	
	if distance_to_player.length() > deadzone_radius:
		var target_vector = distance_to_player.normalized() * (distance_to_player.length() - deadzone_radius)
		var move_to = global_position + Vector3(target_vector.x, 0, target_vector.y)
		global_position = global_position.lerp(move_to, follow_speed * delta)
