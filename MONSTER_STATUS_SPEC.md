# Monster Types & Status Effects — Implementation Spec (M3)

This file mirrors the client **Monster Pact – Monster Types & Status Effects** document and maps it to code.

| Monster type | Status / mechanic | Implementation |
|----------------|-------------------|------------------|
| **Fire** | Burn — 4s, tick 1s, **10% base attack** per tick, max 1 stack, refresh duration | `EnemyBase.apply_burn_from_spec(base_attack)` |
| **Frost** | Freeze — **60% slow** (40% move speed), 2s, max 1 stack; **reapply while active → 0.5s hard stun** | `apply_freeze_from_spec()` + `_get_state_timer_scale()` |
| **Poison** | Poison — 5s, tick 1s, **6% base × stacks** per tick, max **5** stacks, refresh on stack | `apply_poison_from_spec(base_attack)` |
| **Storm** | Shock — chain **64 px** (~4 units), **3** extra targets, **50%** damage, **0.1s** delay | `CombatEffects._storm_chain_start` (deferred async) |
| **Stone** | Stun — **20%** on hit, **1s** stun, knockback, **2s** immunity per enemy | `apply_stone_on_hit_from_spec(from_pos)` |
| **Shadow** | Shadow Mark — **1s** after dodge, hits apply mark **2s**; **+40%** damage taken | Player `_shadow_follow_up_timer`; `apply_shadow_mark()` |
| **Nature** | Root — **20%** on hit, **1.5s**, cannot move, can attack; *area root zones (2s) — future* | `apply_nature_root_from_spec()` |
| **Spirit** | Pierce — **3** enemies, **100% / 90% / 80%** damage | Player `_resolve_melee_hits()` |
| **Neutral** | Expose — **+15%** damage taken, **3s**, 1 stack refresh | `apply_expose_from_spec()` (GDD Neutral) |

**Damage flags:** `EnemyBase.DMG_FLAG_PLAYER` applies Shadow Mark + Expose multipliers. DoT and chain use `DMG_FLAG_RAW`.

**Base attack damage:** Player `get_base_attack_damage()` = `melee_damage × weapon × secondary charm`.

**Files:** `scripts/monster_config.gd`, `scripts/combat_effects.gd`, `scripts/enemy_base.gd`, `scripts/player.gd`, `scripts/companion_projectile.gd`.
