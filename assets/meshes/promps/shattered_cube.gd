extends Node3D

# Movement speed in units per second
var move_speed: float = 5.0

func _ready() -> void:
	print("Starting position: ", position)

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y += move_speed * delta
	elif Input.is_action_pressed("ui_down"):
		position.y -= move_speed * delta
