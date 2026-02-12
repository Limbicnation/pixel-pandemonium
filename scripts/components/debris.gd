class_name Debris
extends RigidBody3D

@export var debris_lifetime: float = 3.0

func _ready() -> void:
	# Schedule cleanup
	_cleanup_after_delay()

func configure(size: float, color: Color) -> void:
	# Set scale
	scale = Vector3(size, size, size)
	
	# Set color on MeshInstance3D child if it exists
	var mesh_instance := get_node_or_null("MeshInstance3D")
	if mesh_instance:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mesh_instance.set_surface_override_material(0, mat)

func _cleanup_after_delay() -> void:
	await get_tree().create_timer(debris_lifetime).timeout
	
	if is_instance_valid(self):
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 0.5)
		tween.tween_callback(queue_free)
