extends Control
## Hub town: class selection (first time), then select region. Shows only unlocked regions.

const FLOOR_TILE_ATLAS_PATH: String = "res://art/fd/tilesets/FD_Ground_Tiles.png"
const ICONS_ATLAS_PATH: String = "res://art/fd/icons/Fantasy_Dreamland_Icons_Transparent.png"

@onready var class_panel: Control = $MarginContainer/VBox/ClassPanel
@onready var region_panel: Control = $MarginContainer/VBox/RegionPanel
@onready var status_label: Label = $MarginContainer/VBox/StatusLabel
@onready var region_1_btn: Button = $MarginContainer/VBox/RegionPanel/Region1Button
@onready var region_2_btn: Button = $MarginContainer/VBox/RegionPanel/Region2Button
@onready var region_3_btn: Button = $MarginContainer/VBox/RegionPanel/Region3Button
@onready var region_4_btn: Button = $MarginContainer/VBox/RegionPanel/Region4Button
@onready var region_5_btn: Button = $MarginContainer/VBox/RegionPanel/Region5Button
@onready var region_6_btn: Button = $MarginContainer/VBox/RegionPanel/Region6Button
@onready var region_7_btn: Button = $MarginContainer/VBox/RegionPanel/Region7Button
@onready var region_8_btn: Button = $MarginContainer/VBox/RegionPanel/Region8Button
@onready var inventory_panel: Control = $MarginContainer/VBox/InventoryPanel
@onready var primary_label: Label = $MarginContainer/VBox/InventoryPanel/PrimaryRow/PrimaryLabel
@onready var secondary_label: Label = $MarginContainer/VBox/InventoryPanel/SecondaryRow/SecondaryLabel
@onready var cycle_primary_btn: Button = $MarginContainer/VBox/InventoryPanel/PrimaryRow/CyclePrimaryButton
@onready var cycle_secondary_btn: Button = $MarginContainer/VBox/InventoryPanel/SecondaryRow/CycleSecondaryButton
@onready var practice_arena_btn: Button = $MarginContainer/VBox/PracticeArenaButton
@onready var save_btn: Button = $MarginContainer/VBox/SaveRow/SaveButton
@onready var load_btn: Button = $MarginContainer/VBox/SaveRow/LoadButton
@onready var save_status_label: Label = $MarginContainer/VBox/SaveStatusLabel

func _ready() -> void:
	# Let clicks pass through to buttons (root Control can block otherwise)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Connect class buttons with explicit paths so they always work
	var tank_btn = get_node_or_null("MarginContainer/VBox/ClassPanel/TankButton")
	var healer_btn = get_node_or_null("MarginContainer/VBox/ClassPanel/HealerButton")
	var mage_btn = get_node_or_null("MarginContainer/VBox/ClassPanel/MageButton")
	var dps_btn = get_node_or_null("MarginContainer/VBox/ClassPanel/DpsButton")
	if tank_btn: tank_btn.pressed.connect(_on_tank_pressed)
	if healer_btn: healer_btn.pressed.connect(_on_healer_pressed)
	if mage_btn: mage_btn.pressed.connect(_on_mage_pressed)
	if dps_btn: dps_btn.pressed.connect(_on_dps_pressed)
	if region_1_btn: region_1_btn.pressed.connect(_on_region_1_pressed)
	if region_2_btn: region_2_btn.pressed.connect(_on_region_2_pressed)
	if region_3_btn: region_3_btn.pressed.connect(_on_region_3_pressed)
	if region_4_btn: region_4_btn.pressed.connect(_on_region_4_pressed)
	if region_5_btn: region_5_btn.pressed.connect(_on_region_5_pressed)
	if region_6_btn: region_6_btn.pressed.connect(_on_region_6_pressed)
	if region_7_btn: region_7_btn.pressed.connect(_on_region_7_pressed)
	if region_8_btn: region_8_btn.pressed.connect(_on_region_8_pressed)
	if cycle_primary_btn: cycle_primary_btn.pressed.connect(_on_cycle_primary_pressed)
	if cycle_secondary_btn: cycle_secondary_btn.pressed.connect(_on_cycle_secondary_pressed)
	if practice_arena_btn: practice_arena_btn.pressed.connect(_on_practice_arena_pressed)
	if save_btn: save_btn.pressed.connect(_on_save_pressed)
	if load_btn: load_btn.pressed.connect(_on_load_pressed)
	_build_hub_art_background()
	_refresh_layout()


func _refresh_layout() -> void:
	# Class pick is optional; hub is usable immediately (inventory + regions).
	if class_panel:
		class_panel.visible = false
	if region_panel:
		region_panel.visible = true
	if inventory_panel:
		inventory_panel.visible = true
	_update_region_buttons()
	_update_inventory_labels()
	_update_save_status()
	if status_label:
		var cls: String = str(GameState.player_class) if not GameState.player_class.is_empty() else "—"
		status_label.text = "HP: %d  Essence: %d  Lv.%d  Class: %s" % [GameState.get_player_max_health(), GameState.get_essence_count(), GameState.player_level, cls]


func _update_region_buttons() -> void:
	if region_1_btn: region_1_btn.visible = GameState.is_region_unlocked(1)
	if region_2_btn: region_2_btn.visible = GameState.is_region_unlocked(2)
	if region_3_btn: region_3_btn.visible = GameState.is_region_unlocked(3)
	if region_4_btn: region_4_btn.visible = GameState.is_region_unlocked(4)
	if region_5_btn: region_5_btn.visible = GameState.is_region_unlocked(5)
	if region_6_btn: region_6_btn.visible = GameState.is_region_unlocked(6)
	if region_7_btn: region_7_btn.visible = GameState.is_region_unlocked(7)
	if region_8_btn: region_8_btn.visible = GameState.is_region_unlocked(8)


