# Reply to client — M1/M2 sign-off & M3 + procedural generation

**Use:** Copy, edit names/sign-off, and send (email/Slack).

---

## Suggested reply (draft)

Hi [Name],

Thank you for the review — we’re glad movement, camera, stage/map setup, and enemy AI with the spawning/config system are working as expected. We agree that **Milestones 1 and 2 are complete** per the agreed scope, and we’re ready to move into **Milestone 3**.

For **Milestone 3**, we’ll align with your framing of **Combat + Inventory + Survival mechanics**, on top of the existing **CLIENT_RULES.md** (weapon vs monster element separation, two equipment slots, energy for monster abilities, dodge on cooldown only, no class selection at start). Concretely, we plan to cover:

- **Combat:** Active monster companion, auto-attack + special ability, essence-based unlock; status/effects applied in line with your monster-type rules (to be finalized when we lock types/balance).
- **Inventory / equipment:** Main weapon (attack pattern + base stats only), secondary item (passives only), and UI flow to equip/use slots without mixing element logic into weapons.
- **Survival mechanics:** We’d like a short alignment on what you want in scope for M3 — e.g. hunger/stamina, wave escalation, time pressure, or “single-life” run rules — so we implement the right systems first.

**Procedural / randomized content:** The current `StageConfig`-style setup (fixed enemy lists + positions per stage) is a solid base. Here is our recommendation on difficulty vs payoff:

| Approach | Effort | What you get |
|----------|--------|----------------|
| **A — Randomized spawns (recommended first)** | **Lowest** | Same arena/room layout; random picks from enemy **pools**, **counts**, and **spawn zones** (with rules so nothing spawns on the player). Optional **seed** for reproducibility. Fits naturally as an extension of today’s config. |
| **B — Modular rooms** | Medium | Hand-built room **prefabs** chosen and stitched (e.g. 2–4 segments per run). More variety than A, still controllable for balance. |
| **C — Full procedural map** | Highest | Generated walls/layout (e.g. cellular / BSP). Highest risk for collision bugs, unfair spawns, and longer tuning. |

**Suggestion:** Implement **A** during or right after M3 core combat/inventory, then evaluate **B** if you want stronger “new map each run” feel without the cost of **C**. We’re happy to discuss timing (M3 vs a small M3.5 / polish milestone) based on your priorities.

Please confirm **survival mechanics** priorities for M3 and whether you’re aligned with starting procedural work at **level A** first.

Best regards,  
[Your name]

---

## Internal notes (for dev)

- **Current main scene:** Test arena (M2). Full `stage.gd` + `StageConfig` still exist for when hub/regions return; proc-gen layer can feed the same spawn API (`get_enemy_spawns` or a new `build_spawn_list(seed, stage_id)`).
- **CLIENT_RULES.md** remains the design source for M3 combat/inventory.
