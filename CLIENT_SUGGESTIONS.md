# Suggestions for the client (Combat System Design Document)

**Thank you for the detailed combat doc.** Here are a few suggestions to avoid rework later:

1. **Finalise docs early**  
   Lock the **Item System** (exact effects, synergy list) and **Status Effects** (duration, numbers, which enemies/attacks apply them) as soon as you can. These touch many systems; changing them later is costly.

2. **Clarify “Monsters do not level up” vs “Monster Level Cap: 5”**  
   The doc says both. Please confirm: no monster leveling at all, or leveling with a cap of 5? The current build has companion leveling; we can remove it or cap at 5 to match.

3. **Energy vs cooldowns**  
   Confirm whether **Energy** is used for: (a) dodge only, (b) monster ability only, (c) both, or (d) dodge on cooldown and Energy only for monster/item abilities. That drives UI (one bar vs two) and balance.

4. **Enemy attack indicators**  
   “Red ground indicators” is clear. Specify preferred shape (circle, cone, line) and how long the warning shows (e.g. 0.5 s) so we can keep it consistent across enemies.

5. **Two-item limit**  
   We’ve added **primary** and **secondary** item slots. When you’re ready, a short list of item IDs and their effects (plus monster synergies) will make implementation straightforward.

---

*Milestone 1 has been updated to match the new combat doc (dodge 0.5 s, Energy resource, light knockback, item slots, caps).*
