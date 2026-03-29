extends Node
## M3–M4: Essence, monsters, equipment, progression, save serialization.

signal essence_changed(total: int, type: StringName)
signal companion_unlocked(companion_id: StringName)
signal active_companion_changed(companion_id: StringName)
signal equipment_changed()
signal player_progress_changed()

const STAGES_PER_REGION: int = 3
const MAX_REGIONS: int = 8
const PLAYER_LEVEL_CAP: int = 10
const PLAYER_EXP_PER_LEVEL: int = 15

var essence_count: int = 0
var essence_by_type: Dictionary = {}

var unlocked_monsters: Array[StringName] = []
var active_companion_id: StringName = &""

var main_weapon_id: StringName = &"sword"
var secondary_item_id: StringName = &""

var player_class: StringName = &""
var player_level: int = 1
var player_exp: int = 0
var player_max_health_base: int = 5

var inventory: Array[String] = []
var current_region: int = 1
var current_stage_index: int = 0
var unlocked_region_count: int = 1
var unlocked_stages: Dictionary = {}

var gacha_currency: int = 0


func _init() -> void:
	unlocked_stages["1_0"] = true


func _ready() -> void:
	if SaveSystem.load_game():
		return
	if unlocked_monsters.is_empty():
		unlocked_monsters.append(&"neutral_blob")
		set_active_companion(&"neutral_blob")


func add_essence(type: StringName = &"common") -> void:
	essence_count += 1
	if not essence_by_type.has(type):
		essence_by_type[type] = 0
	essence_by_type[type] = int(essence_by_type[type]) + 1
	essence_changed.emit(essence_count, type)


func get_essence_count() -> int:
	return essence_count


func get_essence_for_type(type: StringName) -> int:
	return int(essence_by_type.get(type, 0))


func _deduct_essence_by_type(amount: int) -> void:
	var left: int = amount
	var order: Array[StringName] = [&"common"]
	for k in essence_by_type.keys():
		var kk: StringName = k if k is StringName else StringName(str(k))
		if kk not in order:
			order.append(kk)
	for t in order:
		if left <= 0:
			break
		var have: int = int(essence_by_type.get(t, 0))
		if have <= 0:
			continue
		var take: int = mini(have, left)
		essence_by_type[t] = have - take
		left -= take


func is_monster_unlocked(id: StringName) -> bool:
	return id in unlocked_monsters


func try_unlock_monster(id: StringName) -> bool:
	if id in unlocked_monsters:
		return true
	var cost: int = MonsterConfig.get_essence_cost(id)
	if essence_count < cost:
		return false
	essence_count -= cost
	_deduct_essence_by_type(cost)
	unlocked_monsters.append(id)
	essence_changed.emit(essence_count, &"")
	companion_unlocked.emit(id)
	if active_companion_id.is_empty():
		set_active_companion(id)
	SaveSystem.save_game()
	return true


func set_active_companion(id: StringName) -> void:
	if not id.is_empty() and id not in unlocked_monsters:
		return
	active_companion_id = id
	active_companion_changed.emit(id)
	SaveSystem.save_game()


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
	return player_max_health_base + bonus


func get_melee_damage() -> int:
	return 1


func get_companion_level(_id: StringName) -> int:
	return 1


func equip_main_weapon(id: StringName) -> void:
	main_weapon_id = id
	equipment_changed.emit()
	SaveSystem.save_game()


func equip_secondary_item(id: StringName) -> void:
	secondary_item_id = id
	equipment_changed.emit()
	SaveSystem.save_game()


func equip_primary(item_id: StringName) -> void:
	equip_main_weapon(item_id)


func equip_secondary(item_id: StringName) -> void:
	equip_secondary_item(item_id)


var primary_item_id: StringName:
	get:
		return main_weapon_id
	set(value):
		equip_main_weapon(value)


func add_player_exp(amount: int) -> void:
	if player_level >= PLAYER_LEVEL_CAP:
		return
	player_exp += amount
	var need: int = player_level * PLAYER_EXP_PER_LEVEL
	while player_exp >= need and player_level < PLAYER_LEVEL_CAP:
		player_exp -= need
		player_level += 1
		player_max_health_base += 2
		need = player_level * PLAYER_EXP_PER_LEVEL
	player_progress_changed.emit()
	SaveSystem.save_game()


func set_player_class(cl: StringName) -> void:
	player_class = cl
	SaveSystem.save_game()


