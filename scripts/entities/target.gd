class_name Target
extends StaticBody3D

@onready var health: HealthComponent = $HealthComponent
@onready var mesh: MeshInstance3D = $MeshInstance3D

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
		mat.albedo_color = prev_color

func _on_destroyed() -> void:
	_spawn_debris()
	queue_free()

func _spawn_debris() -> void:
	var debris_count := randi_range(4, 6)
	
	for i in debris_count:
		var debris := RigidBody3D.new()
		debris.mass = 0.5
		
		var size := randf_range(0.1, 0.3)
		var shape := BoxShape3D.new()
		shape.size = Vector3(size, size, size)
		
		var collision := CollisionShape3D.new()
		collision.shape = shape
		debris.add_child(collision)
		
		var mesh_instance := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = Vector3(size, size, size)
		mesh_instance.mesh = box_mesh
		
		var mat := StandardMaterial3D.new()
		mat.albedo_color = original_color.darkened(randf() * 0.3)
		mesh_instance.set_surface_override_material(0, mat)
		debris.add_child(mesh_instance)
		
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
		
		_remove_debris_after_delay(debris)

func _remove_debris_after_delay(debris: RigidBody3D) -> void:
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(debris):
		debris.queue_free()
