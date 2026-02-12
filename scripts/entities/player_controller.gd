class_name PlayerController
extends CharacterBody3D

@export_group("Movement")
@export var walk_speed: float = 8.0
@export var sprint_speed: float = 12.0
@export var acceleration: float = 80.0
@export var friction: float = 60.0
@export var air_control: float = 0.4
@export var air_acceleration: float = 15.0
@export var gravity: float = 25.0
@export var fast_fall_multiplier: float = 1.5

@export_group("Jump")
@export var jump_velocity: float = 12.0
@export var jump_cut_multiplier: float = 0.4
@export var coyote_time: float = 0.12
@export var jump_buffer: float = 0.12

@export_group("Dodge")
@export var dodge_speed: float = 18.0
@export var dodge_duration: float = 0.25
@export var dodge_cooldown: float = 0.8

@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.002
@export var invert_y: bool = false
@export var max_look_up: float = 89.0
@export var max_look_down: float = -89.0
@export var fov_change_speed: float = 10.0
@export var sprint_fov: float = 100.0
@export var normal_fov: float = 90.0

@export_group("Weapon")
@export var fire_rate: float = 12.0
@export var damage: int = 25
@export var recoil_strength: float = 0.04
@export var recoil_recovery: float = 5.0
@export var weapon_range: float = 100.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/CameraShake/Camera3D
@onready var raycast: RayCast3D = $Head/CameraShake/Camera3D/RayCast3D
@onready var dodge_timer: Timer = $Timers/DodgeTimer
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var jump_buffer_timer: Timer = $Timers/JumpBufferTimer
@onready var dodge_cooldown_timer: Timer = $Timers/DodgeCooldownTimer

var current_speed: float = 0.0
var is_sprinting: bool = false
var is_dodging: bool = false
var is_aiming: bool = false
var dodge_direction: Vector3 = Vector3.ZERO
var input_dir: Vector2 = Vector2.ZERO
var look_rotation: Vector2 = Vector2.ZERO
var recoil_offset: Vector2 = Vector2.ZERO
var current_recoil: float = 0.0
var fire_cooldown: float = 0.0

signal jumped
signal dodged(direction: Vector3)
signal landed
signal weapon_fired(hit_point: Vector3, hit_normal: Vector3)
signal interacted

func _ready() -> void:
	print("PlayerController: _ready() called")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_setup_timers()
	current_speed = walk_speed
	look_rotation.y = rotation.y
	if head:
		look_rotation.x = head.rotation.x
	print("PlayerController: _ready() completed")

	# Verify critical nodes loaded
	if camera == null:
		push_error("PlayerController: Camera3D not found at $Head/CameraShake/Camera3D")
		return

	if raycast == null:
		push_error("PlayerController: RayCast3D not found at $Head/CameraShake/Camera3D/RayCast3D")
		return

	if dodge_timer == null or coyote_timer == null or jump_buffer_timer == null or dodge_cooldown_timer == null:
		push_error("PlayerController: Missing timer nodes in $Timers/")
		return

	# Register with GameManager
	if GameManager:
		GameManager.register_player(self)
		print("PlayerController: Registered with GameManager")
	else:
		push_error("PlayerController: GameManager not found!")

func _setup_timers() -> void:
	if dodge_timer:
		dodge_timer.wait_time = dodge_duration
		dodge_timer.one_shot = true
		dodge_timer.timeout.connect(_on_dodge_finished)
	
	if coyote_timer:
		coyote_timer.wait_time = coyote_time
		coyote_timer.one_shot = true
	
	if jump_buffer_timer:
		jump_buffer_timer.wait_time = jump_buffer
		jump_buffer_timer.one_shot = true
	
	if dodge_cooldown_timer:
		dodge_cooldown_timer.wait_time = dodge_cooldown
		dodge_cooldown_timer.one_shot = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_handle_mouse_look(event.relative)
	
	if event.is_action_pressed("jump"):
		if jump_buffer_timer:
			jump_buffer_timer.start()
	
	if event.is_action_released("jump") and velocity.y > 0:
		velocity.y *= jump_cut_multiplier
	
	if event.is_action_pressed("dodge"):
		if not is_dodging and dodge_cooldown_timer and dodge_cooldown_timer.is_stopped():
			_attempt_dodge()
	
	if event.is_action_pressed("interact"):
		_attempt_interact()
	
	if event.is_action_pressed("fire"):
		_attempt_fire()
	
	if event.is_action_pressed("aim"):
		_toggle_aim()
	
	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_capture()

