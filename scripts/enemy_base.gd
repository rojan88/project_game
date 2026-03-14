extends CharacterBody2D
## Base enemy: health, take damage from player, telegraphed attack, chance to drop essence on death.
## Override _get_telegraph_time(), _get_attack_duration(), _attack_effect() for different types.

class_name EnemyBase

signal died(enemy: Node2D)
signal essence_dropped(at_position: Vector2, essence_type: StringName)

@export var max_health: int = 3
@export var move_speed: float = 80.0
@export var essence_drop_chance: float = 0.5
@export var essence_type: StringName = &"common"
@export var attack_damage: int = 1
@export var telegraph_time: float = 0.5
@export var attack_duration: float = 0.25
@export var attack_cooldown: float = 1.2

var current_health: int
var _state: String = "idle"  # idle, telegraph, attacking, cooldown
var _state_timer: float = 0.0
var _target: Node2D = null
var _knockback_velocity: Vector2 = Vector2.ZERO  # Combat doc: light knockback on hit
var _telegraph_indicator: Node2D = null  # Combat doc: red ground indicator during wind-up
# Status effects (Combat doc: Burn, Freeze, Poison, Shock, Stun) — foundation + Burn DoT
var status_effects: Array[Dictionary] = []  # { "type": StringName, "duration": float, "tick": float }
const BURN_DAMAGE_PER_TICK: int = 1
const BURN_TICK_INTERVAL: float = 1.0
const POISON_DAMAGE_PER_TICK: int = 1
const POISON_TICK_INTERVAL: float = 1.0

@onready var sprite: Node2D = $Sprite2D if has_node("Sprite2D") else null
@onready var attack_hitbox: Area2D = $AttackHitbox if has_node("AttackHitbox") else null


func _ready() -> void:
	current_health = max_health
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if attack_hitbox:
		attack_hitbox.monitoring = false
		attack_hitbox.collision_mask = 1  # player
		attack_hitbox.body_entered.connect(_on_attack_hit_body)
	_find_player()


func _find_player() -> void:
	var tree := get_tree()
	if tree.has_group("player"):
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			_target = players[0] as Node2D


func add_status(effect_type: StringName, duration: float) -> void:
	for i in range(status_effects.size() - 1, -1, -1):
		if status_effects[i].get("type", &"") == effect_type:
			status_effects[i]["duration"] = maxf(status_effects[i]["duration"], duration)
			return
	status_effects.append({"type": effect_type, "duration": duration, "tick": 0.0})


func _process(delta: float) -> void:
	# Status effect ticks (Burn DoT, etc.)
	for i in range(status_effects.size() - 1, -1, -1):
		var e: Dictionary = status_effects[i]
		e["duration"] -= delta
		if e["duration"] <= 0.0:
			status_effects.remove_at(i)
			continue
		if e["type"] == &"burn":
			e["tick"] = e.get("tick", 0.0) + delta
			while e["tick"] >= BURN_TICK_INTERVAL:
				e["tick"] -= BURN_TICK_INTERVAL
				take_damage(BURN_DAMAGE_PER_TICK)
		if e["type"] == &"poison":
			e["tick"] = e.get("tick", 0.0) + delta
			while e["tick"] >= POISON_TICK_INTERVAL:
				e["tick"] -= POISON_TICK_INTERVAL
				take_damage(POISON_DAMAGE_PER_TICK)


func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_find_player()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_state_timer -= delta

	match _state:
		"idle":
			_idle_behavior(delta)
		"telegraph":
			_telegraph_behavior(delta)
		"attacking":
			_attacking_behavior(delta)
		"cooldown":
			if _state_timer <= 0.0:
				_state = "idle"
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			velocity += _knockback_velocity
			_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			move_and_slide()
			return

	# Apply knockback (Combat doc: light knockback)
	velocity += _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()


func apply_knockback(from_position: Vector2, force: float) -> void:
	var dir := (global_position - from_position).normalized()
	_knockback_velocity = dir * force


func _idle_behavior(delta: float) -> void:
	var dir := (_target.global_position - global_position).normalized()
	velocity = dir * move_speed
	var dist := global_position.distance_to(_target.global_position)
	if dist < 70.0 and _state_timer <= 0.0:
		_start_telegraph()


func _start_telegraph() -> void:
	_state = "telegraph"
	_state_timer = telegraph_time
	velocity = Vector2.ZERO
	_show_telegraph_indicator()


func _show_telegraph_indicator() -> void:
	if _telegraph_indicator != null:
		return
	var dir := (_target.global_position - global_position).normalized() if _target else Vector2.RIGHT
	_telegraph_indicator = Node2D.new()
	_telegraph_indicator.name = "TelegraphIndicator"
	var poly := Polygon2D.new()
	poly.color = Color(1, 0.2, 0.2, 0.45)
	# Rectangle in front (approx attack area)
	var half := Vector2(18, 10)
	poly.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y)
	])
	_telegraph_indicator.add_child(poly)
	_telegraph_indicator.position = dir * 14.0
	_telegraph_indicator.rotation = dir.angle()
	add_child(_telegraph_indicator)


func _hide_telegraph_indicator() -> void:
	if _telegraph_indicator != null:
		_telegraph_indicator.queue_free()
		_telegraph_indicator = null


func _telegraph_behavior(_delta: float) -> void:
	if _state_timer <= 0.0:
		_start_attack()


func _start_attack() -> void:
	_hide_telegraph_indicator()
	_state = "attacking"
	_state_timer = attack_duration
	var dir := (_target.global_position - global_position).normalized()
	if sprite and abs(dir.x) > 0.3:
		sprite.scale.x = 1.0 if dir.x >= 0 else -1.0
	if attack_hitbox:
		attack_hitbox.position = dir * 18.0
		attack_hitbox.rotation = dir.angle()
		attack_hitbox.monitoring = true


func _attacking_behavior(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 800.0 * delta)
	if _state_timer <= 0.0:
		if attack_hitbox:
			attack_hitbox.monitoring = false
		_state = "cooldown"
		_state_timer = attack_cooldown
	move_and_slide()


func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		_die()
	else:
		# Optional: flash or knockback
		pass


func _die() -> void:
	died.emit(self)
	if randf() <= essence_drop_chance:
		essence_dropped.emit(global_position, essence_type)
	queue_free()


func _on_attack_hit_body(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)


func get_attack_damage() -> int:
	return attack_damage
