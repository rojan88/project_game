# Monster Pact

Top-down dodge-based action RPG with monster companions.  
**Engine:** Godot 4.x · **Target:** Android (first release)

**Current state:** Reverted to **Milestone 1** scope with client design rules applied. See **[CLIENT_RULES.md](CLIENT_RULES.md)** for weapon, status, equipment, and energy/class rules before M2/M3.

---

## How to run and play (M1)

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

### M1 scope

- One test arena with walls; player can move, attack, dodge.
- Optional enemies (chaser, lunge) for combat testing; essence drops are collected (for future unlock).
- **No class selection.** Dodge uses **cooldown only** (0.5 s). **Energy** is on the player for future monster abilities only.
- Build variety (later) from: main weapon, active monster, secondary item, synergy.

---

## Milestones

See **[MILESTONES.md](MILESTONES.md)** for the full plan. M2+ (enemies, essence loop, companions, regions, etc.) will be re-added after reviewing types and combat with the client; design rules are in **[CLIENT_RULES.md](CLIENT_RULES.md)**.

---

## Repository

[https://github.com/rojan88/project_game](https://github.com/rojan88/project_game)
