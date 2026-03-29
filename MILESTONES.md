# Monster Pact — Development Milestones

**Working title:** Monster Pact  
**Engine:** Godot 4.x  
**Target platform:** Android (first release); PC/Steam later  
**Reference:** GDD, **Combat System Design Document** (camera, movement, dodge 0.5s, Energy, knockback, items, caps), Zelda Oracle of Seasons, Lost Magic, Challacade

---

## Budget context (from client)

- **Total target:** ~$500–$600 (base); extra for gacha mechanic if profitable.
- **Goal:** Get audience first, then add gacha for engagement.
- **Client has:** Battle prototype APK (turn-based; capture system to be replaced with dodge button).

---

## Milestone 1 — Core player & combat foundation

**Goal:** Playable prototype with movement, attack, and dodge in a test arena.

| # | Task | Description |
|---|------|-------------|
| 1.1 | Project setup | Godot 4 project, folder structure, input map (move, attack, dodge, interact). |
| 1.2 | Player character | 360° movement (top-down), sprite/orientation. |
| 1.3 | Melee attack | Fast melee attack (animation/placeholder + hitbox). |
| 1.4 | Dodge | Dedicated dodge button: short invulnerable dash (no complicated capture on button). |
| 1.5 | Test scene | Single arena with walls/collision; player can move, attack, dodge. |
| 1.6 | Placeholder art | Simple programmer art or placeholders (replace with Gemini-generated assets later). |

**Deliverable:** APK or PC build where the player moves in all directions, attacks, and dodges in one test room.

**Combat doc alignment (updated):** Dodge cooldown 0.5s; Energy resource (regen, cost for dodge + monster ability); light knockback on hit; two item slots (primary/secondary) in GameState; Player Level Cap 10, Monster Level Cap 5; hit flash + screen shake (feedback).

**Suggested budget slice:** ~$100–$120

---

## Milestone 2 — Enemies & basic combat loop

**Goal:** Fight telegraphed enemies, take/give damage, collect essence.

| # | Task | Description |
|---|------|-------------|
| 2.1 | Health & damage | Player health, take damage from enemies, death/respawn or game over. |
| 2.2 | Enemy base | Melee, Ranged, Tank, Flying, Caster (Combat doc); telegraphed attacks. |
| 2.3 | Combat loop | Defeat enemies → chance to drop **Essence** (pickup). |
| 2.4 | Essence system | Collect essence (data/counter); foundation for unlocking companions later. |
| 2.5 | One test stage | Single stage with enemies and essence drops. |

**Deliverable:** Full “enter stage → fight → get essence” loop in one stage.

**Combat doc:** Red ground indicators; Flying & Caster enemies; status foundation + Burn DoT (Fire Spirit melee).

**M2 completion (post–M1 revert):** Test arena is the one stage. Player health, take damage from enemies, death/respawn. EnemyBase: telegraphed attacks (red rectangle), Chaser/Lunge/Shooter in arena, essence drop on death. Essence pickup adds to GameState; UI updates. "Enemies cleared!" when all defeated. Status effects (Burn/Poison) remain in EnemyBase for future monster synergy (client: element from monster).

**Suggested budget slice:** ~$100–$120

---

## Milestone 3 — Companion & capture (essence-based)

**Client framing (aligned):** **Combat + Inventory + Survival mechanics** — see **[CLIENT_MESSAGE_REPLY_M3.md](CLIENT_MESSAGE_REPLY_M3.md)** for suggested client reply and procedural-generation options.

**Goal:** Essence unlocks companions; one active companion with auto-attack + one special ability. Inventory/equipment per **CLIENT_RULES.md** (main weapon = pattern/stats; secondary = passives; element from monster). **Survival mechanics** — confirm scope with client (e.g. waves, resource pressure, run rules).

**M3 implementation (current):** See **[MONSTER_STATUS_SPEC.md](MONSTER_STATUS_SPEC.md)** for full status math. **MonsterConfig** — 9 monsters (Fire/Frost/Poison/Storm/Stone/Shadow/Nature/Spirit/Neutral). **WeaponConfig** + **SecondaryItemConfig** (GDD slots). **EnemyBase** — Burn, Freeze, Poison, Stone stun, Root, Expose, Shadow Mark, pierce + storm chain via **CombatEffects**. **Player** — weapon/secondary scaling, Spirit pierce, Shadow 1s post-dodge window, **L** special (energy), **Tab** cycle, **U** unlock. Starter **neutral_blob** unlocked; others cost essence. **Survival** passives via secondary items (e.g. Band +HP, Focus +energy). Nature **area root zones** marked future in spec doc.

| # | Task | Description |
|---|------|-------------|
| 3.1 | Companion data | Define companion types (e.g. Fire Spirit, Stone Golem); essence type → unlock. |
| 3.2 | One active companion | Only 1 companion active; companion auto-attacks enemies. |
| 3.3 | Special ability | Each companion grants one special skill to the player (e.g. fire wave, ground slam). |
| 3.4 | Capture = essence only | No “capture button”; capture = defeat enemy → chance to drop essence → unlock/upgrade companion. |
| 3.5 | 2–3 companions | Implement 2–3 monsters with different abilities for testing. |
| 3.6 | Companion leveling | Companions level up through combat (simple implementation). |

**Deliverable:** Defeat enemies → get essence → unlock/switch companion → use companion auto-attack + special in combat.

