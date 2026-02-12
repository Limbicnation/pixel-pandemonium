class_name HealthComponent
extends Node

@export_group("Health Settings")
@export var max_health: int = 100
@export var invincibility_time: float = 0.0

var current_health: int = 0
var is_invincible: bool = false

var _invincibility_timer: Timer = null

signal health_changed(new_health: int, max_health: int)
signal health_depleted
signal damage_taken(amount: int, source: Node)
signal healed(amount: int)

func _ready() -> void:
	current_health = max_health
	
	if invincibility_time > 0:
		_setup_invincibility_timer()

func _setup_invincibility_timer() -> void:
	_invincibility_timer = Timer.new()
	_invincibility_timer.name = "InvincibilityTimer"
	_invincibility_timer.one_shot = true
	_invincibility_timer.wait_time = invincibility_time
	add_child(_invincibility_timer)

func take_damage(amount: int, source: Node = null) -> void:
	if is_invincible or amount <= 0:
		return
	
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	damage_taken.emit(amount, source)
	
	if invincibility_time > 0:
		start_invincibility()
	
	if current_health == 0:
		health_depleted.emit()

func heal(amount: int) -> void:
	if amount <= 0:
		return
	
	var old_health := current_health
	current_health = min(max_health, current_health + amount)
	var actual_heal := current_health - old_health
	
	if actual_heal > 0:
		health_changed.emit(current_health, max_health)
		healed.emit(actual_heal)

func start_invincibility() -> void:
	is_invincible = true
	if _invincibility_timer:
		_invincibility_timer.start()
		await _invincibility_timer.timeout
		is_invincible = false

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	return current_health > 0

func is_dead() -> bool:
	return current_health <= 0

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
