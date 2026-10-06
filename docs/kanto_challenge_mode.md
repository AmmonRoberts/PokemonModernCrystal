# Kanto Challenge Mode

Option name: **KANTO CHALLENGE** (new-game options page 6, debug room page 7).
Values: `OFF`, `LV 1` .. `LV 7` (stored in `wKantoChallengeLevel`; the value is the offset per badge).

## Rules

- Active only while the battle takes place on one of the 8 Kanto gym maps: Pewter, Cerulean, Vermilion, Celadon, Fuchsia, Saffron, Seafoam (Blaine), Viridian.
- Level of every trainer Pokemon in those gyms (leaders and regular gym trainers) is normalized so Kanto can be done in any order:

  `level = min(100, vanilla level - gym anchor + 45 + Kanto badges owned x offset)`

  - The gym anchor is that gym's leader's lowest vanilla level (table below), so the lowest leader Pokemon is level 45 at 0 badges and the rest of the party/gym keeps its vanilla spread above or below it.
  - 45 is `KANTO_GYM_BASE_LEVEL` in `constants/kanto_challenge_constants.asm`; anchors are in `GetKantoGymAnchorLevel` in `engine/battle/read_trainer_party.asm`.

- Kanto badges owned is counted when the battle starts (0-8), regardless of gym order.
- `OFF` = vanilla parties and levels everywhere.
- Gym leaders (except Blue) also load a larger "challenge" party (`<LEADER> (2)` in `data/trainers/parties.asm`) whenever the setting is not `OFF`. Regular gym trainers keep their vanilla party; only their levels are rebased and scaled.

| Gym | Anchor (vanilla level) |
|---|---:|
| Pewter (Brock) | 41 |
| Cerulean (Misty) | 42 |
| Vermilion (Lt. Surge) | 40 |
| Celadon (Erika) | 41 |
| Fuchsia (Janine) | 33 |
| Saffron (Sabrina) | 46 |
| Seafoam (Blaine) | 45 |
| Viridian (Blue) | 54 |

## Level bonus (added to the 0-badge level)

Bonus = badges x offset. Rows: Kanto badges owned. Columns: setting.

| Badges | LV 1 | LV 2 | LV 3 | LV 4 | LV 5 | LV 6 | LV 7 |
|-------:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
| 0 | +0 | +0 | +0 | +0 | +0 | +0 | +0 |
| 1 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| 2 | +2 | +4 | +6 | +8 | +10 | +12 | +14 |
| 3 | +3 | +6 | +9 | +12 | +15 | +18 | +21 |
| 4 | +4 | +8 | +12 | +16 | +20 | +24 | +28 |
| 5 | +5 | +10 | +15 | +20 | +25 | +30 | +35 |
| 6 | +6 | +12 | +18 | +24 | +30 | +36 | +42 |
| 7 | +7 | +14 | +21 | +28 | +35 | +42 | +49 |
| 8 | +8 | +16 | +24 | +32 | +40 | +48 | +56 |

The highest leader level (52 at 0 badges: Ampharos, Gengar) is 87 at 7 badges on `LV 5`, 94 on `LV 6`, and hits the cap of 100 on `LV 7` (52 + 49 = 101, capped). On `LV 6` the cap is reached at 8 badges (52 + 48 = 100); on `LV 7` every Pokemon is 100 at 8 badges.

To find a Pokemon's level: take its 0-badge level from the tables below and add the bonus from the row/column above.

## Party with Kanto Challenge Mode on (levels at 0 badges)

Party order is the in-battle order. Rows marked **new** exist only in the challenge party. "Vanilla" is the unmodified level; "0 badges" = vanilla - anchor + 45.

### Brock (Pewter Gym) - 6 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Graveler | 41 | 45 | Defense Curl, Rock Slide, Rollout, Earthquake |
| Rhyhorn | 41 | 45 | Fury Attack, Scary Face, Earthquake, Horn Drill |
| Omastar | 42 | 46 | Bite, Surf, Protect, Spike Cannon |
| Onix | 44 | 48 | Bind, Rock Slide, Bide, Sandstorm |
| Kabutops | 42 | 46 | Slash, Surf, Endure, Giga Drain |
| **Steelix (new)** | 45 | 49 | Rock Slide, Earthquake, Screech, Iron Tail |

