extends Node
## Autoload: minimal global state for M1 + client design rules.
## Reverted to Milestone 1 scope. No class selection; build variety later from weapon + monster + secondary.

signal essence_changed(total: int, type: StringName)

# Essence (for M2 — collect from enemies, unlock monsters later)
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


# Stubs for stage/hub scenes (M2+); use player's own stats when only test_arena is used
func get_player_max_health() -> int:
	return 5


func get_melee_damage() -> int:
	return 1


# --- Equipment (client: two slots — no class, no inventory for now) ---
# Slot 1 = Main weapon (attack pattern only; element/status from monster)
# Slot 2 = Secondary item (passives: move speed, regen, damage, etc.)
var primary_item_id: StringName = &""
var secondary_item_id: StringName = &""

func equip_primary(item_id: StringName) -> void:
	primary_item_id = item_id


func equip_secondary(item_id: StringName) -> void:
	secondary_item_id = item_id


# --- Placeholder for later (gacha, etc.) ---
var gacha_currency: int = 0

func add_gacha_currency(amount: int) -> void:
	gacha_currency += amount
