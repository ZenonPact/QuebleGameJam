extends PathFollow3D


var direction := 1
var attack_timer := 0.0
var attack_duration := 1.0
var target_rotation := 0.0

@export var patrol_speed := 4.0
@export var chase_speed := 8.0
@export var detection_range := 10
@export var attack_range := 1.5

@onready var aggro_aoe: MeshInstance3D = $AggroAoe
@onready var attack_sound: AudioStreamPlayer3D = $AttackSound

enum State { PATROLLING, CHASING, ATTACKING, RETURNING }
var current_state = State.PATROLLING
var target_sheep: CharacterBody3D = null
var patrol_position_when_left: float = 0.0  # Remember where we left the path


func _ready() -> void:
	aggro_aoe.mesh.top_radius = detection_range
	aggro_aoe.mesh.bottom_radius = detection_range



func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROLLING:
			patrol(delta)
			check_for_sheep()
		
		State.CHASING:
			chase_sheep(delta)
		
		State.ATTACKING:
			attack_sheep(delta)
		
		State.RETURNING:
			return_to_patrol(delta)

func patrol(delta: float) -> void:
	progress += patrol_speed * delta * direction
	# Loop the path

	if progress_ratio >= 1.0:
		use_model_front = true
		direction = -1
	elif progress_ratio <= 0:
		direction = 1
		use_model_front = false



func check_for_sheep() -> void:
	# Get all sheep in the scene - adjust this to however you're managing sheep
	var sheep_group = get_tree().get_nodes_in_group("sheeps")
	
	for sheep in sheep_group:
		var distance = global_position.distance_to(sheep.global_position)
		if distance <= detection_range:
			attack_sound.play()
			# Found a sheep!
			target_sheep = sheep
			patrol_position_when_left = progress
			current_state = State.CHASING
			break

func chase_sheep(delta: float) -> void:
	if not is_instance_valid(target_sheep):
		# Sheep disappeared (maybe already eaten)
		current_state = State.RETURNING
		return
	

	var distance = global_position.distance_to(target_sheep.global_position)
	
	if distance <= attack_range:
		target_sheep.baaa.play()
		target_sheep.visible = false
		attack_timer = attack_duration
		current_state = State.ATTACKING
	else:
		# Move toward sheep
		var direction = global_position.direction_to(target_sheep.global_position)
		global_position += direction * chase_speed * delta
		
		# Make wolf look at sheep
		look_at(target_sheep.global_position, Vector3.UP)

func attack_sheep(delta: float) -> void:
	attack_timer -= delta
	if attack_timer <= 0:
		if is_instance_valid(target_sheep):
			# Kill the sheep
			target_sheep.queue_free()  # Or call a death function on the sheep
		
		target_sheep = null
		current_state = State.RETURNING

func return_to_patrol(delta: float) -> void:
	# Find closest point on path
	var closest_offset = get_closest_offset_on_path()
	
	var distance_to_path = global_position.distance_to(get_parent().curve.sample_baked(closest_offset))
	
	if distance_to_path < 0.5:
		# Back on path
		progress = closest_offset
		current_state = State.PATROLLING
	else:
		# Move back toward path
		var path_point = get_parent().curve.sample_baked(closest_offset)
		var direction = global_position.direction_to(path_point)
		global_position += direction * patrol_speed * delta
		look_at(global_position + direction * patrol_speed * delta, Vector3.UP)

func get_closest_offset_on_path() -> float:
	var path: Path3D = get_parent()
	var curve = path.curve
	
	# Sample the curve to find closest point
	var closest_offset = 0.0
	var closest_distance = INF
	var sample_count = 20
	
	for i in range(sample_count + 1):
		var offset = (curve.get_baked_length() / sample_count) * i
		var point = curve.sample_baked(offset)
		var distance = global_position.distance_to(point)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_offset = offset
	
	return closest_offset
