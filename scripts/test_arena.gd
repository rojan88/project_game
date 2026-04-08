extends Node2D
## Test arena: combat loop + in-fight equipment swap (M3 QA) + pause save/load (M4).

@export var essence_pickup_scene: PackedScene
const FLOOR_TILE_ATLAS_PATH: String = "res://art/fd/tilesets/FD_Ground_Tiles.png"
const ICONS_ATLAS_PATH: String = "res://art/fd/icons/Fantasy_Dreamland_Icons_Transparent.png"
var _spawn_position: Vector2
var _player: Node2D
var _cleared_shown: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	if GameState.equipment_changed.is_connected(_refresh_equipment_labels) == false:
		GameState.equipment_changed.connect(_refresh_equipment_labels)
	_update_essence_label(0, &"")
	_refresh_equipment_labels()
	_build_art_floor()

	var hub_btn = get_node_or_null("UI/HubButton")
	if hub_btn is Button:
		hub_btn.pressed.connect(_on_hub_pressed)
	var w_prev = get_node_or_null("UI/EquipmentPanel/WeaponRow/WeaponPrev")
	var w_next = get_node_or_null("UI/EquipmentPanel/WeaponRow/WeaponNext")
	var s_prev = get_node_or_null("UI/EquipmentPanel/SecondaryRow/SecondaryPrev")
	var s_next = get_node_or_null("UI/EquipmentPanel/SecondaryRow/SecondaryNext")
	if w_prev is Button:
		w_prev.pressed.connect(_cycle_weapon.bind(-1))
	if w_next is Button:
		w_next.pressed.connect(_cycle_weapon.bind(1))
	if s_prev is Button:
		s_prev.pressed.connect(_cycle_secondary.bind(-1))
	if s_next is Button:
		s_next.pressed.connect(_cycle_secondary.bind(1))

	var resume = get_node_or_null("PauseMenu/VBox/ResumeButton")
	var save_b = get_node_or_null("PauseMenu/VBox/SaveButton")
	var load_b = get_node_or_null("PauseMenu/VBox/LoadButton")
	var hub_pb = get_node_or_null("PauseMenu/VBox/HubPauseButton")
	if resume is Button:
		resume.pressed.connect(_resume_pause)
	if save_b is Button:
		save_b.pressed.connect(_pause_save)
	if load_b is Button:
		load_b.pressed.connect(_pause_load)
	if hub_pb is Button:
		hub_pb.pressed.connect(_return_hub_from_pause)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused:
		return
	if event.is_action_pressed("equip_weapon_prev"):
		_cycle_weapon(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("equip_weapon_next"):
		_cycle_weapon(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("equip_secondary_prev"):
		_cycle_secondary(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("equip_secondary_next"):
		_cycle_secondary(1)
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	var p: bool = not get_tree().paused
	get_tree().paused = p
	var pm = get_node_or_null("PauseMenu")
	if pm:
		pm.visible = p
	if p:
		AudioManager.play_ui()


func _resume_pause() -> void:
	AudioManager.play_ui()
	get_tree().paused = false
	var pm = get_node_or_null("PauseMenu")
	if pm:
		pm.visible = false


func _pause_save() -> void:
	AudioManager.play_ui()
	SaveSystem.save_game()


func _pause_load() -> void:
	AudioManager.play_ui()
	SaveSystem.load_game()
	_refresh_equipment_labels()
	_update_essence_label(0, &"")


func _return_hub_from_pause() -> void:
	AudioManager.play_ui()
	get_tree().paused = false
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/hub/hub.tscn")


func _on_hub_pressed() -> void:
	AudioManager.play_ui()
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/hub/hub.tscn")


func _weapon_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for id in WeaponConfig.WEAPON_IDS:
		out.append(id)
	return out


func _secondary_ids() -> Array[StringName]:
	var out: Array[StringName] = [&""]
	for id in SecondaryItemConfig.ITEM_IDS:
		out.append(id)
	return out


func _cycle_weapon(delta_idx: int) -> void:
	var list: Array[StringName] = _weapon_ids()
	if list.is_empty():
		return
	var idx: int = list.find(GameState.main_weapon_id)
	if idx < 0:
		idx = 0
	idx = posmod(idx + delta_idx, list.size())
	GameState.equip_main_weapon(list[idx])
	AudioManager.play_ui()
	_refresh_equipment_labels()


func _cycle_secondary(delta_idx: int) -> void:
	var list: Array[StringName] = _secondary_ids()
	var idx: int = list.find(GameState.secondary_item_id)
	if idx < 0:
		idx = 0
	idx = posmod(idx + delta_idx, list.size())
	GameState.equip_secondary_item(list[idx])
	AudioManager.play_ui()
	_refresh_equipment_labels()


func _display_weapon(id: StringName) -> String:
	if id.is_empty():
		return "(none)"
	return WeaponConfig.get_display_name(id)


func _display_secondary(id: StringName) -> String:
	if id.is_empty():
		return "(none)"
	return SecondaryItemConfig.get_display_name(id)


func _refresh_equipment_labels() -> void:
	var wl = get_node_or_null("UI/EquipmentPanel/WeaponRow/WeaponLabel")
	if wl is Label:
		wl.text = "Weapon: %s" % _display_weapon(GameState.main_weapon_id)
	_set_item_icon("UI/EquipmentPanel/WeaponRow/WeaponIcon", GameState.main_weapon_id, true)
	var sl = get_node_or_null("UI/EquipmentPanel/SecondaryRow/SecondaryLabel")
	if sl is Label:
		sl.text = "Secondary: %s" % _display_secondary(GameState.secondary_item_id)
	_set_item_icon("UI/EquipmentPanel/SecondaryRow/SecondaryIcon", GameState.secondary_item_id, false)


func _build_art_floor() -> void:
	var atlas: Texture2D = load(FLOOR_TILE_ATLAS_PATH) as Texture2D
	if atlas == null:
		return
	var old := get_node_or_null("ArtFloor")
	if old:
		old.queue_free()
	var root := Node2D.new()
	root.name = "ArtFloor"
	root.z_index = -25
	add_child(root)
	var cols: int = 26
	var rows: int = 16
	var tile_size := Vector2(16, 16)
	var pattern: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 1), Vector2i(1, 1)]
	for y in rows:
		for x in cols:
			var at := AtlasTexture.new()
			at.atlas = atlas
			var pick: Vector2i = pattern[(x + y * 2) % pattern.size()]
			at.region = Rect2(pick.x * tile_size.x, pick.y * tile_size.y, tile_size.x, tile_size.y)
			var s := Sprite2D.new()
			s.centered = false
			s.texture = at
			s.position = Vector2(-16 + x * tile_size.x, -16 + y * tile_size.y)
			root.add_child(s)


func _set_item_icon(node_path: String, item_id: StringName, is_weapon: bool) -> void:
	var icon_node := get_node_or_null(node_path)
	if icon_node == null or not (icon_node is TextureRect):
		return
	var atlas: Texture2D = load(ICONS_ATLAS_PATH) as Texture2D
	if atlas == null:
		return
	var rect := Rect2(0, 0, 16, 16)
	if is_weapon:
		match String(item_id):
			"sword": rect = Rect2(16, 0, 16, 16)
			"dagger": rect = Rect2(32, 0, 16, 16)
			"spear": rect = Rect2(48, 0, 16, 16)
			"greatsword": rect = Rect2(64, 0, 16, 16)
			_: rect = Rect2(16, 0, 16, 16)
	else:
		if item_id.is_empty():
			rect = Rect2(0, 0, 16, 16)
		else:
			match String(item_id):
				"boots": rect = Rect2(0, 16, 16, 16)
				"charm": rect = Rect2(16, 16, 16, 16)
				"relic": rect = Rect2(32, 16, 16, 16)
				"band": rect = Rect2(48, 16, 16, 16)
				"focus_crystal": rect = Rect2(64, 16, 16, 16)
				_: rect = Rect2(0, 16, 16, 16)
	var at := AtlasTexture.new()
	at.atlas = atlas
	at.region = rect
	(icon_node as TextureRect).texture = at


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
