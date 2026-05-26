extends CharacterBody3D


const SPEED = 7.0

@export var barking_aoe_size := 5.0
@export var rotation_speed := 5

@onready var barking_aoe: MeshInstance3D = $BarkingAoe
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barking_sound: AudioStreamPlayer3D = $BarkingSound

var is_barking := false
var aoe: CylinderMesh

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("bark"):
		barking_sound.play()
		is_barking = true
	else:
		is_barking = false

func _ready() -> void:
	barking_aoe.mesh.top_radius = barking_aoe_size - 1
	barking_aoe.mesh.bottom_radius = barking_aoe_size - 1


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := ( Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		animation_player.play("walk")
		var target_angle = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
