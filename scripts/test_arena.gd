extends Node2D
## M2: One test stage — enter, fight telegraphed enemies, collect essence. Respawn on death.

@export var essence_pickup_scene: PackedScene
var _spawn_position: Vector2
var _player: Node2D
var _cleared_shown: bool = false

func _ready() -> void:
	var marker = get_node_or_null("RespawnPosition")
	if marker:
		_spawn_position = marker.global_position
	else:
		_spawn_position = Vector2(192, 108)

	_player = get_node_or_null("Player")
	if _player == null and has_node("Player"):
		_player = $Player

	if essence_pickup_scene == null:
		essence_pickup_scene = load("res://scenes/items/essence_pickup.tscn") as PackedScene
	for node in get_tree().get_nodes_in_group("enemy"):
		if node.has_signal("essence_dropped"):
			node.essence_dropped.connect(_spawn_essence)

	if GameState.essence_changed.is_connected(_update_essence_label) == false:
		GameState.essence_changed.connect(_update_essence_label)
	_update_essence_label(0, &"")


func respawn_player(player: Node2D) -> void:
	if player.has_method("reset_for_respawn"):
		player.reset_for_respawn(_spawn_position)


func _spawn_essence(at_position: Vector2, essence_type: StringName) -> void:
	if essence_pickup_scene == null:
		return
	var pickup = essence_pickup_scene.instantiate()
	if "essence_type" in pickup:
		pickup.essence_type = essence_type
	add_child(pickup)
	pickup.global_position = at_position


func _update_essence_label(_total: int, _type: StringName) -> void:
	var el = get_node_or_null("UI/EssenceLabel")
	if el is Label:
		el.text = "Essence: %d" % GameState.get_essence_count()
	var ml = get_node_or_null("UI/MonsterLabel")
	if ml is Label:
		var mid: StringName = GameState.active_companion_id
		if mid.is_empty():
			ml.text = "Monster: —"
		else:
			ml.text = "Monster: %s" % MonsterConfig.get_display_name(mid)


func _process(_delta: float) -> void:
	if _player != null and is_instance_valid(_player):
		var hl = get_node_or_null("UI/HealthLabel")
		if hl is Label:
			hl.text = "HP: %d" % _player.current_health
		var enl = get_node_or_null("UI/EnergyLabel")
		if enl is Label and "current_energy" in _player and "max_energy" in _player:
			enl.text = "Energy: %d/%d" % [_player.current_energy, _player.max_energy]
	_update_essence_label(0, &"")

	# M2.5: Show "Enemies cleared!" when all enemies defeated
	var enemies = get_tree().get_nodes_in_group("enemy")
	var count := 0
	for e in enemies:
		if is_instance_valid(e):
			count += 1
	if count == 0 and not _cleared_shown:
		_cleared_shown = true
		var cl = get_node_or_null("UI/ClearedLabel")
		if cl is Label:
			cl.visible = true
