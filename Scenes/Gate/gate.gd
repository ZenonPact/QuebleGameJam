extends Area3D


@export var invisible_sheeps: Node3D

var score := 0


func _on_body_entered(body: Node3D) -> void:
	score += 1
	if body.is_in_group("sheeps"):
		body.baaa.play()
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(body):
			body.queue_free()
	
		for sheep in invisible_sheeps.get_children():
			if sheep.is_in_group("invisible_sheeps"):
				if sheep.visible == false:
					sheep.visible = true
					return
