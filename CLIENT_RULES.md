# Client design rules (post–Milestone 1 review)

**Applied after reverting to M1 scope.** Use these when implementing M2/M3+ so we don’t redo work.

---

## 1. Weapon system (important)

- **Weapons** only define **attack pattern** and **base stats** (e.g. sword = melee slash, bow = projectile, spear = thrust).
- **Weapons do NOT contain elemental or status logic.**
- **Element and status effects come from the active monster**, not the weapon.
  - Example: Sword + Fire Monster → burning melee. Bow + Frost Monster → freezing arrows.
- This keeps weapons reusable with different monsters and builds.

---

## 2. Status effects

- **Monster type** defines the effect:
  - Fire → Burn (DoT)
  - Frost → Freeze (slow / short stun)
  - Poison → stacking poison damage
  - Storm → chain lightning
  - Stone → stun chance
  - Shadow → bonus damage after dodge
  - Spirit → attacks pierce
  - Neutral → Expose (enemies take increased damage)
- **Expose (draft):** +15% damage taken, ~3 s, max 1 stack (refresh on reapply).
- Status effects should be **modular** so any attack can apply them (player, monster abilities, etc.).
- *Types/effects are drafts; review again with client before full implementation for balance.*

---

## 3. Equipment system

- **Two slots:**
  - **Slot 1 – Main weapon:** Attack pattern only (sword, bow, dagger, etc.).
  - **Slot 2 – Secondary item:** Passives only (move speed, energy regen, damage bonus, cooldown reduction, survivability). **Does not change attack pattern.**

---

## 4. Energy + class

- **Energy:** Either remove or keep **simple**.
  - **Use:** Monster abilities only.
  - **Regen:** Automatic over time.
- **Dodge:** **Cooldown only** — no energy cost. Keeps combat responsive; resource management is for abilities.
- **No class selection** at the start (no Warrior / Mage / Tank / Healer for now).
- **Build variety** comes from:
  - Main weapon
  - Active monster type
  - Secondary item
  - Monster ability / status synergy

---

## Current state (after revert)

- **Main scene:** Test arena (move, attack, dodge; optional enemies).
- **No** class selection, **no** companion system, **no** regions/stages in the main flow.
- **Dodge:** Cooldown only (0.5 s); no energy cost.
- **Energy:** Present on player for future monster abilities; not spent on dodge.
- **GameState:** Essence + two equipment slots (primary_item_id, secondary_item_id) only.
- Before M3, **review types and combat system** with the client to avoid unnecessary changes.
