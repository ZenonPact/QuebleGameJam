extends CharacterBody3D


@export var pen: CSGCylinder3D
@export var player: CharacterBody3D
@export var flee_distance := 10.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var baaa: AudioStreamPlayer3D = $Baaa


const SPEED = 7.5

var next_position: Vector3
var direction: Vector3
var distance: float
var target_position: Vector3
var is_fleeing := false



func _physics_process(delta: float) -> void:
	distance = global_position.distance_to(player.global_position)

	if player.is_barking == true and distance <= player.barking_aoe_size:
		var flee_direction = (global_position - player.global_position).normalized()
		var target_position = global_position + flee_direction * flee_distance
		navigation_agent_3d.target_position = target_position
	
	if navigation_agent_3d.is_navigation_finished():
		direction = Vector3.ZERO
	else:
		animation_player.play("walking")
		next_position = navigation_agent_3d.get_next_path_position()
		direction = global_position.direction_to(next_position)
		if is_on_wall():
			navigation_agent_3d.target_position = global_position
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if direction.length() > 0.01:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func look_at_target(pen_direction: Vector3) -> void:
	var adjusted_direction := pen_direction
	adjusted_direction.y = 0

	var look_transform = global_transform.looking_at(global_position + adjusted_direction, Vector3.UP, true)
	var cur_quat = global_transform.basis.get_rotation_quaternion()
	var target_quat = look_transform.basis.get_rotation_quaternion()
	var final_quat = cur_quat.slerp(target_quat, 0.1)
	global_transform.basis = Basis(final_quat)
