# Store assets and listing (Monster Pact) — M5.6

## App icon

- **Current:** `icon.svg` is used as the project icon; Godot can use it for Android.
- **Android:** Godot needs at least a main icon (192×192 px). For adaptive icons (Android 8+), provide foreground and background at 432×432 px. Place or configure in **Project → Export → Android → Icons**.
- **Store listing:** Provide a 512×512 px icon for the Play Store listing.

## Screenshots

- Google Play requires at least 2 screenshots (phone). Recommended: 1080×1920 or 1080×2340.
- Optional: 7-inch and 10-inch tablet screenshots.
- Suggested shots: Hub with class/region select; in-game combat with companion; boss fight; stage clear.

## Store listing text (draft)

### Short description (max 80 characters)

**Option A:** *Fight with monster powers. Dodge, attack, and clear 8 regions in this retro action RPG.*

**Option B:** *Top-down action RPG. Unlock monster companions, dodge and slash through 8 regions.*

### Full description (max 4000 characters)

**Monster Pact** is a fast, top-down action RPG where you fight alongside monster companions and push through eight dangerous regions.

• **Tight combat** — Move in all directions, land melee attacks, and use a quick dodge to avoid damage. Manage your energy for dodges and powerful companion skills.

• **Monster companions** — Beat enemies to collect essence and unlock companions. Each companion auto-attacks and grants a special ability: fire waves, poison clouds, magic beams, and more. Pair them with items for extra synergy (e.g. Flame Sword + Fire Spirit for burn, Shadow Cloak + Ghost for dodge explosions).

• **Classes** — Pick Tank, Healer, Mage, or DPS at the start for different stats and a starter item.

• **Progression** — Clear stages and bosses to unlock the next stage and the next region. Level up for more health and tackle eight regions of increasing challenge.

• **Retro style** — Top-down view and straightforward controls. Perfect for short runs or longer sessions.

No capture minigames — defeat enemies, grab essence, and build your team. Suit up, choose your companion, and clear the regions.

### Category & rating

- **Category:** Action or RPG.
- **Content rating:** Complete the questionnaire in Play Console (likely Everyone or Teen depending on fantasy violence).

## Gacha (post-launch)

- `GameState.gacha_currency` and `GameState.add_gacha_currency()` are in place for a future gacha system.
- When you add gacha: implement pull logic, rate tables, and compliance (e.g. display odds, age ratings).
