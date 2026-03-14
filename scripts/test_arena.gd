extends Node2D
## Test arena (M1): player move, attack, dodge. Respawn on death. Optional enemies for combat testing.

@export var essence_pickup_scene: PackedScene
var _spawn_position: Vector2
var _player: Node2D

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


func respawn_player(player: Node2D) -> void:
	if player.has_method("reset_for_respawn"):
		player.reset_for_respawn(_spawn_position)


func _process(_delta: float) -> void:
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
