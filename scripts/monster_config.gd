extends Node
## M3: Monster definitions — type (for status rules), essence cost, companion combat stats.
## GDD: one active monster; type drives weapon-on-hit effects (not the weapon element).

const TYPE_FIRE: StringName = &"fire"
const TYPE_FROST: StringName = &"frost"
const TYPE_POISON: StringName = &"poison"
const TYPE_STORM: StringName = &"storm"
const TYPE_STONE: StringName = &"stone"
const TYPE_SHADOW: StringName = &"shadow"
const TYPE_NATURE: StringName = &"nature"
const TYPE_SPIRIT: StringName = &"spirit"
const TYPE_NEUTRAL: StringName = &"neutral"

const MONSTER_IDS: Array[StringName] = [
	&"fire_spirit", &"frost_ling", &"poison_bloom", &"storm_jelly",
	&"stone_knight", &"shadow_moth", &"nature_dryad", &"spirit_globe", &"neutral_blob",
]

const DATA: Dictionary = {
	&"fire_spirit": {
		"display_name": "Fire Spirit", "essence_cost": 3, "monster_type": TYPE_FIRE,
		"auto_attack_damage": 1, "auto_attack_range": 120.0, "auto_attack_cooldown": 1.0,
		"auto_attack_projectile_speed": 140.0, "special_cooldown": 2.0, "special_damage": 2,
		"attack_style": &"projectile",
	},
	&"frost_ling": {
		"display_name": "Frost Ling", "essence_cost": 4, "monster_type": TYPE_FROST,
		"auto_attack_damage": 1, "auto_attack_range": 70.0, "auto_attack_cooldown": 1.1,
		"special_cooldown": 2.5, "special_damage": 2, "special_radius": 45.0,
		"attack_style": &"melee",
	},
	&"poison_bloom": {
		"display_name": "Poison Bloom", "essence_cost": 4, "monster_type": TYPE_POISON,
		"auto_attack_damage": 1, "auto_attack_range": 90.0, "auto_attack_cooldown": 1.0,
		"auto_attack_projectile_speed": 120.0, "special_cooldown": 2.8, "special_damage": 2,
		"special_radius": 50.0, "attack_style": &"projectile",
	},
	&"storm_jelly": {
		"display_name": "Storm Jelly", "essence_cost": 5, "monster_type": TYPE_STORM,
		"auto_attack_damage": 1, "auto_attack_range": 100.0, "auto_attack_cooldown": 0.95,
		"auto_attack_projectile_speed": 150.0, "special_cooldown": 2.2, "special_damage": 2,
		"attack_style": &"projectile",
	},
	&"stone_knight": {
		"display_name": "Stone Knight", "essence_cost": 5, "monster_type": TYPE_STONE,
		"auto_attack_damage": 1, "auto_attack_range": 55.0, "auto_attack_cooldown": 1.2,
		"special_cooldown": 3.0, "special_damage": 3, "special_radius": 50.0,
		"attack_style": &"melee",
	},
	&"shadow_moth": {
		"display_name": "Shadow Moth", "essence_cost": 5, "monster_type": TYPE_SHADOW,
		"auto_attack_damage": 1, "auto_attack_range": 110.0, "auto_attack_cooldown": 0.9,
		"auto_attack_projectile_speed": 145.0, "special_cooldown": 2.0, "special_damage": 2,
		"attack_style": &"projectile",
	},
	&"nature_dryad": {
		"display_name": "Nature Dryad", "essence_cost": 5, "monster_type": TYPE_NATURE,
		"auto_attack_damage": 1, "auto_attack_range": 85.0, "auto_attack_cooldown": 1.05,
		"auto_attack_projectile_speed": 125.0, "special_cooldown": 2.6, "special_damage": 2,
		"special_radius": 40.0, "attack_style": &"projectile",
	},
	&"spirit_globe": {
		"display_name": "Spirit Globe", "essence_cost": 6, "monster_type": TYPE_SPIRIT,
		"auto_attack_damage": 1, "auto_attack_range": 115.0, "auto_attack_cooldown": 0.95,
		"auto_attack_projectile_speed": 155.0, "special_cooldown": 2.1, "special_damage": 2,
		"attack_style": &"projectile",
	},
	&"neutral_blob": {
		"display_name": "Neutral Blob", "essence_cost": 2, "monster_type": TYPE_NEUTRAL,
		"auto_attack_damage": 1, "auto_attack_range": 65.0, "auto_attack_cooldown": 1.15,
		"special_cooldown": 2.4, "special_damage": 2, "special_radius": 42.0,
		"attack_style": &"melee",
	},
}

static func get_data(id: StringName) -> Dictionary:
	return DATA.get(id, {})

static func get_monster_type(id: StringName) -> StringName:
	return DATA.get(id, {}).get("monster_type", TYPE_NEUTRAL)

static func get_essence_cost(id: StringName) -> int:
	return DATA.get(id, {}).get("essence_cost", 999)

static func get_display_name(id: StringName) -> String:
	return DATA.get(id, {}).get("display_name", str(id))