func _handle_mouse_look(relative: Vector2) -> void:
	look_rotation.y -= relative.x * mouse_sensitivity
	
	var y_multiplier := 1.0 if invert_y else -1.0
	look_rotation.x -= relative.y * mouse_sensitivity * y_multiplier
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(max_look_down), deg_to_rad(max_look_up))
	
	rotation.y = look_rotation.y
	if head:
		head.rotation.x = look_rotation.x

func _physics_process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta
	
	if Input.is_action_pressed("fire") and fire_cooldown <= 0:
		_attempt_fire()
	
	if is_dodging:
		velocity.x = dodge_direction.x * dodge_speed
		velocity.z = dodge_direction.z * dodge_speed
		velocity.y = 0
		_update_weapon_bob(delta, true)
		_update_recoil(delta)
		_update_fov(delta)
		move_and_slide()
		return
	
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	is_sprinting = Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO and not is_aiming
	var target_speed := sprint_speed if is_sprinting else walk_speed
	if is_aiming:
		target_speed = walk_speed * 0.5
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var accel := acceleration if is_on_floor() else air_acceleration
		velocity.x = lerpf(velocity.x, direction.x * target_speed, 1.0 - exp(-accel * delta))
		velocity.z = lerpf(velocity.z, direction.z * target_speed, 1.0 - exp(-accel * delta))
	else:
		var fric := friction if is_on_floor() else friction * 0.3
		velocity.x = move_toward(velocity.x, 0, fric * delta)
		velocity.z = move_toward(velocity.z, 0, fric * delta)
	
	if not is_on_floor():
		var grav := gravity
		if Input.is_action_pressed("move_backward"):
			grav *= fast_fall_multiplier
		velocity.y -= grav * delta
	else:
		if coyote_timer and coyote_timer.is_stopped():
			coyote_timer.start()
		
		if jump_buffer_timer and not jump_buffer_timer.is_stopped():
			_jump()
	
	if jump_buffer_timer and not jump_buffer_timer.is_stopped():
		if is_on_floor() or (coyote_timer and not coyote_timer.is_stopped()):
			_jump()
	
	move_and_slide()
	
	if is_on_floor() and velocity.y < 0:
		if velocity.y < -2.0:
			landed.emit()
	
	_update_weapon_bob(delta, false)
	_update_recoil(delta)
	_update_fov(delta)

func _jump() -> void:
	velocity.y = jump_velocity
	if jump_buffer_timer:
		jump_buffer_timer.stop()
	if coyote_timer:
		coyote_timer.stop()
	jumped.emit()

func _attempt_dodge() -> void:
	var dodge_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if dodge_input == Vector2.ZERO:
		dodge_input = Vector2(0, -1)
	
	dodge_direction = (transform.basis * Vector3(dodge_input.x, 0, dodge_input.y)).normalized()
	
	if dodge_direction and dodge_timer:
		is_dodging = true
		dodge_timer.start()
		if dodge_cooldown_timer:
			dodge_cooldown_timer.start()
		dodged.emit(dodge_direction)

func _on_dodge_finished() -> void:
	is_dodging = false

func _attempt_interact() -> void:
	if raycast and raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(self)
			interacted.emit()

func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _toggle_aim() -> void:
	is_aiming = not is_aiming

func _attempt_fire() -> void:
	if fire_cooldown > 0:
		return
	if not is_inside_tree():
		return
	if camera == null:
		return
	
	fire_cooldown = 1.0 / max(fire_rate, 0.01)
	
	current_recoil = recoil_strength
	recoil_offset.y -= recoil_strength * 100.0
	recoil_offset.x += randf_range(-recoil_strength, recoil_strength) * 50.0
	
	_show_muzzle_flash()
	
	var world := get_world_3d()
	if world == null:
		return
	
	var space_state := world.direct_space_state
	var from := camera.global_position
	var to := from - camera.global_transform.basis.z * weapon_range
	
	to += camera.global_transform.basis.y * recoil_offset.y * 0.01
	to += camera.global_transform.basis.x * recoil_offset.x * 0.01
	
	var query := PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 0xFFFFFFFF & ~(1 << 1)
	query.exclude = [self]
	
	var result := space_state.intersect_ray(query)
	
	var hit_point: Vector3
	var hit_normal: Vector3
	
	if result:
		hit_point = result.position
		hit_normal = result.normal
		
		var collider: Object = result.collider
		if collider and collider.has_node("HealthComponent"):
			var health_node: Node = collider.get_node("HealthComponent")
			if health_node and health_node.has_method("take_damage"):
				health_node.take_damage(damage, self)
		
		_spawn_impact_effect(hit_point, hit_normal)
	else:
		hit_point = to
		hit_normal = Vector3.UP
	
	weapon_fired.emit(hit_point, hit_normal)