func _on_tank_pressed() -> void: GameState.set_player_class(&"tank"); _refresh_layout()
func _on_healer_pressed() -> void: GameState.set_player_class(&"healer"); _refresh_layout()
func _on_mage_pressed() -> void: GameState.set_player_class(&"mage"); _refresh_layout()
func _on_dps_pressed() -> void: GameState.set_player_class(&"dps"); _refresh_layout()


func _on_region_1_pressed() -> void: _enter_region(1)
func _on_region_2_pressed() -> void: _enter_region(2)
func _on_region_3_pressed() -> void: _enter_region(3)
func _on_region_4_pressed() -> void: _enter_region(4)
func _on_region_5_pressed() -> void: _enter_region(5)
func _on_region_6_pressed() -> void: _enter_region(6)
func _on_region_7_pressed() -> void: _enter_region(7)
func _on_region_8_pressed() -> void: _enter_region(8)


func _enter_region(region: int) -> void:
	AudioManager.play_ui()
	GameState.current_region = region
	GameState.current_stage_index = 0
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/stages/stage.tscn")


func _on_practice_arena_pressed() -> void:
	AudioManager.play_ui()
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/main/test_arena.tscn")


func _on_save_pressed() -> void:
	AudioManager.play_ui()
	var ok: bool = SaveSystem.save_game()
	if save_status_label:
		save_status_label.text = "Save: %s" % ("progress saved" if ok else "failed")


func _on_load_pressed() -> void:
	AudioManager.play_ui()
	var ok: bool = SaveSystem.load_game()
	if ok:
		_refresh_layout()
	if save_status_label:
		save_status_label.text = "Save: %s" % ("loaded from disk" if ok else "no save found")


func _update_save_status() -> void:
	if save_status_label:
		save_status_label.text = "Save: %s" % ("file detected" if SaveSystem.has_save() else "no file yet")


func _update_inventory_labels() -> void:
	if primary_label:
		primary_label.text = "Primary: %s" % (_item_display_name(GameState.primary_item_id))
	if secondary_label:
		secondary_label.text = "Secondary: %s" % (_item_display_name(GameState.secondary_item_id))
	_set_item_icon("MarginContainer/VBox/InventoryPanel/PrimaryRow/PrimaryIcon", GameState.primary_item_id, true)
	_set_item_icon("MarginContainer/VBox/InventoryPanel/SecondaryRow/SecondaryIcon", GameState.secondary_item_id, false)


func _build_hub_art_background() -> void:
	var atlas: Texture2D = load(FLOOR_TILE_ATLAS_PATH) as Texture2D
	if atlas == null:
		return
	var old := get_node_or_null("ArtTiles")
	if old:
		old.queue_free()
	var root := Node2D.new()
	root.name = "ArtTiles"
	root.z_index = -1
	add_child(root)
	var tile_size := Vector2(16, 16)
	var cols: int = 26
	var rows: int = 16
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
			s.modulate = Color(1, 1, 1, 0.35)
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


func _item_display_name(item_id: StringName) -> String:
	if item_id.is_empty():
		return "(none)"
	var wn: String = WeaponConfig.get_display_name(item_id)
	if wn != str(item_id):
		return wn
	var sn: String = SecondaryItemConfig.get_display_name(item_id)
	if sn != str(item_id):
		return sn
	return ItemConfig.get_display_name(item_id)


func _on_cycle_primary_pressed() -> void:
	AudioManager.play_ui()
	var list: Array[StringName] = _primary_cycle_ids()
	if list.is_empty():
		return
	var idx: int = list.find(GameState.primary_item_id)
	if idx < 0:
		idx = 0
	idx = (idx + 1) % list.size()
	GameState.equip_primary(list[idx])
	_update_inventory_labels()


func _on_cycle_secondary_pressed() -> void:
	AudioManager.play_ui()
	var list: Array[StringName] = _secondary_cycle_ids()
	if list.is_empty():
		return
	var idx: int = list.find(GameState.secondary_item_id)
	if idx < 0:
		idx = 0
	idx = (idx + 1) % list.size()
	GameState.equip_secondary(list[idx])
	_update_inventory_labels()


func _primary_cycle_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	var seen: Dictionary = {}
	for id in WeaponConfig.WEAPON_IDS:
		out.append(id)
		seen[id] = true
	for s in GameState.inventory:
		var sid: StringName = StringName(s)
		if WeaponConfig.DATA.has(sid) and not seen.has(sid):
			out.append(sid)
			seen[sid] = true
	return out


func _secondary_cycle_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	var seen: Dictionary = {}
	out.append(&"")
	seen[&""] = true
	for id in SecondaryItemConfig.ITEM_IDS:
		out.append(id)
		seen[id] = true
	for s in GameState.inventory:
		var sid: StringName = StringName(s)
		if SecondaryItemConfig.DATA.has(sid) and not seen.has(sid):
			out.append(sid)
			seen[sid] = true
	return out


func _process(_delta: float) -> void:
	if status_label:
		var cls: String = str(GameState.player_class) if not GameState.player_class.is_empty() else "—"
		status_label.text = "HP: %d  Essence: %d  Lv.%d  Class: %s" % [GameState.get_player_max_health(), GameState.get_essence_count(), GameState.player_level, cls]
	_update_save_status()
