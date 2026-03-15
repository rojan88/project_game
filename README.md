# Monster Pact

Top-down dodge-based action RPG with monster companions.  
**Engine:** Godot 4.x · **Target:** Android (first release)

**Current state:** **Milestone 2** complete (M1 + client rules + enemies & essence loop). See **[CLIENT_RULES.md](CLIENT_RULES.md)** for design rules.

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

### M1 + M2 scope

- **One test stage:** Arena with walls; player moves (WASD), attacks (J), dodges (K, cooldown only).
- **Enemies:** Chaser, Lunge, Shooter — telegraphed attacks (red indicator), drop **Essence** on death (chance).
- **Essence:** Walk over pickups to collect; counter in UI. Foundation for unlocking companions later (M3).
- **Death/respawn:** At 0 HP you respawn at the start after a short delay. "Enemies cleared!" when all are defeated.
- **No class selection.** Energy is for future monster abilities only.

---

## Milestones

See **[MILESTONES.md](MILESTONES.md)** for the full plan. M1 and M2 are complete; design rules in **[CLIENT_RULES.md](CLIENT_RULES.md)**. M3 (companions, unlock with essence) next; review types/combat with client before implementing.

---

## Repository

[https://github.com/rojan88/project_game](https://github.com/rojan88/project_game)