### Misty (Cerulean Gym) - 6 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Golduck | 42 | 45 | Surf, Disable, Psych Up, Psychic |
| Quagsire | 42 | 45 | Surf, Amnesia, Earthquake, Rain Dance |
| Lapras | 44 | 47 | Surf, Perish Song, Blizzard, Rain Dance |
| **Vaporeon (new)** | 44 | 47 | Surf, Ice Beam, Aurora Beam, Haze |
| **Kingdra (new)** | 46 | 49 | Surf, Ice Beam, Agility, Smokescreen |
| Starmie | 47 | 50 | Surf, Confuse Ray, Recover, Ice Beam |

### Lt. Surge (Vermilion Gym) - 6 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Raichu | 44 | 49 | Thunder Wave, Quick Attack, Thunderbolt, Thunder |
| Electrode | 40 | 45 | Screech, Double Team, Swift, Explosion |
| Magneton | 40 | 45 | Lock-On, Double Team, Swift, Zap Cannon |
| Electrode | 40 | 45 | Screech, Double Team, Swift, Explosion |
| **Ampharos (new)** | 47 | 52 | Thunderbolt, Thunder Wave, Light Screen, Cotton Spore |
| Electabuzz | 46 | 51 | Quick Attack, Thunderpunch, Light Screen, Thunder |

### Erika (Celadon Gym) - 6 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Tangela | 42 | 46 | Vine Whip, Bind, Giga Drain, Sleep Powder |
| Jumpluff | 41 | 45 | Mega Drain, Leech Seed, Cotton Spore, Giga Drain |
| **Meganium (new)** | 44 | 48 | Razor Leaf, Body Slam, Reflect, Light Screen |
| Victreebel | 46 | 50 | Sunny Day, Synthesis, Acid, Razor Leaf |
| **Vileplume (new)** | 46 | 50 | Solarbeam, Sleep Powder, Mega Drain, Petal Dance |
| Bellossom | 46 | 50 | Sunny Day, Synthesis, Petal Dance, Solarbeam |

### Janine (Fuchsia Gym) - 6 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Crobat | 36 | 48 | Screech, Supersonic, Confuse Ray, Wing Attack |
| Weezing | 36 | 48 | Smog, Sludge Bomb, Toxic, Explosion |
| Weezing | 36 | 48 | Smog, Sludge Bomb, Toxic, Explosion |
| Ariados | 33 | 45 | Scary Face, Giga Drain, String Shot, Night Shade |
| **Gengar (new)** | 40 | 52 | Sludge Bomb, Shadow Ball, Hypnosis, Destiny Bond |
| Venomoth | 39 | 51 | Foresight, Double Team, Gust, Psychic |

### Sabrina (Saffron Gym) - 5 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Espeon | 46 | 45 | Sand-Attack, Quick Attack, Swift, Psychic |
| Mr. Mime | 46 | 45 | Barrier, Reflect, Baton Pass, Psychic |
| **Xatu (new)** | 46 | 45 | Psychic, Confuse Ray, Dream Eater, Reflect |
| **Slowking (new)** | 47 | 46 | Psychic, Surf, Curse, Toxic |
| Alakazam | 48 | 47 | Recover, Future Sight, Psychic, Reflect |

### Blaine (Seafoam Gym) - 5 Pokemon

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Magcargo | 45 | 45 | Curse, Smog, Flamethrower, Rock Slide |
| Magmar | 45 | 45 | Thunderpunch, Fire Punch, Sunny Day, Confuse Ray |
| **Typhlosion (new)** | 47 | 47 | Flamethrower, Earthquake, Swift, Reversal |
| **Houndoom (new)** | 48 | 48 | Crunch, Flamethrower, Roar, Faint Attack |
| Rapidash | 50 | 50 | Quick Attack, Fire Spin, Fury Attack, Fire Blast |