func _show_muzzle_flash() -> void:
	var weapon_holder := get_node_or_null("Head/CameraShake/Camera3D/WeaponHolder")
	var gun_body := get_node_or_null("Head/CameraShake/Camera3D/WeaponHolder/GunBody")
	var gun_barrel := get_node_or_null("Head/CameraShake/Camera3D/WeaponHolder/GunBarrel")
	
	if weapon_holder and weapon_holder.is_inside_tree():
		weapon_holder.position.z += 0.05
		var tween := create_tween()
		tween.tween_property(weapon_holder, "position:z", -0.4, 0.1)
	
	if gun_body and gun_body.is_inside_tree() and gun_barrel and gun_barrel.is_inside_tree():
		gun_body.scale = Vector3(1.1, 1.1, 1.2)
		gun_barrel.scale = Vector3(1.2, 1.2, 1.3)
		
		var tween := create_tween()
		tween.set_parallel()
		tween.tween_property(gun_body, "scale", Vector3.ONE, 0.1)
		tween.tween_property(gun_barrel, "scale", Vector3.ONE, 0.1)
	
	_spawn_muzzle_flash_light()

func _spawn_muzzle_flash_light() -> void:
	var muzzle_pos := get_node_or_null("Head/CameraShake/Camera3D/WeaponHolder/MuzzlePosition")
	if not muzzle_pos:
		return
	
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.8, 0.4)
	light.light_energy = 5.0
	light.omni_range = 3.0
	muzzle_pos.add_child(light)
	
	# Smooth fade out with tween
	var tween := create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.05)
	tween.tween_callback(light.queue_free)

func _spawn_impact_effect(hit_pos: Vector3, normal: Vector3) -> void:
	var spark := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	spark.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.6, 0.1)
	mat.emission_energy = 2.0
	spark.set_surface_override_material(0, mat)
	
	spark.global_position = hit_pos + normal * 0.02
	
	var tree := get_tree()
	if tree:
		tree.root.add_child(spark)
	
	# Create tween on the spark itself for safer lifecycle management
	var tween := spark.create_tween()
	tween.tween_property(spark, "scale", Vector3.ZERO, 0.2)
	tween.finished.connect(func():
		if is_instance_valid(spark):
			spark.queue_free()
	)

func _update_weapon_bob(delta: float, is_dodging_: bool) -> void:
	var weapon_holder := get_node_or_null("Head/CameraShake/Camera3D/WeaponHolder")
	if not weapon_holder:
		return
	
	var target_pos := Vector3(0.25, -0.15, -0.4)
	
	if is_dodging_:
		target_pos = Vector3(0.1, -0.3, -0.3)
	elif is_aiming:
		target_pos = Vector3(0, -0.15, -0.4)
	elif is_on_floor() and input_dir != Vector2.ZERO:
		var time: float = Time.get_time_dict_from_system()["second"] + Time.get_ticks_msec() / 1000.0
		var bob_freq := 15.0 if is_sprinting else 10.0
		var bob_amp := 0.05 if is_sprinting else 0.03
		target_pos.y += sin(time * bob_freq) * bob_amp
		target_pos.x += cos(time * bob_freq * 0.5) * bob_amp * 0.5
	
	weapon_holder.position = weapon_holder.position.lerp(target_pos, 1.0 - exp(-10.0 * delta))

func _update_recoil(delta: float) -> void:
	recoil_offset = recoil_offset.lerp(Vector2.ZERO, recoil_recovery * delta)
	
	if camera:
		camera.rotation_degrees.x = recoil_offset.y
		camera.rotation_degrees.y = recoil_offset.x * 0.5

func _update_fov(delta: float) -> void:
	if camera == null:
		return
	
	var target_fov := normal_fov
	if is_sprinting:
		target_fov = sprint_fov
	elif is_aiming:
		target_fov = normal_fov - 10.0
	
	camera.fov = lerpf(camera.fov, target_fov, fov_change_speed * delta)

func apply_knockback(force: Vector3) -> void:
	velocity += force

func is_grounded() -> bool:
	return is_on_floor()

func is_moving() -> bool:
	return input_dir != Vector2.ZERO

func get_velocity_horizontal() -> float:
	return Vector2(velocity.x, velocity.z).length()
