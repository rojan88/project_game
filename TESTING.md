# Testing & QA checklist (M5.5)

Use this before releasing a build (PC or Android).

## Core loop

- [ ] **Hub:** Class selection shows once; after choosing, region panel and inventory appear.
- [ ] **Regions:** Only unlocked regions (1–8) show; selecting a region loads stage with correct enemies.
- [ ] **Stages:** Enemies spawn; defeating all triggers “Stage clear!” and progression (next stage or hub after boss).
- [ ] **Progression:** Beating boss unlocks next region; first stage of new region is playable.

## Combat

- [ ] **Movement:** WASD (or sticks) moves in 8 directions; no getting stuck on walls.
- [ ] **Attack:** J (or button) triggers melee; hitbox damages enemies; knockback and (with Fire Spirit or Flame Sword) burn apply.
- [ ] **Dodge:** K (or button) spends energy, gives brief invulnerability, 0.5 s cooldown; with Shadow Cloak + Ghost, dodge explosion damages nearby enemies.
- [ ] **Energy:** Regens over time; dodge and companion special consume it; UI shows current/max.
- [ ] **Companion:** Auto-attack and special (L) work; companion follows player; cycling (Tab) and unlock (U) work.

## Items & synergy

- [ ] **Hub inventory:** Primary/Secondary show; “Change” cycles through owned items and (none).
- [ ] **Starter items:** Mage/DPS get Flame Sword, Tank/Healer get Vital Herb; equipped as primary after class select.
- [ ] **Synergies:** Flame Sword + Fire Spirit → burn on melee; Shadow Cloak + Ghost → damage on dodge end (if both owned).

## Death & respawn

- [ ] **Death:** Player dies at 0 HP; respawn after delay at stage spawn with full HP/energy.
- [ ] **No softlocks:** No infinite loops or stuck state in hub or stage.

## Android-specific

- [ ] **Touch/controls:** Input map works (virtual keys or external gamepad if used).
- [ ] **Resolution:** Layout readable on phone (viewport/stretch set in project.godot).
- [ ] **Performance:** No major frame drops during combat with several enemies and effects.
- [ ] **Export:** AAB/APK builds without errors; install and launch on device.

## Content

- [ ] **All 8 regions** have 3 stages (2 normal + 1 boss); no missing scenes or config.
- [ ] **Bosses:** Region 1/6 → BOSS; 2/4/7 → BOSS_2; 3/5/8 → BOSS_3; patterns and telegraphs visible.

## Balance (optional pass)

- [ ] Early regions feel manageable; later regions ramp difficulty (enemy mix, elites, casters).
- [ ] Essence gain allows unlocking 2–3 companions in a run; player level and items feel impactful.

---

**Bug reporting:** Note device/OS, steps to reproduce, and expected vs actual behavior.