### Blue (Viridian Gym) - 6 Pokemon (no extra Pokemon; levels scale only)

| Pokemon | Vanilla | 0 badges | Moves |
|---|---:|---:|---|
| Pidgeot | 56 | 47 | Quick Attack, Whirlwind, Wing Attack, Mirror Move |
| Alakazam | 54 | 45 | Disable, Recover, Psychic, Reflect |
| Rhydon | 56 | 47 | Fury Attack, Sandstorm, Rock Slide, Earthquake |
| Gyarados | 58 | 49 | Twister, Hydro Pump, Rain Dance, Hyper Beam |
| Exeggutor | 58 | 49 | Sunny Day, Leech Seed, Egg Bomb, Solarbeam |
| Arcanine | 58 | 49 | Roar, Swift, Flamethrower, Extremespeed |

## Vanilla party (setting `OFF`)

Same as the tables above without the **new** rows and with the unmodified (vanilla) levels:
Brock 5, Misty 4, Lt. Surge 5, Erika 4, Janine 5, Sabrina 3, Blaine 3, Blue 6 Pokemon.

## Worked example

Misty, setting `LV 3`, 4 Kanto badges owned: bonus = 4 x 3 = +12.
Golduck 57, Quagsire 57, Lapras 59, Vaporeon 59, Kingdra 61, Starmie 62.

## Explicit levels per setting, gym and badge count

