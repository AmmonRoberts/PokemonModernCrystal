# First Encounter Mode

First Encounter Mode is a built-in Nuzlocke-style challenge option configurable from the **CHALLENGE** page (page 4) of the new-game options screen. It restricts which wild Pokémon the player may attempt to catch based on per-area encounter history.

## Modes

The mode cycles through three values. The setting is saved alongside the other options and persists across save/load.

### DISABLED (default)

No restrictions. Poké Balls work normally. Old saves without this setting stored are treated as DISABLED.

---

### FORGIVING

Classic Nuzlocke rules with a duplicate clause and a wild-flee exception.

| Situation | Result |
|---|---|
| First wild encounter in an area, evo line **not** yet caught | **First encounter** — `!` shown, ball throw allowed |
| First wild encounter in an area, evo line **already caught** | Duplicate clause — area stays OPEN, `!` not shown, player can look for another species |
| Wild Pokémon flees on its own (random flee, Whirlwind, Roar) | Area **reopens** — player gets another chance |
| Player runs away | Area locked as **FAILED** |
| Pokémon knocked out or battle otherwise ends without catching | Area locked as **FAILED** |
| Ball thrown when area is already used (not a first encounter) | Blocked — "You've already had your first encounter in this area!" |

---

### STRICT

First-seen-locks rules. No duplicate clause, no wild-flee reprieve.

| Situation | Result |
|---|---|
| First wild encounter in an area (any species) | **First encounter** — `!` shown, ball throw attempted |
| Evo line already caught, ball thrown | Blocked — duplicate clause does **not** apply |
| Wild Pokémon flees | Area locked as **FAILED** (not reopened) |
| Player runs away | Area locked as **FAILED** |
| Ball thrown when area is already used | Blocked |

---

## Common Rules (both active modes)

- **Intro gate:** Rules do not activate until the player has returned the Mystery Egg to Professor Elm (`EVENT_GAVE_MYSTERY_EGG_TO_ELM`). The 5 starter Poké Balls are given immediately after this event, so by the time the player reaches wild grass the gate is already cleared.
- **Shiny bypass:** Shiny Pokémon (detected by DV values) always bypass the ball-throw block regardless of area state or mode.
- **`!` indicator:** A `!` tile is drawn at the top-right of the enemy info box whenever the current encounter counts as a first encounter (`wNuzlockeFirstEncounter = 1`).
- **Area tracking:** 96 areas are tracked, one per landmark ID. The landmark is determined from the current map group/number via `GetWorldMapLocation`.
- **Evo line deduplication:** "Already caught" checks use the base form of the species' evolution line (resolved via `GetBaseEvolution`) so that catching a Caterpie also counts Metapod and Butterfree as covered.
- **Catching:** A successful catch marks the area as `CAUGHT` (`$FC`) and records the evo line in the caught-lines flag array. Data persists in SRAM.

## Area State Values

| Value | Meaning |
|---|---|
| `$00` | OPEN — no encounter yet |
| `$01`–`$FB` | Species ID of the first encountered Pokémon (encounter in progress / pending resolution) |
| `$FC` | CAUGHT — first encounter was successfully caught |
| `$FD` | FAILED — encounter opportunity used up with no catch |

## Implementation Files

| File | Role |
|---|---|
| `constants/nuzlocke_constants.asm` | Mode and area-state constants |
| `engine/battle/nuzlocke.asm` | Core logic: battle-start check, mark-caught, post-battle resolution |
| `engine/battle/core.asm` | Hook at `.PrintBattleStartText`; wild-flee flag in `TryEnemyFlee` |
| `engine/battle/effect_commands.asm` | Wild-flee flag for Whirlwind/Roar (`.wild_force_flee`) |
| `engine/items/item_effects.asm` | Ball-throw gate and `NuzlockeBlockCatch` in `PokeBallEffect` |
| `engine/overworld/scripting.asm` | Post-battle hook at `.was_wild` → `NuzlockePostBattle` |
| `engine/menus/newgame_options.asm` | Options UI — FIRST ENCOUNTER on page 4 |
| `engine/menus/init_gender.asm` | New-game zero-init of area and caught-line arrays |
| `engine/menus/save.asm` | SRAM save/load of `wNuzlockeAreas` and `wNuzlockeLinesCaught` |
| `ram/wram.asm` | RAM declarations (`wNuzlockeMode` in WRAM0; arrays in WRAMX 2) |
| `ram/sram.asm` | SRAM declarations (`sNuzlockeAreas`, `sNuzlockeLinesCaught` and backup copies) |
