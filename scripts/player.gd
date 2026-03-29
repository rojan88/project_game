extends CharacterBody2D
## M3: Movement, weapon-scaled melee (pierce for Spirit), dodge + Shadow window, monster special (energy).

@export var move_speed: float = 180.0
@export var dodge_speed: float = 400.0
@export var dodge_duration: float = 0.15
@export var dodge_cooldown: float = 0.5

@export var max_energy: int = 100
@export var energy_regen_per_second: float = 15.0
@export var special_energy_cost: int = 30

@export var attack_duration: float = 0.25
@export var attack_cooldown: float = 0.35
@export var melee_damage: int = 1

@export var max_health: int = 5
@export var invuln_after_hit_duration: float = 0.8

var current_health: int
var current_energy: int
var _invuln_after_hit_timer: float = 0.0

var _dodge_timer: float = 0.0
var _dodge_cooldown_timer: float = 0.0
var _attack_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _facing: Vector2 = Vector2.DOWN
var _invulnerable: bool = false
var _dead: bool = false
var _attack_hit_targets: Array[Node2D] = []
var _melee_resolved: bool = false
var _hit_flash_timer: float = 0.0
var _camera_shake_timer: float = 0.0
var _shadow_follow_up_timer: float = 0.0

const COMPANION_SCENE: PackedScene = preload("res://scenes/companions/companion.tscn")

@onready var sprite: Node2D = $Sprite2D
@onready var hitbox: Area2D = $AttackHitbox
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var companion_holder: Node2D = $CompanionHolder if has_node("CompanionHolder") else null


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	_apply_loadout_stats()
	current_health = max_health
	current_energy = mini(current_energy, _effective_max_energy())
	if hitbox:
		hitbox.monitoring = false
		hitbox.monitorable = false
	if GameState.active_companion_changed.is_connected(_refresh_companion) == false:
		GameState.active_companion_changed.connect(_refresh_companion)
	if GameState.equipment_changed.is_connected(_on_loadout_changed) == false:
		GameState.equipment_changed.connect(_on_loadout_changed)
	if GameState.player_progress_changed.is_connected(_on_loadout_changed) == false:
		GameState.player_progress_changed.connect(_on_loadout_changed)
	_refresh_companion(GameState.active_companion_id)


func _on_loadout_changed() -> void:
	_apply_loadout_stats()
	current_health = mini(current_health, max_health)


func _apply_loadout_stats() -> void:
	max_health = GameState.get_player_max_health()
	var w_spd: float = WeaponConfig.get_attack_speed_mult(GameState.main_weapon_id)
	attack_cooldown = 0.35 / w_spd
	attack_duration = 0.25 / w_spd


func _effective_max_energy() -> int:
	return max_energy + SecondaryItemConfig.get_max_energy_bonus(GameState.secondary_item_id)


func get_base_attack_damage() -> int:
	var w: float = WeaponConfig.get_damage_mult(GameState.main_weapon_id)
	var s: float = SecondaryItemConfig.get_damage_mult(GameState.secondary_item_id)
	return maxi(1, int(ceil(float(melee_damage) * w * s)))


func is_shadow_dodge_window_active() -> bool:
	return _shadow_follow_up_timer > 0.0


func _physics_process(delta: float) -> void:
	if _dead:
		return
	var regen_mult: float = SecondaryItemConfig.get_energy_regen_mult(GameState.secondary_item_id)
	var emax: int = _effective_max_energy()
	current_energy = mini(current_energy + int(energy_regen_per_second * regen_mult * delta), emax)
	if _shadow_follow_up_timer > 0.0:
		_shadow_follow_up_timer -= delta

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
	if _invuln_after_hit_timer > 0.0:
		_invuln_after_hit_timer -= delta
		if _invuln_after_hit_timer <= 0.0:
			_invulnerable = false
	if _dodge_cooldown_timer > 0.0:
		_dodge_cooldown_timer -= delta
	if _attack_cooldown_timer > 0.0:
		_attack_cooldown_timer -= delta

	if _dodge_timer > 0.0:
		_process_dodge(delta)
		return

	if _attack_timer > 0.0:
		_process_attack(delta)
		move_and_slide()
		return

	if Input.is_action_just_pressed("special"):
		_try_companion_special()
	if Input.is_action_just_pressed("next_companion"):
		_cycle_monster()
	if Input.is_action_just_pressed("unlock_companion"):
		_try_unlock_next_monster()

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

	var spd: float = move_speed * SecondaryItemConfig.get_move_speed_mult(GameState.secondary_item_id)
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if dir.length() > 1.0:
		dir = dir.normalized()
	velocity = dir * spd
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
		_shadow_follow_up_timer = 1.0


