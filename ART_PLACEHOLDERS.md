# Art placeholders & polish (M5.3)

Target style: **Retro pixel art**, Zelda Oracle of Seasons–style top-down.

## Replace with final art

| Asset | Current | Notes |
|-------|---------|------|
| **Player** | `scenes/player/player.tscn` (Sprite2D) | Character sprite; facing/flip. |
| **Companion** | `scenes/companions/companion.tscn` | Small sprite; tint per type (fire, stone, bat, plant, ghost). |
| **Enemies** | All under `scenes/enemies/*.tscn` | Chaser, Lunge, Shooter, Sweeper, Elite Chaser, Flying, Caster, Boss x3. |
| **Projectiles** | `companion_projectile.tscn`, enemy bullets | Use icon or simple shapes; replace with themed projectiles. |
| **Essence pickup** | `scenes/items/essence_pickup.tscn` | Collectible visual. |
| **Hub** | `scenes/hub/hub.tscn` | UI only; add background art if desired. |
| **Stage** | `scenes/stages/stage.tscn` | Floor, walls; add tileset or background. |
| **App icon** | `icon.svg` | Replace with 512×512 (store) and adaptive icon assets (see STORE_ASSETS.md). |

## Juice already added

- Hit flash + camera shake on player hit.
- Stage clear label pop (scale tween).
- Essence drop sparkle (tween + pickup).

## Optional polish

- **Particles:** Hit sparks, death puff, essence collect burst (CPUParticles2D or GPUParticles2D).
- **Sound:** Hit, dodge, attack, stage clear, essence pick-up (AudioStreamPlayer).
- **Animations:** Player walk/attack, companion idle, enemy telegraph/attack (AnimatedSprite2D or AnimationPlayer).

Client can use Gemini or other tools for pixel art; keep resolution and palette consistent (e.g. 16×16 or 32×32 tiles, limited palette).
