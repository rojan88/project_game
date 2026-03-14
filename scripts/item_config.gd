extends Node
## Item definitions and primary–monster synergy (Combat doc).
## Primary item synergizes with active companion; secondary is effect-only.

const ITEM_IDS: Array[StringName] = [&"flame_sword", &"shadow_cloak", &"vital_herb"]

const DATA: Dictionary = {
	&"flame_sword": { "display_name": "Flame Sword", "description": "Melee burns with Fire Spirit." },
	&"shadow_cloak": { "display_name": "Shadow Cloak", "description": "Dodge explodes with Ghost." },
	&"vital_herb": { "display_name": "Vital Herb", "description": "Secondary: small heal over time." },
}

# Primary + companion -> synergy key for on-hit
const SYNERGY_ON_HIT: Dictionary = {
	&"flame_sword": { &"fire_spirit": &"burn" },
}

# Primary + companion -> synergy key for on-dodge-end
const SYNERGY_ON_DODGE: Dictionary = {
	&"shadow_cloak": { &"ghost": &"explosion" },
}

static func get_display_name(item_id: StringName) -> String:
	return DATA.get(item_id, {}).get("display_name", str(item_id))

static func get_description(item_id: StringName) -> String:
	return DATA.get(item_id, {}).get("description", "")

## Returns synergy effect for melee hit: e.g. &"burn" to apply burn to hit enemy.
static func get_primary_synergy_on_hit(primary_id: StringName, companion_id: StringName) -> StringName:
	if primary_id.is_empty() or companion_id.is_empty():
		return &""
	var comp_map: Dictionary = SYNERGY_ON_HIT.get(primary_id, {})
	return comp_map.get(companion_id, &"")

## Returns synergy effect for dodge end: e.g. &"explosion" to deal area damage.
static func get_primary_synergy_on_dodge(primary_id: StringName, companion_id: StringName) -> StringName:
	if primary_id.is_empty() or companion_id.is_empty():
		return &""
	var comp_map: Dictionary = SYNERGY_ON_DODGE.get(primary_id, {})
	return comp_map.get(companion_id, &"")
