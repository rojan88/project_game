extends Node
## Static companion definitions: id, name, essence cost, auto-attack and special params.
## Companion IDs in unlock order.

const COMPANION_IDS: Array[StringName] = [&"fire_spirit", &"stone_golem", &"bat", &"plant_sprite", &"ghost"]

const DATA: Dictionary = {
	&"fire_spirit": {
		"display_name": "Fire Spirit",
		"essence_cost": 3,
		"auto_attack_damage": 1,
		"auto_attack_range": 120.0,
		"auto_attack_cooldown": 1.0,
		"auto_attack_projectile_speed": 140.0,
		"special_cooldown": 2.0,
		"special_damage": 2,
		"special_range": 80.0,
	},
	&"stone_golem": {
		"display_name": "Stone Golem",
		"essence_cost": 5,
		"auto_attack_damage": 1,
		"auto_attack_range": 60.0,
		"auto_attack_cooldown": 1.2,
		"special_cooldown": 3.0,
		"special_damage": 3,
		"special_radius": 50.0,
	},
	&"bat": {
		"display_name": "Bat",
		"essence_cost": 5,
		"auto_attack_damage": 1,
		"auto_attack_range": 70.0,
		"auto_attack_cooldown": 0.8,
		"special_cooldown": 2.5,
		"special_damage": 2,
		"special_dash_distance": 80.0,
	},
	&"plant_sprite": {
		"display_name": "Plant Sprite",
		"essence_cost": 5,
		"auto_attack_damage": 1,
		"auto_attack_range": 80.0,
		"auto_attack_cooldown": 1.1,
		"special_cooldown": 2.8,
		"special_damage": 2,
		"special_radius": 55.0,
	},
	&"ghost": {
		"display_name": "Ghost",
		"essence_cost": 6,
		"auto_attack_damage": 1,
		"auto_attack_range": 130.0,
		"auto_attack_cooldown": 0.9,
		"auto_attack_projectile_speed": 150.0,
		"special_cooldown": 2.2,
		"special_damage": 2,
		"special_range": 100.0,
	},
}

static func get_data(id: StringName) -> Dictionary:
	return DATA.get(id, {})

static func get_essence_cost(id: StringName) -> int:
	return DATA.get(id, {}).get("essence_cost", 999)

static func get_display_name(id: StringName) -> String:
	return DATA.get(id, {}).get("display_name", str(id))