func _start_dodge() -> void:
	_dodge_timer = dodge_duration
	_invulnerable = true
	AudioManager.play_dodge()


func _process_attack(delta: float) -> void:
	_attack_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	if hitbox and _attack_timer <= attack_duration * 0.5 and not hitbox.monitoring:
		hitbox.monitoring = true
		_melee_resolved = false
		call_deferred("_resolve_melee_hits_deferred")
	if _attack_timer <= 0.0:
		_attack_cooldown_timer = attack_cooldown
		if hitbox:
			hitbox.monitoring = false


func _start_attack() -> void:
	_attack_timer = attack_duration
	velocity = Vector2.ZERO
	_attack_hit_targets.clear()
	_melee_resolved = false


func _resolve_melee_hits_deferred() -> void:
	if _melee_resolved or hitbox == null or not hitbox.monitoring:
		return
	_melee_resolved = true
	_resolve_melee_hits()


func _resolve_melee_hits() -> void:
	if hitbox == null:
		return
	var base: int = get_base_attack_damage()
	var mtype: StringName = MonsterConfig.get_monster_type(GameState.active_companion_id)
	var bodies: Array = hitbox.get_overlapping_bodies()
	var enemies: Array[Node2D] = []
	for b in bodies:
		if b is Node2D and b.is_in_group("enemy"):
			enemies.append(b as Node2D)
	enemies.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	var max_targets: int = 3 if mtype == MonsterConfig.TYPE_SPIRIT else 1
	var mults: Array[float] = [1.0, 0.9, 0.8]
	var landed: bool = false
	for i in mini(max_targets, enemies.size()):
		var e: Node2D = enemies[i]
		if e in _attack_hit_targets:
			continue
		_attack_hit_targets.append(e)
		var dmg: int = maxi(1, int(ceil(float(base) * mults[i])))
		if e.has_method("take_damage"):
			e.take_damage(dmg, EnemyBase.DMG_FLAG_PLAYER)
			landed = true
		if e.has_method("apply_knockback"):
			e.apply_knockback(global_position, 120.0)
		var primary_chain: bool = (i == 0)
		CombatEffects.apply_player_melee_effects(self, e, base, dmg, primary_chain)
	if landed:
		AudioManager.play_hit()


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
	_apply_loadout_stats()
	current_health = max_health
	current_energy = _effective_max_energy()
	_invulnerable = true
	_invuln_after_hit_timer = 0.6
	global_position = spawn_global_position
	velocity = Vector2.ZERO


func get_facing() -> Vector2:
	return _facing


func _refresh_companion(_id: StringName) -> void:
	if companion_holder == null:
		return
	for c in companion_holder.get_children():
		c.queue_free()
	if GameState.active_companion_id.is_empty():
		return
	var comp: Node2D = COMPANION_SCENE.instantiate()
	companion_holder.add_child(comp)


func _try_companion_special() -> void:
	if companion_holder == null or current_energy < special_energy_cost:
		return
	for c in companion_holder.get_children():
		if c.has_method("use_special"):
			if c.use_special(global_position, _facing):
				current_energy = maxi(0, current_energy - special_energy_cost)
				AudioManager.play_ability()
			return


func _cycle_monster() -> void:
	var next_id: StringName = GameState.get_next_unlocked_monster()
	if next_id.is_empty():
		return
	GameState.set_active_companion(next_id)


func _try_unlock_next_monster() -> void:
	for id in MonsterConfig.MONSTER_IDS:
		if GameState.is_monster_unlocked(id):
			continue
		if GameState.try_unlock_monster(id):
			return


func _hit_feedback() -> void:
	_hit_flash_timer = 0.12
	_camera_shake_timer = 0.15
	if sprite:
		sprite.modulate = Color(1, 0.4, 0.4, 1)
