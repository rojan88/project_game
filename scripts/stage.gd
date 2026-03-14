extends Node2D
## Generic stage: spawns enemies from StageConfig, detects clear, gives rewards, goes to next stage or hub.

@export var essence_pickup_scene: PackedScene
var _spawn_position: Vector2
var _player: Node2D
var _enemies_container: Node2D
var _cleared: bool = false
var _initial_enemy_count: int = 0

func _ready() -> void:
	var marker = get_node_or_null("RespawnPosition")
	if marker:
		_spawn_position = marker.global_position
	else:
		_spawn_position = Vector2(192, 108)

	_enemies_container = get_node_or_null("Enemies")
	if _enemies_container == null:
		_enemies_container = Node2D.new()
		add_child(_enemies_container)
		_enemies_container.name = "Enemies"

	# Clear placeholder children from Enemies (if any from scene) and spawn from config
	for c in _enemies_container.get_children():
		c.queue_free()

	var spawns: Array = StageConfig.get_enemy_spawns(GameState.current_region, GameState.current_stage_index)
	for entry in spawns:
		var path: String = entry.get("scene", "")
		var pos: Vector2 = entry.get("position", _spawn_position)
		if path.is_empty():
			continue
		var scene: PackedScene = load(path) as PackedScene
		if scene:
			var enemy: Node2D = scene.instantiate()
			_enemies_container.add_child(enemy)
			enemy.global_position = pos
			if enemy.has_signal("essence_dropped"):
				enemy.essence_dropped.connect(_spawn_essence)
	_initial_enemy_count = spawns.size()

	_player = get_node_or_null("Player")
	if _player != null:
		_player.max_health = GameState.get_player_max_health()
		_player.current_health = GameState.get_player_max_health()
		if _player.global_position.distance_to(_spawn_position) > 1.0:
			_player.global_position = _spawn_position

	if essence_pickup_scene == null:
		essence_pickup_scene = load("res://scenes/items/essence_pickup.tscn") as PackedScene


func _process(_delta: float) -> void:
	_update_hud()
	if _cleared:
		return
	if _initial_enemy_count <= 0:
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	var count: int = 0
	for e in enemies:
		if is_instance_valid(e):
			count += 1
	if count > 0:
		return
	_on_stage_cleared()


func _update_hud() -> void:
	if _player != null and is_instance_valid(_player):
		var hl = get_node_or_null("UI/HealthLabel")
		if hl is Label:
			hl.text = "HP: %d" % _player.current_health
		var enl = get_node_or_null("UI/EnergyLabel")
		if enl is Label and "current_energy" in _player and "max_energy" in _player:
			enl.text = "Energy: %d/%d" % [_player.current_energy, _player.max_energy]
	var el = get_node_or_null("UI/EssenceLabel")
	if el is Label:
		el.text = "Essence: %d" % GameState.get_essence_count()
	var cl = get_node_or_null("UI/CompanionLabel")
	if cl is Label:
		if GameState.active_companion_id.is_empty():
			cl.text = "Companion: (U unlock: 3)"
		else:
			var name_str: String = CompanionConfig.get_display_name(GameState.active_companion_id)
			var lv: int = GameState.get_companion_level(GameState.active_companion_id)
			cl.text = "Companion: %s Lv.%d" % [name_str, lv]


func _on_stage_cleared() -> void:
	_cleared = true
	# Reward: player exp
	var exp_reward: int = 5 + GameState.current_stage_index * 3
	if StageConfig.is_boss_stage(GameState.current_region, GameState.current_stage_index):
		exp_reward += 10
	GameState.add_player_exp(exp_reward)
	GameState.clear_stage(GameState.current_region, GameState.current_stage_index)
	var next_scene: String = GameState.get_next_stage_after_clear(GameState.current_region, GameState.current_stage_index)
	# Show "Stage clear!" with pop (M5.3 juice)
	var label = get_node_or_null("UI/StageClearLabel")
	if label is Label:
		label.visible = true
		label.text = "Stage clear!"
		label.scale = Vector2(0.5, 0.5)
		var tween := create_tween()
		tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)
		tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	await get_tree().create_timer(1.5).timeout
	if next_scene.ends_with("hub.tscn"):
		get_tree().change_scene_to_file(next_scene)
	else:
		GameState.current_stage_index += 1
		get_tree().change_scene_to_file(next_scene)


func respawn_player(player: Node2D) -> void:
	if player.has_method("reset_for_respawn"):
		player.reset_for_respawn(_spawn_position)


func _spawn_essence(at_position: Vector2, essence_type: StringName) -> void:
	# Quick death sparkle (juice)
	var eff = Node2D.new()
	var spr = Sprite2D.new()
	spr.texture = load("res://icon.svg") as Texture2D
	spr.modulate = Color(1, 0.9, 0.5, 0.9)
	spr.scale = Vector2(0.15, 0.15)
	eff.add_child(spr)
	add_child(eff)
	eff.global_position = at_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(spr, "scale", Vector2(0.05, 0.05), 0.25)
	tween.tween_property(spr, "modulate", Color(1, 0.9, 0.5, 0), 0.25)
	tween.chain().tween_callback(eff.queue_free)
	if essence_pickup_scene == null:
		return
	var pickup = essence_pickup_scene.instantiate()
	if "essence_type" in pickup:
		pickup.essence_type = essence_type
	add_child(pickup)
	pickup.global_position = at_position
