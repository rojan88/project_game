extends Node
## M3 / GDD: Main weapons — pattern + stat multipliers only (no element).

const WEAPON_IDS: Array[StringName] = [
	&"sword", &"dagger", &"spear", &"greatsword", &"bow", &"orb", &"chakram", &"whip",
]

# Tier 1 baseline = 100% damage, base attack speed factor 1.0
const DATA: Dictionary = {
	&"sword": { "display_name": "Iron Sword", "damage_mult": 1.0, "attack_speed_mult": 1.0, "tier": 1 },
	&"dagger": { "display_name": "Iron Dagger", "damage_mult": 0.85, "attack_speed_mult": 1.25, "tier": 1 },
	&"spear": { "display_name": "Iron Spear", "damage_mult": 1.05, "attack_speed_mult": 0.95, "tier": 1 },
	&"greatsword": { "display_name": "Iron Greatsword", "damage_mult": 1.35, "attack_speed_mult": 0.75, "tier": 1 },
	&"bow": { "display_name": "Hunter Bow", "damage_mult": 0.95, "attack_speed_mult": 1.0, "tier": 1 },
	&"orb": { "display_name": "Novice Orb", "damage_mult": 1.0, "attack_speed_mult": 1.0, "tier": 1 },
	&"chakram": { "display_name": "Steel Chakram", "damage_mult": 0.9, "attack_speed_mult": 1.1, "tier": 1 },
	&"whip": { "display_name": "Leather Whip", "damage_mult": 0.88, "attack_speed_mult": 1.15, "tier": 1 },
}

static func get_damage_mult(id: StringName) -> float:
	if id.is_empty():
		return 1.0
	return float(DATA.get(id, {}).get("damage_mult", 1.0))

static func get_attack_speed_mult(id: StringName) -> float:
	if id.is_empty():
		return 1.0
	return float(DATA.get(id, {}).get("attack_speed_mult", 1.0))

static func get_display_name(id: StringName) -> String:
	return DATA.get(id, {}).get("display_name", str(id))
