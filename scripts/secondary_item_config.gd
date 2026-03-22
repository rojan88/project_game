extends Node
## M3 / GDD: Secondary slot — passives only (no attack pattern change).

const ITEM_IDS: Array[StringName] = [
	&"boots", &"charm", &"relic", &"band", &"focus_crystal",
]

const DATA: Dictionary = {
	&"boots": { "display_name": "Swift Boots", "move_speed_mult": 1.12, "dodge_distance_mult": 1.0 },
	&"charm": { "display_name": "War Charm", "damage_mult": 1.08, "crit_bonus": 0.0 },
	&"relic": { "display_name": "Cooldown Relic", "special_cooldown_mult": 0.85 },
	&"band": { "display_name": "Vitality Band", "max_health_bonus": 1 },
	&"focus_crystal": { "display_name": "Focus Crystal", "max_energy_bonus": 15, "energy_regen_mult": 1.2 },
}

static func get_move_speed_mult(id: StringName) -> float:
	return float(DATA.get(id, {}).get("move_speed_mult", 1.0))

static func get_damage_mult(id: StringName) -> float:
	return float(DATA.get(id, {}).get("damage_mult", 1.0))

static func get_max_health_bonus(id: StringName) -> int:
	return int(DATA.get(id, {}).get("max_health_bonus", 0))

static func get_max_energy_bonus(id: StringName) -> int:
	return int(DATA.get(id, {}).get("max_energy_bonus", 0))

static func get_energy_regen_mult(id: StringName) -> float:
	return float(DATA.get(id, {}).get("energy_regen_mult", 1.0))

static func get_special_cooldown_mult(id: StringName) -> float:
	return float(DATA.get(id, {}).get("special_cooldown_mult", 1.0))

static func get_display_name(id: StringName) -> String:
	return DATA.get(id, {}).get("display_name", str(id))
