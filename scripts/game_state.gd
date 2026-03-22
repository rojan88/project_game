extends Node
## M3: Essence, equipment (weapon + secondary), active monster companion.

signal essence_changed(total: int, type: StringName)
signal companion_unlocked(companion_id: StringName)
signal active_companion_changed(companion_id: StringName)

var essence_count: int = 0
var essence_by_type: Dictionary = {}

func add_essence(type: StringName = &"common") -> void:
	essence_count += 1
	if not essence_by_type.has(type):
		essence_by_type[type] = 0
	essence_by_type[type] += 1
	essence_changed.emit(essence_count, type)


func get_essence_count() -> int:
	return essence_count


func get_essence_for_type(type: StringName) -> int:
	return essence_by_type.get(type, 0)


var unlocked_monsters: Array[StringName] = []
var active_companion_id: StringName = &""


func _ready() -> void:
	if unlocked_monsters.is_empty():
		unlocked_monsters.append(&"neutral_blob")
		set_active_companion(&"neutral_blob")


func is_monster_unlocked(id: StringName) -> bool:
	return id in unlocked_monsters


func try_unlock_monster(id: StringName) -> bool:
	if id in unlocked_monsters:
		return true
	var cost: int = MonsterConfig.get_essence_cost(id)
	if essence_count < cost:
		return false
	essence_count -= cost
	unlocked_monsters.append(id)
	essence_changed.emit(essence_count, &"")
	companion_unlocked.emit(id)
	if active_companion_id.is_empty():
		set_active_companion(id)
	return true


func set_active_companion(id: StringName) -> void:
	if not id.is_empty() and id not in unlocked_monsters:
		return
	active_companion_id = id
	active_companion_changed.emit(id)


func get_next_unlocked_monster() -> StringName:
	if unlocked_monsters.is_empty():
		return &""
	var idx: int = unlocked_monsters.find(active_companion_id)
	if idx < 0:
		return unlocked_monsters[0]
	idx = (idx + 1) % unlocked_monsters.size()
	return unlocked_monsters[idx]


func get_player_max_health() -> int:
	var bonus: int = SecondaryItemConfig.get_max_health_bonus(secondary_item_id)
	return 5 + bonus


func get_melee_damage() -> int:
	return 1


func get_companion_level(_id: StringName) -> int:
	return 1


var main_weapon_id: StringName = &"sword"
var secondary_item_id: StringName = &""


func equip_main_weapon(id: StringName) -> void:
	main_weapon_id = id


func equip_secondary_item(id: StringName) -> void:
	secondary_item_id = id


func equip_primary(item_id: StringName) -> void:
	equip_main_weapon(item_id)


func equip_secondary(item_id: StringName) -> void:
	equip_secondary_item(item_id)


var primary_item_id: StringName:
	get:
		return main_weapon_id
	set(value):
		main_weapon_id = value


var gacha_currency: int = 0

func add_gacha_currency(amount: int) -> void:
	gacha_currency += amount


# --- Hub / stage compatibility (optional scenes) ---
var player_class: StringName = &""
var player_level: int = 1
var player_exp: int = 0
var inventory: Array[String] = []
var current_region: int = 1
var current_stage_index: int = 0
var unlocked_region_count: int = 8
var unlocked_stages: Dictionary = {"1_0": true}

func set_player_class(_cl: StringName) -> void:
	player_class = _cl


func is_region_unlocked(region: int) -> bool:
	return region >= 1 and region <= unlocked_region_count


func is_stage_unlocked(region: int, stage_idx: int) -> bool:
	return unlocked_stages.get("%d_%d" % [region, stage_idx], false)


func clear_stage(region: int, stage_idx: int) -> void:
	unlocked_stages["%d_%d" % [region, stage_idx]] = true


func get_next_stage_after_clear(_region: int, _stage_idx: int) -> String:
	return "res://scenes/hub/hub.tscn"


func add_item(item_id: String) -> void:
	inventory.append(item_id)


func has_item(item_id: String) -> bool:
	return item_id in inventory


func try_unlock_companion(id: StringName) -> bool:
	return try_unlock_monster(id)


func add_player_exp(_amount: int) -> void:
	pass
