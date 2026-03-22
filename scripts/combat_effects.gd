extends Node
## M3: Applies monster-type effects after player/companion hits (per client spec).

const CHAIN_RANGE_PX: float = 64.0
const CHAIN_MAX_TARGETS: int = 3
const CHAIN_DAMAGE_MULT: float = 0.5
const CHAIN_DELAY_SEC: float = 0.1


func apply_player_melee_effects(player: Node2D, primary_target: Node2D, base_attack_damage: int, dealt_damage: int, allow_storm_chain: bool = true) -> void:
	if not is_instance_valid(primary_target) or not primary_target.is_in_group("enemy"):
		return
	var mid: StringName = GameState.active_companion_id
	var mtype: StringName = MonsterConfig.get_monster_type(mid)
	var enemy: EnemyBase = primary_target as EnemyBase
	if enemy == null:
		return

	if player.has_method("is_shadow_dodge_window_active") and player.is_shadow_dodge_window_active():
		enemy.apply_shadow_mark()

	match mtype:
		MonsterConfig.TYPE_FIRE:
			enemy.apply_burn_from_spec(base_attack_damage)
		MonsterConfig.TYPE_FROST:
			enemy.apply_freeze_from_spec()
		MonsterConfig.TYPE_POISON:
			enemy.apply_poison_from_spec(base_attack_damage)
		MonsterConfig.TYPE_STORM:
			if allow_storm_chain:
				call_deferred("_storm_chain_start", primary_target, dealt_damage)
		MonsterConfig.TYPE_STONE:
			enemy.apply_stone_on_hit_from_spec(player.global_position)
		MonsterConfig.TYPE_SHADOW:
			pass
		MonsterConfig.TYPE_NATURE:
			enemy.apply_nature_root_from_spec()
		MonsterConfig.TYPE_SPIRIT:
			pass
		MonsterConfig.TYPE_NEUTRAL:
			enemy.apply_expose_from_spec()


func apply_companion_projectile_hit(enemy: Node2D, damage_amount: int, companion_id: StringName, allow_storm_chain: bool = true) -> void:
	if not enemy.is_in_group("enemy"):
		return
	var eb: EnemyBase = enemy as EnemyBase
	if eb == null:
		return
	var mtype: StringName = MonsterConfig.get_monster_type(companion_id)
	match mtype:
		MonsterConfig.TYPE_FIRE:
			eb.apply_burn_from_spec(damage_amount)
		MonsterConfig.TYPE_FROST:
			eb.apply_freeze_from_spec()
		MonsterConfig.TYPE_POISON:
			eb.apply_poison_from_spec(damage_amount)
		MonsterConfig.TYPE_STORM:
			if allow_storm_chain:
				call_deferred("_storm_chain_start", enemy, damage_amount)
		MonsterConfig.TYPE_STONE:
			eb.apply_stone_on_hit_from_spec(enemy.global_position + Vector2(40, 0))
		MonsterConfig.TYPE_NATURE:
			eb.apply_nature_root_from_spec()
		MonsterConfig.TYPE_NEUTRAL:
			eb.apply_expose_from_spec()
		_:
			pass


func _storm_chain_start(first_target: Node2D, source_damage: int) -> void:
	await _run_storm_chain(first_target, source_damage)


func _run_storm_chain(first_target: Node2D, source_damage: int) -> void:
	if not is_instance_valid(first_target):
		return
	var dmg: int = maxi(1, int(ceil(source_damage * CHAIN_DAMAGE_MULT)))
	var hit_list: Array[Node2D] = [first_target]
	var from_pos: Vector2 = first_target.global_position
	for _i in CHAIN_MAX_TARGETS:
		await get_tree().create_timer(CHAIN_DELAY_SEC).timeout
		var next_enemy: Node2D = _find_chain_target(from_pos, hit_list)
		if next_enemy == null or not is_instance_valid(next_enemy):
			break
		if next_enemy.has_method("take_damage"):
			next_enemy.take_damage(dmg, EnemyBase.DMG_FLAG_RAW)
		hit_list.append(next_enemy)
		from_pos = next_enemy.global_position


func _find_chain_target(from_pos: Vector2, exclude: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_d: float = CHAIN_RANGE_PX + 1.0
	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node):
			continue
		var n: Node2D = node as Node2D
		if n in exclude:
			continue
		var d: float = from_pos.distance_to(n.global_position)
		if d <= CHAIN_RANGE_PX and d < best_d:
			best_d = d
			best = n
	return best