**Combat doc alignment (M3):** Monsters do not level up (companions stay level 1). Plant Sprite (poison cloud auto + area poison special) and Ghost (magic beam auto + beam special) added. Item system: primary/secondary slots; primary–monster synergy (e.g. Flame Sword + Fire Spirit = burn on melee; Shadow Cloak + Ghost = dodge explosion). ItemConfig autoload; synergies wired in player melee and dodge end.

**Suggested budget slice:** ~$120–$150

**Milestone 3 — client QA closure (post-review):**

- **Inventory in default flow:** Main scene runs **Hub** first; **Test Arena (practice)** from Hub validates weapon/secondary swaps during combat (UI buttons + `[` `]` / `,` `.` keybinds). Returning to Hub persists via save.
- **XP:** `GameState.add_player_exp` is implemented (level cap 10, HP growth on level); stage clear continues to award XP.
- **Hub UI:** Secondary slot display names resolve through **SecondaryItemConfig** (not raw IDs). Primary/secondary cycling uses **WeaponConfig.WEAPON_IDS** and **SecondaryItemConfig.ITEM_IDS** (inventory IDs merged when present).
- **Data hygiene:** **CompanionConfig** autoload removed (MonsterConfig remains authoritative). Companion unlock deducts **essence_by_type** in line with total essence spend.
- **M4 foundations started here:** `SaveSystem` (`user://monster_pact_save.json`), `AudioManager` (optional `res://audio/*.wav` on Master bus), equipment/save hooks on equip and progression.

---

## Milestone 4 — World structure & progression

**Goal:** Hub, regions, stages, bosses, and simple progression.

| # | Task | Description |
|---|------|-------------|
| 4.1 | Hub town | Simple hub (single screen or small area) to select regions. |
| 4.2 | Regions & stages | 2–3 regions for MVP; each region has stages + boss stage. |
| 4.3 | Progression | Complete stage → unlock next; defeat boss → unlock next region. |
| 4.4 | Boss fights | At least 1–2 boss encounters with telegraphed patterns. |
| 4.5 | Level system | Simple player (and optionally companion) level system. |
| 4.6 | Items / inventory | Base weapon + simple inventory (foundation for DLC/cosmetics later). |

**Deliverable:** Hub → choose region → play stages → boss → next region; basic level and inventory.

**M4 completion notes:** Hub is the **default** run scene. Class pick panel is optional/hidden so regions and inventory are always available. **Save/load** autoload persists essence, unlocks, equipment, progression, and stage unlocks; arena **pause menu** (Esc) offers Resume, Save, Load, Return to Hub. **AudioManager** plays hit/dodge/ability/UI when matching files exist under `res://audio/`. **Player** reapplies loadout on `equipment_changed` / `player_progress_changed`. Test arena equipment HUD + Hub practice entry complete the **inventory verification** loop from QA.

**Suggested budget slice:** ~$120–$150

---

## Milestone 5 — Content, polish & Android release

**Goal:** Content-complete, polished, and ready for Android release.

| # | Task | Description |
|---|------|-------------|
| 5.1 | Content scale-up | 8 regions, 10 enemy types, 8 elite enemies, 8 major bosses (or agreed MVP cut). |
| 5.2 | MC variety | Tank / Healer / Mage / DPS (Archer/Warrior) or simplified variants. |
| 5.3 | Art pass | Retro pixel art (Zelda Oracle of Seasons style); replace placeholders; particles and juice. |
| 5.4 | Android export | Godot Android export config; signing; store-ready APK/AAB. |
| 5.5 | Testing & bug fixing | QA on Android devices; performance and balance pass. |
| 5.6 | Store assets | Icons, screenshots, description (and optional gacha hook for post-launch). |

**Deliverable:** Shippable Android build; optional hook for future gacha mechanic.

**M5 completion notes:**  
- **5.1** Content scale-up: 8 regions (regions 6–8 added to StageConfig + GameState + Hub); enemy/boss variety uses existing types (MVP cut).  
- **5.2** MC variety: Tank/Healer/Mage/DPS already in place.  
- **5.3** Art pass: ART_PLACEHOLDERS.md lists assets to replace and style target; stage-clear label pop (scale tween) added as juice.  
- **5.4** Android: ANDROID_BUILD.md updated with Install Android Build Template and full export/signing steps.  
- **5.5** Testing: TESTING.md added with QA checklist (core loop, combat, items, death, Android, content).  
- **5.6** Store assets: STORE_ASSETS.md updated with draft short + full description and screenshot suggestions.

**Suggested budget slice:** ~$160–$180 (covers content, polish, release, buffer)

---

## Summary table

| Milestone | Focus | Suggested budget |
|-----------|--------|-------------------|
| 1 | Core player & combat (move, attack, dodge) | $100–$120 |
| 2 | Enemies & essence loop | $100–$120 |
| 3 | Companion & essence-based “capture” | $120–$150 |
| 4 | World, hub, regions, bosses, progression | $120–$150 |
| 5 | Content, polish, Android release | $160–$180 |
| **Total** | | **$600–$720** |

---

## Notes for development

- **Capture system:** Implement as “dodge button” + “essence on kill” only. Do not replicate the old APK’s complicated capture mechanic.
- **Art:** Placeholders first; client can use Gemini Ultra for sprites/assets; style target = Zelda Oracle of Seasons (retro top-down).
- **Prototype APK:** Use only as reference for feel/ideas; combat should be dodge-based action, not turn-based.
- **Repository:** [GitHub – project_game](https://github.com/rojan88/project_game.git); use branches/tags per milestone if desired.
