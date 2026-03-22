extends CharacterBody2D
## Base enemy: telegraphed attacks, essence drop, full M3 status system (monster spec).

class_name EnemyBase

signal died(enemy: Node2D)
signal essence_dropped(at_position: Vector2, essence_type: StringName)

const DMG_FLAG_RAW: int = 0
const DMG_FLAG_PLAYER: int = 1

@export var max_health: int = 3
@export var move_speed: float = 80.0
@export var essence_drop_chance: float = 0.5
@export var essence_type: StringName = &"common"
@export var attack_damage: int = 1
@export var telegraph_time: float = 0.5
@export var attack_duration: float = 0.25
@export var attack_cooldown: float = 1.2

var current_health: int
var _state: String = "idle"
var _state_timer: float = 0.0
var _target: Node2D = null
var _knockback_velocity: Vector2 = Vector2.ZERO
var _telegraph_indicator: Node2D = null

var _base_move_speed: float = 80.0
var _hard_stun_timer: float = 0.0
var _stun_immunity_timer: float = 0.0
var _statuses: Array[Dictionary] = []

@onready var sprite: Node2D = $Sprite2D if has_node("Sprite2D") else null
@onready var attack_hitbox: Area2D = $AttackHitbox if has_node("AttackHitbox") else null


func _ready() -> void:
	current_health = max_health
	_base_move_speed = move_speed
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if attack_hitbox:
		attack_hitbox.monitoring = false
		attack_hitbox.collision_mask = 1
		attack_hitbox.body_entered.connect(_on_attack_hit_body)
	_find_player()


func _find_player() -> void:
	var tree := get_tree()
	if tree.has_group("player"):
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			_target = players[0] as Node2D


func _has_status(kind: StringName) -> bool:
	for s in _statuses:
		if s.get("kind", &"") == kind:
			return float(s.get("duration", 0.0)) > 0.0
	return false


func _get_move_speed_mult() -> float:
	if _hard_stun_timer > 0.0:
		return 0.0
	if _is_rooted():
		return 0.0
	if _has_status(&"freeze"):
		return 0.4
	return 1.0


func _get_state_timer_scale() -> float:
	# Slower attacks while frozen (crowd control)
	if _has_status(&"freeze") and _hard_stun_timer <= 0.0:
		return 0.4
	return 1.0


func _is_rooted() -> bool:
	return _has_status(&"root")


func apply_burn_from_spec(base_attack_damage: int) -> void:
	var tick_dmg: int = maxi(1, int(ceil(base_attack_damage * 0.10)))
	for i in range(_statuses.size()):
		if _statuses[i].get("kind", &"") == &"burn":
			_statuses[i]["duration"] = 4.0
			_statuses[i]["tick_dmg"] = tick_dmg
			return
	_statuses.append({"kind": &"burn", "duration": 4.0, "tick": 0.0, "tick_dmg": tick_dmg})


func apply_freeze_from_spec() -> void:
	if _has_status(&"freeze"):
		_hard_stun_timer = maxf(_hard_stun_timer, 0.5)
	for i in range(_statuses.size()):
		if _statuses[i].get("kind", &"") == &"freeze":
			_statuses[i]["duration"] = 2.0
			return
	_statuses.append({"kind": &"freeze", "duration": 2.0})


func apply_poison_from_spec(base_attack_damage: int) -> void:
	for i in range(_statuses.size()):
		if _statuses[i].get("kind", &"") == &"poison":
			var st: int = mini(5, int(_statuses[i].get("stacks", 1)) + 1)
			_statuses[i]["stacks"] = st
			_statuses[i]["duration"] = 5.0
			_statuses[i]["base"] = base_attack_damage
			return
	_statuses.append({"kind": &"poison", "duration": 5.0, "tick": 0.0, "stacks": 1, "base": base_attack_damage})


func apply_stone_on_hit_from_spec(from_position: Vector2) -> void:
	if _stun_immunity_timer > 0.0:
		return
	if randf() > 0.20:
		return
	_hard_stun_timer = maxf(_hard_stun_timer, 1.0)
	_stun_immunity_timer = 2.0
	apply_knockback(from_position, 120.0)


