extends Node
## Static config: which enemies to spawn per (region, stage_index).
## Stage index 2 = boss stage.

const CHASER: String = "res://scenes/enemies/chaser_enemy.tscn"
const LUNGE: String = "res://scenes/enemies/lunge_enemy.tscn"
const SHOOTER: String = "res://scenes/enemies/shooter_enemy.tscn"
const SWEEPER: String = "res://scenes/enemies/sweeper_enemy.tscn"
const ELITE_CHASER: String = "res://scenes/enemies/elite_chaser.tscn"
const BOSS: String = "res://scenes/enemies/boss_enemy.tscn"
const BOSS_2: String = "res://scenes/enemies/boss_2_enemy.tscn"
const BOSS_3: String = "res://scenes/enemies/boss_3_enemy.tscn"
const FLYING: String = "res://scenes/enemies/flying_enemy.tscn"
const CASTER: String = "res://scenes/enemies/caster_enemy.tscn"

# [region][stage_index] = array of { "scene": path, "position": Vector2 }
const STAGE_DATA: Dictionary = {
	1: {
		0: [{"scene": CHASER, "position": Vector2(280, 80)}, {"scene": CHASER, "position": Vector2(100, 140)}, {"scene": LUNGE, "position": Vector2(192, 50)}],
		1: [{"scene": CHASER, "position": Vector2(150, 60)}, {"scene": LUNGE, "position": Vector2(250, 100)}, {"scene": CHASER, "position": Vector2(192, 160)}],
		2: [{"scene": BOSS, "position": Vector2(192, 80)}],
	},
	2: {
		0: [{"scene": LUNGE, "position": Vector2(120, 70)}, {"scene": FLYING, "position": Vector2(260, 120)}, {"scene": SHOOTER, "position": Vector2(192, 160)}],
		1: [{"scene": ELITE_CHASER, "position": Vector2(192, 80)}, {"scene": LUNGE, "position": Vector2(100, 140)}, {"scene": CHASER, "position": Vector2(280, 100)}],
		2: [{"scene": BOSS_2, "position": Vector2(192, 80)}],
	},
	3: {
		0: [{"scene": SHOOTER, "position": Vector2(140, 60)}, {"scene": CASTER, "position": Vector2(240, 140)}, {"scene": CHASER, "position": Vector2(192, 100)}],
		1: [{"scene": CHASER, "position": Vector2(80, 100)}, {"scene": LUNGE, "position": Vector2(300, 100)}, {"scene": ELITE_CHASER, "position": Vector2(192, 50)}],
		2: [{"scene": BOSS_3, "position": Vector2(192, 80)}],
	},
	4: {
		0: [{"scene": SWEEPER, "position": Vector2(120, 70)}, {"scene": LUNGE, "position": Vector2(260, 120)}, {"scene": SHOOTER, "position": Vector2(192, 160)}],
		1: [{"scene": ELITE_CHASER, "position": Vector2(150, 60)}, {"scene": SWEEPER, "position": Vector2(230, 140)}, {"scene": LUNGE, "position": Vector2(192, 100)}],
		2: [{"scene": BOSS_2, "position": Vector2(192, 80)}],
	},
	5: {
		0: [{"scene": ELITE_CHASER, "position": Vector2(100, 80)}, {"scene": SWEEPER, "position": Vector2(280, 100)}, {"scene": SHOOTER, "position": Vector2(192, 160)}],
		1: [{"scene": SWEEPER, "position": Vector2(140, 60)}, {"scene": ELITE_CHASER, "position": Vector2(240, 120)}, {"scene": LUNGE, "position": Vector2(192, 140)}],
		2: [{"scene": BOSS_3, "position": Vector2(192, 80)}],
	},
	# M5.1: Regions 6–8
	6: {
		0: [{"scene": CASTER, "position": Vector2(140, 70)}, {"scene": FLYING, "position": Vector2(250, 130)}, {"scene": ELITE_CHASER, "position": Vector2(192, 160)}],
		1: [{"scene": SWEEPER, "position": Vector2(100, 90)}, {"scene": LUNGE, "position": Vector2(280, 110)}, {"scene": SHOOTER, "position": Vector2(192, 50)}],
		2: [{"scene": BOSS, "position": Vector2(192, 80)}],
	},
	7: {
		0: [{"scene": CHASER, "position": Vector2(120, 60)}, {"scene": CASTER, "position": Vector2(260, 140)}, {"scene": FLYING, "position": Vector2(192, 100)}],
		1: [{"scene": ELITE_CHASER, "position": Vector2(80, 120)}, {"scene": SWEEPER, "position": Vector2(300, 80)}, {"scene": LUNGE, "position": Vector2(192, 160)}],
		2: [{"scene": BOSS_2, "position": Vector2(192, 80)}],
	},
	8: {
		0: [{"scene": FLYING, "position": Vector2(100, 80)}, {"scene": SHOOTER, "position": Vector2(280, 120)}, {"scene": ELITE_CHASER, "position": Vector2(192, 160)}],
		1: [{"scene": CASTER, "position": Vector2(150, 60)}, {"scene": SWEEPER, "position": Vector2(230, 140)}, {"scene": FLYING, "position": Vector2(192, 100)}],
		2: [{"scene": BOSS_3, "position": Vector2(192, 80)}],
	},
}

func get_enemy_spawns(region: int, stage_idx: int) -> Array:
	var r: Dictionary = STAGE_DATA.get(region, {})
	return r.get(stage_idx, [])

func is_boss_stage(region: int, stage_idx: int) -> bool:
	return stage_idx == 2
