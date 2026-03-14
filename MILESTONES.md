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

**Suggested budget slice:** ~$100–$120

---

## Milestone 3 — Companion & capture (essence-based)

**Goal:** Essence unlocks companions; one active companion with auto-attack + one special ability.

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

**M4 completion notes:** 4.1–4.5 already in place (hub, 5 regions × 3 stages, progression, boss stages, player level cap 10). 4.6: Starter items on class selection (Mage/DPS: Flame Sword; Tank/Healer: Vital Herb); hub Inventory panel with Primary/Secondary labels and “Change” buttons to cycle equip from inventory.

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