func apply_shadow_mark() -> void:
	for i in range(_statuses.size()):
		if _statuses[i].get("kind", &"") == &"shadow_mark":
			_statuses[i]["duration"] = 2.0
			return
	_statuses.append({"kind": &"shadow_mark", "duration": 2.0})


func apply_nature_root_from_spec() -> void:
	if randf() > 0.20:
		return
	for i in range(_statuses.size()):
		if _statuses[i].get("kind", &"") == &"root":
			_statuses[i]["duration"] = 1.5
			return
	_statuses.append({"kind": &"root", "duration": 1.5})


func apply_expose_from_spec() -> void:
	for i in range(_statuses.size()):
		if _statuses[i].get("kind", &"") == &"expose":
			_statuses[i]["duration"] = 3.0
			return
	_statuses.append({"kind": &"expose", "duration": 3.0})


func _process(delta: float) -> void:
	_stun_immunity_timer = maxf(0.0, _stun_immunity_timer - delta)
	_hard_stun_timer = maxf(0.0, _hard_stun_timer - delta)

	var idx := 0
	while idx < _statuses.size():
		var e: Dictionary = _statuses[idx]
		var kind: StringName = e.get("kind", &"")
		e["duration"] = float(e["duration"]) - delta

		if kind == &"burn":
			e["tick"] = float(e.get("tick", 0.0)) + delta
			while float(e["tick"]) >= 1.0 and float(e["duration"]) > 0.0:
				e["tick"] = float(e["tick"]) - 1.0
				_apply_raw_damage(int(e.get("tick_dmg", 1)))
			if float(e["duration"]) <= 0.0:
				_statuses.remove_at(idx)
				continue
		elif kind == &"poison":
			e["tick"] = float(e.get("tick", 0.0)) + delta
			var stacks: int = int(e.get("stacks", 1))
			var base_d: int = int(e.get("base", 1))
			var tick_dmg: int = maxi(1, int(ceil(0.06 * float(base_d) * float(stacks))))
			while float(e["tick"]) >= 1.0 and float(e["duration"]) > 0.0:
				e["tick"] = float(e["tick"]) - 1.0
				_apply_raw_damage(tick_dmg)
			if float(e["duration"]) <= 0.0:
				_statuses.remove_at(idx)
				continue
		else:
			if float(e["duration"]) <= 0.0:
				_statuses.remove_at(idx)
				continue
		idx += 1


func _apply_raw_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		_die()


func take_damage(amount: int, flags: int = DMG_FLAG_RAW) -> void:
	var amt: int = amount
	if flags & DMG_FLAG_PLAYER:
		if _has_status(&"shadow_mark"):
			amt = int(ceil(amt * 1.40))
		if _has_status(&"expose"):
			amt = int(ceil(amt * 1.15))
	current_health -= amt
	if current_health <= 0:
		_die()


## Legacy / clarity
func add_status(effect_type: StringName, duration: float) -> void:
	if effect_type == &"burn":
		apply_burn_from_spec(10)
	elif effect_type == &"poison":
		apply_poison_from_spec(10)
	else:
		_statuses.append({"kind": effect_type, "duration": duration})


func _physics_process(delta: float) -> void:
	if _hard_stun_timer > 0.0:
		velocity = Vector2.ZERO
		velocity += _knockback_velocity
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return

	if _target == null or not is_instance_valid(_target):
		_find_player()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var tscale: float = _get_state_timer_scale()
	_state_timer -= delta * tscale

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

	velocity += _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()


func apply_knockback(from_position: Vector2, force: float) -> void:
	var dir := (global_position - from_position).normalized()
	_knockback_velocity = dir * force


func _idle_behavior(_delta: float) -> void:
	var spd: float = _base_move_speed * _get_move_speed_mult()
	var dir := (_target.global_position - global_position).normalized()
	velocity = dir * spd
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
