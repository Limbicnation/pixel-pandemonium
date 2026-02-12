class_name Target
extends StaticBody3D

@onready var health: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var debris_scene: PackedScene

var original_color: Color

func _ready() -> void:
	health.health_depleted.connect(_on_destroyed)
	health.health_changed.connect(_on_health_changed)
	
	if mesh and mesh.get_surface_override_material(0):
		original_color = mesh.get_surface_override_material(0).albedo_color

func _on_health_changed(_new_health: int, _max_health: int) -> void:
	_flash_white()

func _flash_white() -> void:
	if not mesh:
		return
	
	var mat := mesh.get_surface_override_material(0)
	if not mat:
		return
	
	var prev_color: Color = mat.albedo_color
	mat.albedo_color = Color.WHITE
	
	await get_tree().create_timer(0.05).timeout
	
	if is_instance_valid(self) and mesh and mat:
		mat.albedo_color = original_color

func _on_destroyed() -> void:
	_spawn_debris()
	queue_free()

func _spawn_debris() -> void:
	if not debris_scene:
		push_warning("Target: No debris scene assigned!")
		return

	var debris_count := randi_range(4, 6)

	for i in debris_count:
		var debris: RigidBody3D = debris_scene.instantiate()
		var size := randf_range(0.1, 0.3)

		# Configure debris (assuming it has a configure method)
		if debris.has_method("configure"):
			debris.configure(size, original_color.darkened(randf() * 0.3))

		debris.global_position = global_position + Vector3(
			randf_range(-0.3, 0.3),
			randf_range(0, 0.5),
			randf_range(-0.3, 0.3)
		)

		get_tree().current_scene.add_child(debris)

		debris.apply_central_impulse(Vector3(
			randf_range(-2, 2),
			randf_range(2, 5),
			randf_range(-2, 2)
		))

		debris.angular_velocity = Vector3(
			randf_range(-5, 5),
			randf_range(-5, 5),
			randf_range(-5, 5)
		)

func _remove_debris_after_delay(debris: RigidBody3D) -> void:
	# Handled by debris script cleanup
	pass