Computed with `vanilla - anchor + 45 + badges x offset` (cap 100). Columns are Kanto badges owned (0-7; a leader's own badge is not owned yet on the first fight). Party order is the in-battle order.

### Setting LV 1 (+1 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Rhyhorn | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Omastar | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 |
| Onix | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
| Kabutops | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 |
| Steelix (new) | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Quagsire | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Lapras | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 |
| Vaporeon (new) | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 |
| Kingdra (new) | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 |
| Starmie | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 |
| Electrode | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Magneton | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Electrode | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Ampharos (new) | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 |
| Electabuzz | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 |
| Jumpluff | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Meganium (new) | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
| Victreebel | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 |
| Vileplume (new) | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 |
| Bellossom | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
| Weezing | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
| Weezing | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
| Ariados | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Gengar (new) | 52 | 53 | 54 | 55 | 56 | 57 | 58 | 59 |
| Venomoth | 51 | 52 | 53 | 54 | 55 | 56 | 57 | 58 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Mr. Mime | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Xatu (new) | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Slowking (new) | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 |
| Alakazam | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Magmar | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Typhlosion (new) | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 |
| Houndoom (new) | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |
| Rapidash | 50 | 51 | 52 | 53 | 54 | 55 | 56 | 57 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 |
| Alakazam | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 |
| Rhydon | 47 | 48 | 49 | 50 | 51 | 52 | 53 | 54 |
| Gyarados | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 |
| Exeggutor | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 |
| Arcanine | 49 | 50 | 51 | 52 | 53 | 54 | 55 | 56 |

### Setting LV 2 (+2 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Rhyhorn | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Omastar | 46 | 48 | 50 | 52 | 54 | 56 | 58 | 60 |
| Onix | 48 | 50 | 52 | 54 | 56 | 58 | 60 | 62 |
| Kabutops | 46 | 48 | 50 | 52 | 54 | 56 | 58 | 60 |
| Steelix (new) | 49 | 51 | 53 | 55 | 57 | 59 | 61 | 63 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Quagsire | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Lapras | 47 | 49 | 51 | 53 | 55 | 57 | 59 | 61 |
| Vaporeon (new) | 47 | 49 | 51 | 53 | 55 | 57 | 59 | 61 |
| Kingdra (new) | 49 | 51 | 53 | 55 | 57 | 59 | 61 | 63 |
| Starmie | 50 | 52 | 54 | 56 | 58 | 60 | 62 | 64 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 51 | 53 | 55 | 57 | 59 | 61 | 63 |
| Electrode | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Magneton | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Electrode | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Ampharos (new) | 52 | 54 | 56 | 58 | 60 | 62 | 64 | 66 |
| Electabuzz | 51 | 53 | 55 | 57 | 59 | 61 | 63 | 65 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 48 | 50 | 52 | 54 | 56 | 58 | 60 |
| Jumpluff | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Meganium (new) | 48 | 50 | 52 | 54 | 56 | 58 | 60 | 62 |
| Victreebel | 50 | 52 | 54 | 56 | 58 | 60 | 62 | 64 |
| Vileplume (new) | 50 | 52 | 54 | 56 | 58 | 60 | 62 | 64 |
| Bellossom | 50 | 52 | 54 | 56 | 58 | 60 | 62 | 64 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 50 | 52 | 54 | 56 | 58 | 60 | 62 |
| Weezing | 48 | 50 | 52 | 54 | 56 | 58 | 60 | 62 |
| Weezing | 48 | 50 | 52 | 54 | 56 | 58 | 60 | 62 |
| Ariados | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Gengar (new) | 52 | 54 | 56 | 58 | 60 | 62 | 64 | 66 |
| Venomoth | 51 | 53 | 55 | 57 | 59 | 61 | 63 | 65 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Mr. Mime | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Xatu (new) | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Slowking (new) | 46 | 48 | 50 | 52 | 54 | 56 | 58 | 60 |
| Alakazam | 47 | 49 | 51 | 53 | 55 | 57 | 59 | 61 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Magmar | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Typhlosion (new) | 47 | 49 | 51 | 53 | 55 | 57 | 59 | 61 |
| Houndoom (new) | 48 | 50 | 52 | 54 | 56 | 58 | 60 | 62 |
| Rapidash | 50 | 52 | 54 | 56 | 58 | 60 | 62 | 64 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 49 | 51 | 53 | 55 | 57 | 59 | 61 |
| Alakazam | 45 | 47 | 49 | 51 | 53 | 55 | 57 | 59 |
| Rhydon | 47 | 49 | 51 | 53 | 55 | 57 | 59 | 61 |
| Gyarados | 49 | 51 | 53 | 55 | 57 | 59 | 61 | 63 |
| Exeggutor | 49 | 51 | 53 | 55 | 57 | 59 | 61 | 63 |
| Arcanine | 49 | 51 | 53 | 55 | 57 | 59 | 61 | 63 |

### Setting LV 3 (+3 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Rhyhorn | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Omastar | 46 | 49 | 52 | 55 | 58 | 61 | 64 | 67 |
| Onix | 48 | 51 | 54 | 57 | 60 | 63 | 66 | 69 |
| Kabutops | 46 | 49 | 52 | 55 | 58 | 61 | 64 | 67 |
| Steelix (new) | 49 | 52 | 55 | 58 | 61 | 64 | 67 | 70 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Quagsire | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Lapras | 47 | 50 | 53 | 56 | 59 | 62 | 65 | 68 |
| Vaporeon (new) | 47 | 50 | 53 | 56 | 59 | 62 | 65 | 68 |
| Kingdra (new) | 49 | 52 | 55 | 58 | 61 | 64 | 67 | 70 |
| Starmie | 50 | 53 | 56 | 59 | 62 | 65 | 68 | 71 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 52 | 55 | 58 | 61 | 64 | 67 | 70 |
| Electrode | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Magneton | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Electrode | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Ampharos (new) | 52 | 55 | 58 | 61 | 64 | 67 | 70 | 73 |
| Electabuzz | 51 | 54 | 57 | 60 | 63 | 66 | 69 | 72 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 49 | 52 | 55 | 58 | 61 | 64 | 67 |
| Jumpluff | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Meganium (new) | 48 | 51 | 54 | 57 | 60 | 63 | 66 | 69 |
| Victreebel | 50 | 53 | 56 | 59 | 62 | 65 | 68 | 71 |
| Vileplume (new) | 50 | 53 | 56 | 59 | 62 | 65 | 68 | 71 |
| Bellossom | 50 | 53 | 56 | 59 | 62 | 65 | 68 | 71 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 51 | 54 | 57 | 60 | 63 | 66 | 69 |
| Weezing | 48 | 51 | 54 | 57 | 60 | 63 | 66 | 69 |
| Weezing | 48 | 51 | 54 | 57 | 60 | 63 | 66 | 69 |
| Ariados | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Gengar (new) | 52 | 55 | 58 | 61 | 64 | 67 | 70 | 73 |
| Venomoth | 51 | 54 | 57 | 60 | 63 | 66 | 69 | 72 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Mr. Mime | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Xatu (new) | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Slowking (new) | 46 | 49 | 52 | 55 | 58 | 61 | 64 | 67 |
| Alakazam | 47 | 50 | 53 | 56 | 59 | 62 | 65 | 68 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Magmar | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Typhlosion (new) | 47 | 50 | 53 | 56 | 59 | 62 | 65 | 68 |
| Houndoom (new) | 48 | 51 | 54 | 57 | 60 | 63 | 66 | 69 |
| Rapidash | 50 | 53 | 56 | 59 | 62 | 65 | 68 | 71 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 50 | 53 | 56 | 59 | 62 | 65 | 68 |
| Alakazam | 45 | 48 | 51 | 54 | 57 | 60 | 63 | 66 |
| Rhydon | 47 | 50 | 53 | 56 | 59 | 62 | 65 | 68 |
| Gyarados | 49 | 52 | 55 | 58 | 61 | 64 | 67 | 70 |
| Exeggutor | 49 | 52 | 55 | 58 | 61 | 64 | 67 | 70 |
| Arcanine | 49 | 52 | 55 | 58 | 61 | 64 | 67 | 70 |

### Setting LV 4 (+4 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Rhyhorn | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Omastar | 46 | 50 | 54 | 58 | 62 | 66 | 70 | 74 |
| Onix | 48 | 52 | 56 | 60 | 64 | 68 | 72 | 76 |
| Kabutops | 46 | 50 | 54 | 58 | 62 | 66 | 70 | 74 |
| Steelix (new) | 49 | 53 | 57 | 61 | 65 | 69 | 73 | 77 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Quagsire | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Lapras | 47 | 51 | 55 | 59 | 63 | 67 | 71 | 75 |
| Vaporeon (new) | 47 | 51 | 55 | 59 | 63 | 67 | 71 | 75 |
| Kingdra (new) | 49 | 53 | 57 | 61 | 65 | 69 | 73 | 77 |
| Starmie | 50 | 54 | 58 | 62 | 66 | 70 | 74 | 78 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 53 | 57 | 61 | 65 | 69 | 73 | 77 |
| Electrode | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Magneton | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Electrode | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Ampharos (new) | 52 | 56 | 60 | 64 | 68 | 72 | 76 | 80 |
| Electabuzz | 51 | 55 | 59 | 63 | 67 | 71 | 75 | 79 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 50 | 54 | 58 | 62 | 66 | 70 | 74 |
| Jumpluff | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Meganium (new) | 48 | 52 | 56 | 60 | 64 | 68 | 72 | 76 |
| Victreebel | 50 | 54 | 58 | 62 | 66 | 70 | 74 | 78 |
| Vileplume (new) | 50 | 54 | 58 | 62 | 66 | 70 | 74 | 78 |
| Bellossom | 50 | 54 | 58 | 62 | 66 | 70 | 74 | 78 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 52 | 56 | 60 | 64 | 68 | 72 | 76 |
| Weezing | 48 | 52 | 56 | 60 | 64 | 68 | 72 | 76 |
| Weezing | 48 | 52 | 56 | 60 | 64 | 68 | 72 | 76 |
| Ariados | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Gengar (new) | 52 | 56 | 60 | 64 | 68 | 72 | 76 | 80 |
| Venomoth | 51 | 55 | 59 | 63 | 67 | 71 | 75 | 79 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Mr. Mime | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Xatu (new) | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Slowking (new) | 46 | 50 | 54 | 58 | 62 | 66 | 70 | 74 |
| Alakazam | 47 | 51 | 55 | 59 | 63 | 67 | 71 | 75 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Magmar | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Typhlosion (new) | 47 | 51 | 55 | 59 | 63 | 67 | 71 | 75 |
| Houndoom (new) | 48 | 52 | 56 | 60 | 64 | 68 | 72 | 76 |
| Rapidash | 50 | 54 | 58 | 62 | 66 | 70 | 74 | 78 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 51 | 55 | 59 | 63 | 67 | 71 | 75 |
| Alakazam | 45 | 49 | 53 | 57 | 61 | 65 | 69 | 73 |
| Rhydon | 47 | 51 | 55 | 59 | 63 | 67 | 71 | 75 |
| Gyarados | 49 | 53 | 57 | 61 | 65 | 69 | 73 | 77 |
| Exeggutor | 49 | 53 | 57 | 61 | 65 | 69 | 73 | 77 |
| Arcanine | 49 | 53 | 57 | 61 | 65 | 69 | 73 | 77 |

### Setting LV 5 (+5 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Rhyhorn | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Omastar | 46 | 51 | 56 | 61 | 66 | 71 | 76 | 81 |
| Onix | 48 | 53 | 58 | 63 | 68 | 73 | 78 | 83 |
| Kabutops | 46 | 51 | 56 | 61 | 66 | 71 | 76 | 81 |
| Steelix (new) | 49 | 54 | 59 | 64 | 69 | 74 | 79 | 84 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Quagsire | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Lapras | 47 | 52 | 57 | 62 | 67 | 72 | 77 | 82 |
| Vaporeon (new) | 47 | 52 | 57 | 62 | 67 | 72 | 77 | 82 |
| Kingdra (new) | 49 | 54 | 59 | 64 | 69 | 74 | 79 | 84 |
| Starmie | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 54 | 59 | 64 | 69 | 74 | 79 | 84 |
| Electrode | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Magneton | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Electrode | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Ampharos (new) | 52 | 57 | 62 | 67 | 72 | 77 | 82 | 87 |
| Electabuzz | 51 | 56 | 61 | 66 | 71 | 76 | 81 | 86 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 51 | 56 | 61 | 66 | 71 | 76 | 81 |
| Jumpluff | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Meganium (new) | 48 | 53 | 58 | 63 | 68 | 73 | 78 | 83 |
| Victreebel | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 |
| Vileplume (new) | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 |
| Bellossom | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 53 | 58 | 63 | 68 | 73 | 78 | 83 |
| Weezing | 48 | 53 | 58 | 63 | 68 | 73 | 78 | 83 |
| Weezing | 48 | 53 | 58 | 63 | 68 | 73 | 78 | 83 |
| Ariados | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Gengar (new) | 52 | 57 | 62 | 67 | 72 | 77 | 82 | 87 |
| Venomoth | 51 | 56 | 61 | 66 | 71 | 76 | 81 | 86 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Mr. Mime | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Xatu (new) | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Slowking (new) | 46 | 51 | 56 | 61 | 66 | 71 | 76 | 81 |
| Alakazam | 47 | 52 | 57 | 62 | 67 | 72 | 77 | 82 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Magmar | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Typhlosion (new) | 47 | 52 | 57 | 62 | 67 | 72 | 77 | 82 |
| Houndoom (new) | 48 | 53 | 58 | 63 | 68 | 73 | 78 | 83 |
| Rapidash | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 52 | 57 | 62 | 67 | 72 | 77 | 82 |
| Alakazam | 45 | 50 | 55 | 60 | 65 | 70 | 75 | 80 |
| Rhydon | 47 | 52 | 57 | 62 | 67 | 72 | 77 | 82 |
| Gyarados | 49 | 54 | 59 | 64 | 69 | 74 | 79 | 84 |
| Exeggutor | 49 | 54 | 59 | 64 | 69 | 74 | 79 | 84 |
| Arcanine | 49 | 54 | 59 | 64 | 69 | 74 | 79 | 84 |

### Setting LV 6 (+6 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Rhyhorn | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Omastar | 46 | 52 | 58 | 64 | 70 | 76 | 82 | 88 |
| Onix | 48 | 54 | 60 | 66 | 72 | 78 | 84 | 90 |
| Kabutops | 46 | 52 | 58 | 64 | 70 | 76 | 82 | 88 |
| Steelix (new) | 49 | 55 | 61 | 67 | 73 | 79 | 85 | 91 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Quagsire | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Lapras | 47 | 53 | 59 | 65 | 71 | 77 | 83 | 89 |
| Vaporeon (new) | 47 | 53 | 59 | 65 | 71 | 77 | 83 | 89 |
| Kingdra (new) | 49 | 55 | 61 | 67 | 73 | 79 | 85 | 91 |
| Starmie | 50 | 56 | 62 | 68 | 74 | 80 | 86 | 92 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 55 | 61 | 67 | 73 | 79 | 85 | 91 |
| Electrode | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Magneton | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Electrode | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Ampharos (new) | 52 | 58 | 64 | 70 | 76 | 82 | 88 | 94 |
| Electabuzz | 51 | 57 | 63 | 69 | 75 | 81 | 87 | 93 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 52 | 58 | 64 | 70 | 76 | 82 | 88 |
| Jumpluff | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Meganium (new) | 48 | 54 | 60 | 66 | 72 | 78 | 84 | 90 |
| Victreebel | 50 | 56 | 62 | 68 | 74 | 80 | 86 | 92 |
| Vileplume (new) | 50 | 56 | 62 | 68 | 74 | 80 | 86 | 92 |
| Bellossom | 50 | 56 | 62 | 68 | 74 | 80 | 86 | 92 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 54 | 60 | 66 | 72 | 78 | 84 | 90 |
| Weezing | 48 | 54 | 60 | 66 | 72 | 78 | 84 | 90 |
| Weezing | 48 | 54 | 60 | 66 | 72 | 78 | 84 | 90 |
| Ariados | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Gengar (new) | 52 | 58 | 64 | 70 | 76 | 82 | 88 | 94 |
| Venomoth | 51 | 57 | 63 | 69 | 75 | 81 | 87 | 93 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Mr. Mime | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Xatu (new) | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Slowking (new) | 46 | 52 | 58 | 64 | 70 | 76 | 82 | 88 |
| Alakazam | 47 | 53 | 59 | 65 | 71 | 77 | 83 | 89 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Magmar | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Typhlosion (new) | 47 | 53 | 59 | 65 | 71 | 77 | 83 | 89 |
| Houndoom (new) | 48 | 54 | 60 | 66 | 72 | 78 | 84 | 90 |
| Rapidash | 50 | 56 | 62 | 68 | 74 | 80 | 86 | 92 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 53 | 59 | 65 | 71 | 77 | 83 | 89 |
| Alakazam | 45 | 51 | 57 | 63 | 69 | 75 | 81 | 87 |
| Rhydon | 47 | 53 | 59 | 65 | 71 | 77 | 83 | 89 |
| Gyarados | 49 | 55 | 61 | 67 | 73 | 79 | 85 | 91 |
| Exeggutor | 49 | 55 | 61 | 67 | 73 | 79 | 85 | 91 |
| Arcanine | 49 | 55 | 61 | 67 | 73 | 79 | 85 | 91 |

### Setting LV 7 (+7 per badge)

#### Brock (Pewter)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Graveler | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Rhyhorn | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Omastar | 46 | 53 | 60 | 67 | 74 | 81 | 88 | 95 |
| Onix | 48 | 55 | 62 | 69 | 76 | 83 | 90 | 97 |
| Kabutops | 46 | 53 | 60 | 67 | 74 | 81 | 88 | 95 |
| Steelix (new) | 49 | 56 | 63 | 70 | 77 | 84 | 91 | 98 |

#### Misty (Cerulean)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Golduck | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Quagsire | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Lapras | 47 | 54 | 61 | 68 | 75 | 82 | 89 | 96 |
| Vaporeon (new) | 47 | 54 | 61 | 68 | 75 | 82 | 89 | 96 |
| Kingdra (new) | 49 | 56 | 63 | 70 | 77 | 84 | 91 | 98 |
| Starmie | 50 | 57 | 64 | 71 | 78 | 85 | 92 | 99 |

#### Lt. Surge (Vermilion)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Raichu | 49 | 56 | 63 | 70 | 77 | 84 | 91 | 98 |
| Electrode | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Magneton | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Electrode | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Ampharos (new) | 52 | 59 | 66 | 73 | 80 | 87 | 94 | 100 |
| Electabuzz | 51 | 58 | 65 | 72 | 79 | 86 | 93 | 100 |

#### Erika (Celadon)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Tangela | 46 | 53 | 60 | 67 | 74 | 81 | 88 | 95 |
| Jumpluff | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Meganium (new) | 48 | 55 | 62 | 69 | 76 | 83 | 90 | 97 |
| Victreebel | 50 | 57 | 64 | 71 | 78 | 85 | 92 | 99 |
| Vileplume (new) | 50 | 57 | 64 | 71 | 78 | 85 | 92 | 99 |
| Bellossom | 50 | 57 | 64 | 71 | 78 | 85 | 92 | 99 |

#### Janine (Fuchsia)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Crobat | 48 | 55 | 62 | 69 | 76 | 83 | 90 | 97 |
| Weezing | 48 | 55 | 62 | 69 | 76 | 83 | 90 | 97 |
| Weezing | 48 | 55 | 62 | 69 | 76 | 83 | 90 | 97 |
| Ariados | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Gengar (new) | 52 | 59 | 66 | 73 | 80 | 87 | 94 | 100 |
| Venomoth | 51 | 58 | 65 | 72 | 79 | 86 | 93 | 100 |

#### Sabrina (Saffron)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Espeon | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Mr. Mime | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Xatu (new) | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Slowking (new) | 46 | 53 | 60 | 67 | 74 | 81 | 88 | 95 |
| Alakazam | 47 | 54 | 61 | 68 | 75 | 82 | 89 | 96 |

#### Blaine (Seafoam)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Magcargo | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Magmar | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Typhlosion (new) | 47 | 54 | 61 | 68 | 75 | 82 | 89 | 96 |
| Houndoom (new) | 48 | 55 | 62 | 69 | 76 | 83 | 90 | 97 |
| Rapidash | 50 | 57 | 64 | 71 | 78 | 85 | 92 | 99 |

#### Blue (Viridian)

| Pokemon | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| Pidgeot | 47 | 54 | 61 | 68 | 75 | 82 | 89 | 96 |
| Alakazam | 45 | 52 | 59 | 66 | 73 | 80 | 87 | 94 |
| Rhydon | 47 | 54 | 61 | 68 | 75 | 82 | 89 | 96 |
| Gyarados | 49 | 56 | 63 | 70 | 77 | 84 | 91 | 98 |
| Exeggutor | 49 | 56 | 63 | 70 | 77 | 84 | 91 | 98 |
| Arcanine | 49 | 56 | 63 | 70 | 77 | 84 | 91 | 98 |

## Notes

- To change the baseline, edit `KANTO_GYM_BASE_LEVEL`; to change one gym's relative strength, edit its anchor (a higher anchor lowers that gym's levels).
- Regular gym trainers are rebased with their gym's anchor, so a trainer below the leader's lowest level ends up below 45 at 0 badges.
- The additional Pokemon and movesets are proposals pending review.
- Randomizer options (trainers/bosses) are not yet verified against the added second party per leader.
