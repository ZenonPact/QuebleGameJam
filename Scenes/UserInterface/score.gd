extends Control


@export var gate_score: Area3D

@onready var label: Label = %Label


func _process(delta: float) -> void:
	label.text = str(gate_score.score)
