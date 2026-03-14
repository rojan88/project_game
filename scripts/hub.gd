extends Control
## Hub town: class selection (first time), then select region. Shows only unlocked regions.

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
	_refresh_layout()


func _refresh_layout() -> void:
	var need_class: bool = GameState.player_class.is_empty()
	if class_panel:
		class_panel.visible = need_class
	if region_panel:
		region_panel.visible = not need_class
	if inventory_panel:
		inventory_panel.visible = not need_class
	_update_region_buttons()
	_update_inventory_labels()
	if status_label:
		status_label.text = "HP: %d  Essence: %d  Lv.%d  Class: %s" % [GameState.get_player_max_health(), GameState.get_essence_count(), GameState.player_level, GameState.player_class if not GameState.player_class.is_empty() else "—"]


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
	GameState.current_region = region
	GameState.current_stage_index = 0
	get_tree().change_scene_to_file("res://scenes/stages/stage.tscn")


func _update_inventory_labels() -> void:
	if primary_label:
		primary_label.text = "Primary: %s" % (_item_display_name(GameState.primary_item_id))
	if secondary_label:
		secondary_label.text = "Secondary: %s" % (_item_display_name(GameState.secondary_item_id))


func _item_display_name(item_id: StringName) -> String:
	if item_id.is_empty():
		return "(none)"
	return ItemConfig.get_display_name(item_id)


func _on_cycle_primary_pressed() -> void:
	var list: Array[StringName] = _inventory_list_with_empty()
	if list.is_empty():
		return
	var current: String = String(GameState.primary_item_id)
	var idx: int = list.find(StringName(current))
	if idx < 0:
		idx = 0
	idx = (idx + 1) % list.size()
	GameState.equip_primary(list[idx])
	_update_inventory_labels()


func _on_cycle_secondary_pressed() -> void:
	var list: Array[StringName] = _inventory_list_with_empty()
	if list.is_empty():
		return
	var current: String = String(GameState.secondary_item_id)
	var idx: int = list.find(StringName(current))
	if idx < 0:
		idx = 0
	idx = (idx + 1) % list.size()
	GameState.equip_secondary(list[idx])
	_update_inventory_labels()


func _inventory_list_with_empty() -> Array[StringName]:
	var out: Array[StringName] = [&""]
	for s in GameState.inventory:
		out.append(StringName(s))
	return out


func _process(_delta: float) -> void:
	if status_label and (region_panel == null or region_panel.visible):
		status_label.text = "HP: %d  Essence: %d  Lv.%d  Class: %s" % [GameState.get_player_max_health(), GameState.get_essence_count(), GameState.player_level, GameState.player_class if not GameState.player_class.is_empty() else "—"]
