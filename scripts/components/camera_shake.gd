class_name CameraShake
extends Node3D

@export var shake_decay: float = 8.0
@export var max_offset: Vector3 = Vector3(0.5, 0.5, 0.3)
@export var max_roll: float = 0.1

var shake_strength: float = 0.0
var trauma: float = 0.0  ## 0-1 trauma system for more natural decay
var initial_position: Vector3 = Vector3.ZERO
var noise: FastNoiseLite

func _ready() -> void:
	initial_position = position
	
	# Setup noise for more organic shake
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.5

func _process(delta: float) -> void:
	if trauma > 0:
		# Decay trauma exponentially (feels more natural)
		trauma = max(0.0, trauma - shake_decay * delta * trauma)
		
		# Calculate shake amount (quadratic for more impact at high trauma)
		var shake_amount := trauma * trauma
		var time := Time.get_ticks_msec() / 1000.0
		
		# Use noise for organic movement
		position.x = initial_position.x + noise.get_noise_1d(time * 20.0) * shake_amount * max_offset.x
		position.y = initial_position.y + noise.get_noise_1d(time * 20.0 + 100.0) * shake_amount * max_offset.y
		position.z = initial_position.z + noise.get_noise_1d(time * 20.0 + 200.0) * shake_amount * max_offset.z
		
		# Roll rotation
		rotation.z = noise.get_noise_1d(time * 15.0) * shake_amount * max_roll
	else:
		position = initial_position
		rotation.z = 0.0
		trauma = 0.0

## Add trauma (0-1 scale)
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

## Apply shake directly (legacy, converts to trauma)
func apply_shake(strength: float) -> void:
	add_trauma(strength)

## Preset shakes for common scenarios
func explosion() -> void:
	add_trauma(1.0)

func strong_impact() -> void:
	add_trauma(0.7)

func medium_impact() -> void:
	add_trauma(0.4)

func light_impact() -> void:
	add_trauma(0.2)

func gun_recoil() -> void:
	add_trauma(0.15)

func landing() -> void:
	add_trauma(0.25)

func get_current_trauma() -> float:
	return trauma
