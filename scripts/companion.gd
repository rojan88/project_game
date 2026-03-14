extends Node2D
## One active companion: follows player, auto-attacks nearest enemy, provides special ability.
## Companion type comes from GameState.active_companion_id.

var companion_id: StringName = &""
var _player: Node2D
var _auto_timer: float = 0.0
var _special_timer: float = 0.0
var _data: Dictionary = {}

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/companions/companion_projectile.tscn")

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null


func _ready() -> void:
	companion_id = GameState.active_companion_id
	_data = CompanionConfig.get_data(companion_id)
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null and get_parent() != null:
		_player = get_parent().get_parent() as Node2D
	_update_visual()
	_auto_timer = 0.0
	_special_timer = 0.0


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	# Follow player with offset (orbit slightly to the side)
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
	match companion_id:
		&"fire_spirit":
			sprite.modulate = Color(1, 0.5, 0.2)
		&"stone_golem":
			sprite.modulate = Color(0.6, 0.55, 0.5)
		&"bat":
			sprite.modulate = Color(0.4, 0.3, 0.6)
		&"plant_sprite":
			sprite.modulate = Color(0.3, 0.8, 0.25)
		&"ghost":
			sprite.modulate = Color(0.7, 0.6, 1.0)
		_:
			sprite.modulate = Color.WHITE


func _try_auto_attack() -> void:
	var tree := get_tree()
	if not tree.has_group("enemy"):
		return
	var enemies: Array = tree.get_nodes_in_group("enemy")
	var range_max: float = _data.get("auto_attack_range", 100.0)
	var nearest: Node2D = null
	var nearest_d: float = range_max
	for node in enemies:
		if not is_instance_valid(node):
			continue
		var d: float = global_position.distance_to(node.global_position)
		if d < nearest_d:
			nearest_d = d
			nearest = node as Node2D
	if nearest == null:
		return

	# Combat doc: Monsters do not level up — use base damage only
	var damage_amount: int = _data.get("auto_attack_damage", 1)

	match companion_id:
		&"fire_spirit":
			_fire_spirit_auto(nearest, damage_amount)
		&"stone_golem":
			_stone_golem_auto(nearest, damage_amount)
		&"bat":
			_bat_auto(nearest, damage_amount)
		&"plant_sprite":
			_plant_sprite_auto(nearest, damage_amount)
		&"ghost":
			_ghost_auto(nearest, damage_amount)


func _fire_spirit_auto(target: Node2D, damage_amount: int) -> void:
	var dir: Vector2 = (target.global_position - global_position).normalized()
	var proj: Area2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = global_position
	proj.velocity = dir * _data.get("auto_attack_projectile_speed", 140.0)
	proj.damage = damage_amount
	proj.companion_id = companion_id
	get_tree().current_scene.add_child(proj)


func _stone_golem_auto(target: Node2D, damage_amount: int) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage_amount)


func _bat_auto(target: Node2D, damage_amount: int) -> void:
	# Small projectile
	var dir: Vector2 = (target.global_position - global_position).normalized()
	var proj: Area2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = global_position
	proj.velocity = dir * 160.0
	proj.damage = damage_amount
	proj.companion_id = companion_id
	get_tree().current_scene.add_child(proj)


func use_special(player_global_pos: Vector2, facing: Vector2) -> bool:
	if _special_timer > 0.0:
		return false
	var cooldown: float = _data.get("special_cooldown", 2.0)
	_special_timer = cooldown

	match companion_id:
		&"fire_spirit":
			_fire_spirit_special(player_global_pos, facing)
		&"stone_golem":
			_stone_golem_special(player_global_pos)
		&"bat":
			_bat_special(player_global_pos, facing)
		&"plant_sprite":
			_plant_sprite_special(player_global_pos)
		&"ghost":
			_ghost_special(player_global_pos, facing)
		_:
			return false
	return true


func _fire_spirit_special(origin: Vector2, facing: Vector2) -> void:
	var damage_amount: int = _data.get("special_damage", 2)
	for i in 3:
		var proj: Area2D = PROJECTILE_SCENE.instantiate()
		var spread: float = (i - 1) * 0.15
		var dir: Vector2 = facing.rotated(spread).normalized()
		proj.global_position = origin + dir * 20.0
		proj.velocity = dir * 180.0
		proj.damage = damage_amount
		proj.companion_id = companion_id
		get_tree().current_scene.add_child(proj)
		await get_tree().create_timer(0.06).timeout


func _stone_golem_special(origin: Vector2) -> void:
	var damage_amount: int = _data.get("special_damage", 3)
	var radius: float = _data.get("special_radius", 50.0)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var e: Node2D = enemy as Node2D
		if origin.distance_to(e.global_position) <= radius and e.has_method("take_damage"):
			e.take_damage(damage_amount)


func _bat_special(origin: Vector2, facing: Vector2) -> void:
	var damage_amount: int = _data.get("special_damage", 2)
	var proj: Area2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = origin
	proj.velocity = facing.normalized() * 320.0
	proj.damage = damage_amount
	proj.companion_id = companion_id
	get_tree().current_scene.add_child(proj)
	proj.collision_mask = 2

func _plant_sprite_auto(target: Node2D, damage_amount: int) -> void:
	var dir: Vector2 = (target.global_position - global_position).normalized()
	var proj: Area2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = global_position
	proj.velocity = dir * _data.get("auto_attack_projectile_speed", 120.0)
	proj.damage = damage_amount
	proj.companion_id = companion_id
	proj.status_effect = &"poison"
	proj.status_duration = 3.0
	get_tree().current_scene.add_child(proj)

func _plant_sprite_special(origin: Vector2) -> void:
	var damage_amount: int = _data.get("special_damage", 2)
	var radius: float = _data.get("special_radius", 55.0)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var e: Node2D = enemy as Node2D
		if origin.distance_to(e.global_position) <= radius:
			if e.has_method("take_damage"):
				e.take_damage(damage_amount)
			if e.has_method("add_status"):
				e.add_status(&"poison", 4.0)

func _ghost_auto(target: Node2D, damage_amount: int) -> void:
	var dir: Vector2 = (target.global_position - global_position).normalized()
	var proj: Area2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = global_position
	proj.velocity = dir * _data.get("auto_attack_projectile_speed", 150.0)
	proj.damage = damage_amount
	proj.companion_id = companion_id
	get_tree().current_scene.add_child(proj)

func _ghost_special(origin: Vector2, facing: Vector2) -> void:
	var damage_amount: int = _data.get("special_damage", 2)
	var proj: Area2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = origin + facing.normalized() * 20.0
	proj.velocity = facing.normalized() * 220.0
	proj.damage = damage_amount
	proj.companion_id = companion_id
	get_tree().current_scene.add_child(proj)
	proj.collision_mask = 2