func is_region_unlocked(region: int) -> bool:
	return region >= 1 and region <= unlocked_region_count


func is_stage_unlocked(region: int, stage_idx: int) -> bool:
	return unlocked_stages.get("%d_%d" % [region, stage_idx], false)


func clear_stage(region: int, stage_idx: int) -> void:
	var key: String = "%d_%d" % [region, stage_idx]
	unlocked_stages[key] = true
	var is_boss: bool = stage_idx == STAGES_PER_REGION - 1
	if is_boss:
		if region < MAX_REGIONS:
			unlocked_region_count = maxi(unlocked_region_count, region + 1)
		if region + 1 <= MAX_REGIONS:
			unlocked_stages["%d_0" % (region + 1)] = true
	else:
		unlocked_stages["%d_%d" % [region, stage_idx + 1]] = true
	SaveSystem.save_game()


func get_next_stage_after_clear(region: int, stage_idx: int) -> String:
	var is_boss: bool = stage_idx == STAGES_PER_REGION - 1
	if is_boss:
		return "res://scenes/hub/hub.tscn"
	return "res://scenes/stages/stage.tscn"


func add_item(item_id: String) -> void:
	inventory.append(item_id)


func has_item(item_id: String) -> bool:
	return item_id in inventory


func try_unlock_companion(id: StringName) -> bool:
	return try_unlock_monster(id)


func add_gacha_currency(amount: int) -> void:
	gacha_currency += amount


# --- Save / load ---
func get_save_dict() -> Dictionary:
	var ess_bt: Dictionary = {}
	for k in essence_by_type.keys():
		ess_bt[str(k)] = essence_by_type[k]
	var monsters: Array = []
	for m in unlocked_monsters:
		monsters.append(str(m))
	return {
		"essence_count": essence_count,
		"essence_by_type": ess_bt,
		"unlocked_monsters": monsters,
		"active_companion_id": str(active_companion_id),
		"main_weapon_id": str(main_weapon_id),
		"secondary_item_id": str(secondary_item_id),
		"player_class": str(player_class),
		"player_level": player_level,
		"player_exp": player_exp,
		"player_max_health_base": player_max_health_base,
		"inventory": inventory.duplicate(),
		"current_region": current_region,
		"current_stage_index": current_stage_index,
		"unlocked_region_count": unlocked_region_count,
		"unlocked_stages": unlocked_stages.duplicate(true),
		"gacha_currency": gacha_currency,
	}


func apply_save_dict(d: Dictionary) -> void:
	essence_count = int(d.get("essence_count", 0))
	essence_by_type.clear()
	var ebt: Variant = d.get("essence_by_type", {})
	if ebt is Dictionary:
		for k in ebt.keys():
			essence_by_type[StringName(str(k))] = ebt[k]
	unlocked_monsters.clear()
	for s in d.get("unlocked_monsters", []):
		unlocked_monsters.append(StringName(str(s)))
	active_companion_id = StringName(str(d.get("active_companion_id", "")))
	main_weapon_id = StringName(str(d.get("main_weapon_id", "sword")))
	if main_weapon_id.is_empty():
		main_weapon_id = &"sword"
	secondary_item_id = StringName(str(d.get("secondary_item_id", "")))
	player_class = StringName(str(d.get("player_class", "")))
	player_level = int(d.get("player_level", 1))
	player_exp = int(d.get("player_exp", 0))
	player_max_health_base = int(d.get("player_max_health_base", 5))
	inventory.clear()
	for it in d.get("inventory", []):
		inventory.append(str(it))
	current_region = int(d.get("current_region", 1))
	current_stage_index = int(d.get("current_stage_index", 0))
	unlocked_region_count = int(d.get("unlocked_region_count", 1))
	unlocked_stages.clear()
	var us: Variant = d.get("unlocked_stages", {})
	if us is Dictionary:
		for k in us.keys():
			unlocked_stages[str(k)] = us[k]
	gacha_currency = int(d.get("gacha_currency", 0))
	if unlocked_stages.is_empty():
		unlocked_stages["1_0"] = true
	if unlocked_monsters.is_empty():
		unlocked_monsters.append(&"neutral_blob")
	if active_companion_id.is_empty() and not unlocked_monsters.is_empty():
		active_companion_id = unlocked_monsters[0]
	player_progress_changed.emit()
	equipment_changed.emit()
	active_companion_changed.emit(active_companion_id)
