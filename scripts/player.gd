extends CharacterBody2D
## Monster Pact — Player controller (M1 + client rules).
## 360° movement, melee attack, dodge (cooldown only — no energy).
## Energy reserved for monster abilities only (later).

# Movement
@export var move_speed: float = 180.0
@export var dodge_speed: float = 400.0
@export var dodge_duration: float = 0.15
@export var dodge_cooldown: float = 0.5  # Client: dodge = cooldown only, not energy

# Energy (client: for monster abilities only; regen over time)
@export var max_energy: int = 100
@export var energy_regen_per_second: float = 15.0

# Attack
@export var attack_duration: float = 0.25
@export var attack_cooldown: float = 0.35
@export var melee_damage: int = 1  # Client: weapon defines pattern/stats; element from monster later

# Health
@export var max_health: int = 5
@export var invuln_after_hit_duration: float = 0.8

var current_health: int
var current_energy: int
var _invuln_after_hit_timer: float = 0.0

# State
var _dodge_timer: float = 0.0
var _dodge_cooldown_timer: float = 0.0
var _attack_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _facing: Vector2 = Vector2.DOWN
var _invulnerable: bool = false
var _dead: bool = false
var _attack_hit_targets: Array[Node2D] = []
var _hit_flash_timer: float = 0.0
var _camera_shake_timer: float = 0.0

@onready var sprite: Node2D = $Sprite2D
@onready var hitbox: Area2D = $AttackHitbox
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var invuln_timer: Timer = $InvulnTimer if has_node("InvulnTimer") else null


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	current_health = max_health
	current_energy = max_energy
	if hitbox:
		hitbox.monitoring = false
		hitbox.monitorable = false
		hitbox.body_entered.connect(_on_attack_hit_body)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	# Energy regen (for future monster abilities)
	current_energy = mini(current_energy + int(energy_regen_per_second * delta), max_energy)
	# Hit flash & camera shake
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		if _hit_flash_timer <= 0.0 and sprite:
			sprite.modulate = Color(0.4, 0.7, 1, 1)
	var cam = get_node_or_null("Camera2D") as Camera2D
	if cam and _camera_shake_timer > 0.0:
		_camera_shake_timer -= delta
		cam.offset = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		if _camera_shake_timer <= 0.0:
			cam.offset = Vector2.ZERO
	# Invuln after hit
	if _invuln_after_hit_timer > 0.0:
		_invuln_after_hit_timer -= delta
		if _invuln_after_hit_timer <= 0.0:
			_invulnerable = false
	# Cooldowns
	if _dodge_cooldown_timer > 0.0:
		_dodge_cooldown_timer -= delta
	if _attack_cooldown_timer > 0.0:
		_attack_cooldown_timer -= delta

	# Dodge (priority) — client: cooldown only, no energy cost
	if _dodge_timer > 0.0:
		_process_dodge(delta)
		return

	# Attack
	if _attack_timer > 0.0:
		_process_attack(delta)
		move_and_slide()
		return

	# Input
	var want_dodge: bool = Input.is_action_just_pressed("dodge") and _dodge_cooldown_timer <= 0.0
	var want_attack: bool = Input.is_action_just_pressed("attack") and _attack_cooldown_timer <= 0.0

	if want_dodge:
		_start_dodge()
		_physics_process(delta)
		return

	if want_attack:
		_start_attack()
		move_and_slide()
		return

	# Normal movement — 360°
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if dir.length() > 1.0:
		dir = dir.normalized()
	velocity = dir * move_speed
	if dir.length_squared() > 0.01:
		_facing = dir

	_update_facing_display()
	move_and_slide()


func _process_dodge(delta: float) -> void:
	_dodge_timer -= delta
	velocity = _facing * dodge_speed
	_invulnerable = true
	move_and_slide()
	if _dodge_timer <= 0.0:
		_dodge_cooldown_timer = dodge_cooldown
		_invulnerable = false


func _start_dodge() -> void:
	_dodge_timer = dodge_duration
	_invulnerable = true


func _process_attack(delta: float) -> void:
	_attack_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	if hitbox and _attack_timer <= attack_duration * 0.5 and not hitbox.monitoring:
		hitbox.monitoring = true
	if _attack_timer <= 0.0:
		_attack_cooldown_timer = attack_cooldown
		if hitbox:
			hitbox.monitoring = false


func _start_attack() -> void:
	_attack_timer = attack_duration
	velocity = Vector2.ZERO
	_attack_hit_targets.clear()


func _update_facing_display() -> void:
	if sprite and abs(_facing.x) > 0.3:
		sprite.scale.x = 1.0 if _facing.x >= 0 else -1.0
	if hitbox and _facing.length_squared() > 0.01:
		hitbox.position = _facing.normalized() * 16.0
		hitbox.rotation = _facing.angle()


func is_invulnerable() -> bool:
	return _invulnerable


func take_damage(amount: int) -> void:
	if _invulnerable or _dead:
		return
	current_health -= amount
	_invulnerable = true
	_invuln_after_hit_timer = invuln_after_hit_duration
	_hit_feedback()
	if current_health <= 0:
		_die()


func _die() -> void:
	_dead = true
	velocity = Vector2.ZERO
	var scene = get_tree().current_scene
	if scene != null and scene.has_method("respawn_player"):
		await get_tree().create_timer(1.0).timeout
		scene.respawn_player(self)
	else:
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()


func reset_for_respawn(spawn_global_position: Vector2) -> void:
	_dead = false
	current_health = max_health
	current_energy = max_energy
	_invulnerable = true
	_invuln_after_hit_timer = 0.6
	global_position = spawn_global_position
	velocity = Vector2.ZERO


func _on_attack_hit_body(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage") and body not in _attack_hit_targets:
		_attack_hit_targets.append(body)
		body.take_damage(melee_damage)
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position, 120.0)
	# Status/element will come from active monster later (client: not from weapon)


func get_facing() -> Vector2:
	return _facing


func _hit_feedback() -> void:
	_hit_flash_timer = 0.12
	_camera_shake_timer = 0.15
	if sprite:
		sprite.modulate = Color(1, 0.4, 0.4, 1)
