extends Node2D
## M3: Active monster — auto-attack + special (energy cost on player). Data from MonsterConfig.

var companion_id: StringName = &""
var _player: Node2D
var _auto_timer: float = 0.0
var _special_timer: float = 0.0
var _data: Dictionary = {}

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/companions/companion_projectile.tscn")

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null


func _ready() -> void:
	companion_id = GameState.active_companion_id
	_data = MonsterConfig.get_data(companion_id)
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null and get_parent() != null:
		_player = get_parent().get_parent() as Node2D
	_update_visual()
	_auto_timer = 0.0
	_special_timer = 0.0


func refresh_from_game_state() -> void:
	companion_id = GameState.active_companion_id
	_data = MonsterConfig.get_data(companion_id)
	_update_visual()


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var offset := Vector2(20, -8)
	global_position = _player.global_position + offset
	_auto_timer -= delta
	_special_timer -= delta
	if _auto_timer <= 0.0:
		_try_auto_attack()
		_auto_timer = _data.get("auto_attack_cooldown", 1.0)


func _update_visual() -> void:
	if not sprite:
		return
	match MonsterConfig.get_monster_type(companion_id):
		MonsterConfig.TYPE_FIRE:
			sprite.modulate = Color(1, 0.45, 0.2)
		MonsterConfig.TYPE_FROST:
			sprite.modulate = Color(0.6, 0.85, 1.0)
		MonsterConfig.TYPE_POISON:
			sprite.modulate = Color(0.4, 0.9, 0.35)
		MonsterConfig.TYPE_STORM:
			sprite.modulate = Color(0.85, 0.75, 1.0)
		MonsterConfig.TYPE_STONE:
			sprite.modulate = Color(0.65, 0.6, 0.55)
		MonsterConfig.TYPE_SHADOW:
			sprite.modulate = Color(0.45, 0.35, 0.65)
		MonsterConfig.TYPE_NATURE:
			sprite.modulate = Color(0.35, 0.75, 0.3)
		MonsterConfig.TYPE_SPIRIT:
			sprite.modulate = Color(0.9, 0.95, 1.0)
		_:
			sprite.modulate = Color(0.75, 0.75, 0.8)


func _nearest_enemy(range_max: float) -> Node2D:
	var nearest: Node2D = null
	var nearest_d: float = range_max
	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node):
			continue
		var d: float = global_position.distance_to(node.global_position)
		if d < nearest_d:
			nearest_d = d
			nearest = node as Node2D
	return nearest


func _try_auto_attack() -> void:
	var range_max: float = _data.get("auto_attack_range", 100.0)
	var nearest: Node2D = _nearest_enemy(range_max)
	if nearest == null:
		return
	var damage_amount: int = _data.get("auto_attack_damage", 1)
	var style: StringName = _data.get("attack_style", &"projectile")
	if style == &"melee":
		if nearest.has_method("take_damage"):
			nearest.take_damage(damage_amount, EnemyBase.DMG_FLAG_RAW)
			CombatEffects.apply_companion_projectile_hit(nearest, damage_amount, companion_id, true)
	else:
		var dir: Vector2 = (nearest.global_position - global_position).normalized()
		var proj: Area2D = PROJECTILE_SCENE.instantiate()
		proj.global_position = global_position
		proj.velocity = dir * _data.get("auto_attack_projectile_speed", 140.0)
		proj.damage = damage_amount
		proj.companion_id = companion_id
		get_tree().current_scene.add_child(proj)


func use_special(player_global_pos: Vector2, facing: Vector2) -> bool:
	if _special_timer > 0.0:
		return false
	_special_timer = float(_data.get("special_cooldown", 2.0))
	var rel: float = SecondaryItemConfig.get_special_cooldown_mult(GameState.secondary_item_id)
	_special_timer *= rel
	_do_special(player_global_pos, facing)
	return true


func _do_special(origin: Vector2, facing: Vector2) -> void:
	var dmg: int = int(_data.get("special_damage", 2))
	var radius: float = float(_data.get("special_radius", 48.0))
	match companion_id:
		&"fire_spirit":
			for i in 3:
				var proj: Area2D = PROJECTILE_SCENE.instantiate()
				var spread: float = (i - 1) * 0.15
				var dir: Vector2 = facing.rotated(spread).normalized()
				proj.global_position = origin + dir * 20.0
				proj.velocity = dir * 180.0
				proj.damage = dmg
				proj.companion_id = companion_id
				get_tree().current_scene.add_child(proj)
				await get_tree().create_timer(0.06).timeout
		&"shadow_moth":
			var proj: Area2D = PROJECTILE_SCENE.instantiate()
			proj.global_position = origin
			proj.velocity = facing.normalized() * 300.0
			proj.damage = dmg
			proj.companion_id = companion_id
			get_tree().current_scene.add_child(proj)
			proj.collision_mask = 2
		&"storm_jelly", &"spirit_globe":
			var proj: Area2D = PROJECTILE_SCENE.instantiate()
			proj.global_position = origin + facing.normalized() * 18.0
			proj.velocity = facing.normalized() * 200.0
			proj.damage = dmg
			proj.companion_id = companion_id
			get_tree().current_scene.add_child(proj)
			proj.collision_mask = 2
		_:
			_special_radius_damage(origin, radius, dmg)


func _special_radius_damage(origin: Vector2, radius: float, dmg: int) -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var e: Node2D = enemy as Node2D
		if origin.distance_to(e.global_position) > radius:
			continue
		if e.has_method("take_damage"):
			e.take_damage(dmg, EnemyBase.DMG_FLAG_RAW)
		CombatEffects.apply_companion_projectile_hit(e, dmg, companion_id, false)
