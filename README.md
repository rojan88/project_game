# Monster Pact

Top-down dodge-based action RPG with monster companions.  
**Engine:** Godot 4.x · **Target:** Android (first release)

**Current state:** **Milestone 3** combat + inventory systems implemented. See **[CLIENT_RULES.md](CLIENT_RULES.md)**, **[MONSTER_STATUS_SPEC.md](MONSTER_STATUS_SPEC.md)** (client status numbers), and **[CLIENT_MESSAGE_REPLY_M3.md](CLIENT_MESSAGE_REPLY_M3.md)**.

---

## How to run and play (M1 + M2)

### Run the game

1. **Install Godot 4.x** — [Download](https://godotengine.org/download) (4.2 or 4.3+).
2. **Open the project** — Import the folder containing **project.godot** (or double‑click **project.godot**).
3. **Play** — Press **F5**. The game starts in the **Test Arena**.

### Controls (M1)

| Action | Key |
|--------|-----|
| Move   | W A S D |
| Attack | J |
| Dodge  | K (cooldown only — no energy cost) |

### M1 + M2 + M3 scope

- **Test arena:** Same as M2, plus **active monster** (starts as **Neutral Blob** — Expose on hit). **Tab** cycles unlocked monsters; **U** unlocks next in roster (essence cost); **L** uses **monster special** (costs **Energy**). Dodge stays **cooldown-only**; energy regens for specials.
- **Weapons & secondaries:** `GameState.main_weapon_id` (default **sword**) and `secondary_item_id` — stats from **WeaponConfig** / **SecondaryItemConfig** (GDD). Monster type defines **status effects** on hit (not the weapon).
- **Status effects:** Full implementation per client spec — Burn, Freeze, Poison stacks, Storm chain lightning, Stone stun, Shadow mark after dodge, Nature root chance, Spirit melee pierce (3 targets, 100/90/80%), Neutral Expose. Details: **[MONSTER_STATUS_SPEC.md](MONSTER_STATUS_SPEC.md)**.

---

## Milestones

See **[MILESTONES.md](MILESTONES.md)**. M3 core combat + inventory + monster effects are in; optional survival layers (waves, hunger, etc.) can be agreed with the client.

---

## Repository

[https://github.com/rojan88/project_game](https://github.com/rojan88/project_game)
