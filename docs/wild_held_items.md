# Wild Pokémon Held Item Probabilities

Wild Pokémon held items are resolved at the start of battle by `_RollWildHeldItem`
(`engine/battle/wild_item_drop.asm`). Each species has three item slots in its base
stats: **Item1**, **Item2**, and **Item3**.

The **Mod Held Items** setting (`MODFLAG_WILD_HELD_ITEM_MOD_F`, toggled on page 4 of
the new-game options or in the debug room) controls whether Item3 is eligible.

---

## How the roll works

1. **Item3 check** (only when Mod Held Items is ON and Item3 ≠ `NO_ITEM`):
   - Roll `BattleRandom`.
   - **< 64 (25%)** → hold Item3. Done — the standard roll is skipped.
   - **≥ 64 (75%)** → Item3 not awarded; continue to the standard roll.

2. **Standard roll** (always runs if Item3 was not awarded above):
   - Roll `BattleRandom`.
   - **< 193 (~75%)** → `NO_ITEM`.
   - **≥ 193 (~25%)** → proceed to the item-slot roll:
     - Roll `BattleRandom` again.
     - **< 20 (~8% of this roll → ~2% overall)** → hold Item2.
     - **≥ 20 (~92% of this roll → ~23% overall)** → hold Item1.

---

## Probability tables

### Species with Item1 and/or Item2 set, Item3 = `NO_ITEM`
*(e.g. Paras: TINYMUSHROOM / BIG_MUSHROOM; Marowak: `NO_ITEM` / THICK_CLUB)*

| Outcome  | Flag OFF | Flag ON  |
|----------|----------|----------|
| NO_ITEM  | ~75%     | ~75%     |
| Item1    | ~23%     | ~23%     |
| Item2    | ~2%      | ~2%      |

Flag ON has no effect — Item3 is `NO_ITEM` so the Item3 roll is skipped entirely.

---

### Species with Item1 = `NO_ITEM`, Item2 = `NO_ITEM`, Item3 set
*(e.g. Abra: `NO_ITEM` / `NO_ITEM` / TWISTEDSPOON; Gastly: `NO_ITEM` / `NO_ITEM` / SPELL_TAG)*

| Outcome  | Flag OFF | Flag ON  |
|----------|----------|----------|
| NO_ITEM  | 100%     | ~75%     |
| Item3    | 0%       | ~25%     |

With flag OFF the Item3 roll never runs; the standard roll always yields NO_ITEM.
With flag ON the Item3 roll fires first: 25% chance to hold Item3, otherwise the
standard roll runs (which also yields NO_ITEM since Item1 and Item2 are both unset).

---

### Species with Item3 also set (Item1 or Item2 AND Item3 all non-`NO_ITEM`)
This combination is intentionally unused in the shipped data — species that already
have Item1/Item2 assigned keep Item3 = `NO_ITEM`. If a modder sets all three slots:

| Outcome  | Flag OFF | Flag ON    |
|----------|----------|------------|
| NO_ITEM  | ~75%     | ~56.25%    |
| Item1    | ~23%     | ~17.25%    |
| Item2    | ~2%      | ~1.5%      |
| Item3    | 0%       | ~25%       |

With flag ON, Item3 gets a flat 25% independent roll first. If it fires, the standard
roll is skipped. If it doesn't fire (75% of the time), the standard 75/23/2 split
applies to the remaining probability.

---

### Species with all three slots = `NO_ITEM`
*(e.g. Kangaskhan, Aipom, Tauros)*

| Outcome  | Flag OFF | Flag ON |
|----------|----------|---------|
| NO_ITEM  | 100%     | 100%    |

Flag has no effect.

---

## Special cases

| Battle type           | Behaviour |
|-----------------------|-----------|
| `BATTLETYPE_FORCEITEM` | Bypasses `_RollWildHeldItem` entirely. Item1 is always held (used for Ho-Oh, Lugia, Snorlax). |
| `MODFLAG_WILD_HELD_ITEM_RAND_F` ON | Replaces the standard Item1/Item2 roll with a random pick from `RandomizableItems`. The Item3 roll (if enabled) still runs independently beforehand and is unaffected. |

---

## Item slot assignments

Item slots are defined in `data/pokemon/base_stats/<species>.asm`:

```asm
db Item1, Item2, Item3 ; items
```

- **Item1 / Item2** — the original Crystal held-item system. 61 species have at least
  one non-`NO_ITEM` slot.
- **Item3** — added by this project. Represents a separate, type-flavoured item a
  species can hold, controlled entirely by the **Mod Held Items** flag. It rolls
  independently of Item1/Item2 — both rolls can apply to the same species, and whether
  Item1/Item2 are set has no bearing on whether Item3 is used. Items are assigned
  thematically per type (e.g. Psychic → TWISTEDSPOON, Fire → CHARCOAL).

---

## Species held item reference

| # | Species | Item1 | Item2 | Item3 |
|---|---------|-------|-------|-------|
| 1 | Bulbasaur | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 2 | Ivysaur | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 3 | Venusaur | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 4 | Charmander | NO_ITEM | NO_ITEM | BURNT_BERRY |
| 5 | Charmeleon | NO_ITEM | NO_ITEM | CHARCOAL |
| 6 | Charizard | NO_ITEM | NO_ITEM | CHARCOAL |
| 7 | Squirtle | NO_ITEM | NO_ITEM | NO_ITEM |
| 8 | Wartortle | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 9 | Blastoise | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 10 | Caterpie | NO_ITEM | NO_ITEM | PRZCUREBERRY |
| 11 | Metapod | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 12 | Butterfree | NO_ITEM | SILVERPOWDER | SILVERPOWDER |
| 13 | Weedle | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 14 | Kakuna | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 15 | Beedrill | NO_ITEM | POISON_BARB | POISON_BARB |
| 16 | Pidgey | NO_ITEM | NO_ITEM | BERRY |
| 17 | Pidgeotto | NO_ITEM | NO_ITEM | SHARP_BEAK |
| 18 | Pidgeot | NO_ITEM | NO_ITEM | SHARP_BEAK |
| 19 | Rattata | NO_ITEM | NO_ITEM | BERRY |
| 20 | Raticate | NO_ITEM | NO_ITEM | QUICK_CLAW |
| 21 | Spearow | NO_ITEM | NO_ITEM | NO_ITEM |
| 22 | Fearow | NO_ITEM | SHARP_BEAK | SHARP_BEAK |
| 23 | Ekans | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 24 | Arbok | NO_ITEM | NO_ITEM | POISON_BARB |
| 25 | Pikachu | NO_ITEM | BERRY | LIGHT_BALL |
| 26 | Raichu | NO_ITEM | BERRY | LIGHT_BALL |
| 27 | Sandshrew | NO_ITEM | NO_ITEM | YLW_APRICORN |
| 28 | Sandslash | NO_ITEM | NO_ITEM | SOFT_SAND |
| 29 | Nidoran♀ | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 30 | Nidorina | NO_ITEM | NO_ITEM | MOON_STONE |
| 31 | Nidoqueen | NO_ITEM | NO_ITEM | POISON_BARB |
| 32 | Nidoran♂ | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 33 | Nidorino | NO_ITEM | NO_ITEM | MOON_STONE |
| 34 | Nidoking | NO_ITEM | NO_ITEM | POISON_BARB |
| 35 | Clefairy | MYSTERYBERRY | MOON_STONE | MYSTERYBERRY |
| 36 | Clefable | MYSTERYBERRY | MOON_STONE | MYSTERYBERRY |
| 37 | Vulpix | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY |
| 38 | Ninetales | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY |
| 39 | Jigglypuff | NO_ITEM | NO_ITEM | NO_ITEM |
| 40 | Wigglytuff | NO_ITEM | NO_ITEM | NO_ITEM |
| 41 | Zubat | NO_ITEM | NO_ITEM | NO_ITEM |
| 42 | Golbat | NO_ITEM | NO_ITEM | POISON_BARB |
| 43 | Oddish | NO_ITEM | NO_ITEM | MINT_BERRY |
| 44 | Gloom | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 45 | Vileplume | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 46 | Paras | TINYMUSHROOM | BIG_MUSHROOM | TINYMUSHROOM |
| 47 | Parasect | TINYMUSHROOM | BIG_MUSHROOM | BIG_MUSHROOM |
| 48 | Venonat | NO_ITEM | NO_ITEM | BERRY |
| 49 | Venomoth | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 50 | Diglett | NO_ITEM | NO_ITEM | TINYMUSHROOM |
| 51 | Dugtrio | NO_ITEM | NO_ITEM | SOFT_SAND |
| 52 | Meowth | NO_ITEM | NO_ITEM | QUICK_CLAW |
| 53 | Persian | NO_ITEM | NO_ITEM | QUICK_CLAW |
| 54 | Psyduck | NO_ITEM | NO_ITEM | BITTER_BERRY |
| 55 | Golduck | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 56 | Mankey | NO_ITEM | NO_ITEM | RAGECANDYBAR |
| 57 | Primeape | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 58 | Growlithe | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY |
| 59 | Arcanine | BURNT_BERRY | BURNT_BERRY | NO_ITEM |
| 60 | Poliwag | NO_ITEM | NO_ITEM | FRESH_WATER |
| 61 | Poliwhirl | NO_ITEM | KINGS_ROCK | KINGS_ROCK |
| 62 | Poliwrath | NO_ITEM | KINGS_ROCK | KINGS_ROCK |
| 63 | Abra | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 64 | Kadabra | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 65 | Alakazam | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 66 | Machop | NO_ITEM | NO_ITEM | RAGECANDYBAR |
| 67 | Machoke | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 68 | Machamp | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 69 | Bellsprout | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 70 | Weepinbell | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 71 | Victreebel | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 72 | Tentacool | NO_ITEM | NO_ITEM | NO_ITEM |
| 73 | Tentacruel | NO_ITEM | NO_ITEM | POISON_BARB |
| 74 | Geodude | NO_ITEM | EVERSTONE | EVERSTONE |
| 75 | Graveler | NO_ITEM | EVERSTONE | HARD_STONE |
| 76 | Golem | NO_ITEM | EVERSTONE | HARD_STONE |
| 77 | Ponyta | NO_ITEM | NO_ITEM | BURNT_BERRY |
| 78 | Rapidash | NO_ITEM | NO_ITEM | CHARCOAL |
| 79 | Slowpoke | NO_ITEM | KINGS_ROCK | SLOWPOKETAIL |
| 80 | Slowbro | NO_ITEM | KINGS_ROCK | KINGS_ROCK |
| 81 | Magnemite | NO_ITEM | METAL_COAT | METAL_COAT |
| 82 | Magneton | NO_ITEM | METAL_COAT | METAL_COAT |
| 83 | Farfetch'D | NO_ITEM | STICK | STICK |
| 84 | Doduo | NO_ITEM | NO_ITEM | BERRY |
| 85 | Dodrio | NO_ITEM | SHARP_BEAK | SHARP_BEAK |
| 86 | Seel | NO_ITEM | NO_ITEM | ICE_BERRY |
| 87 | Dewgong | NO_ITEM | NO_ITEM | NEVERMELTICE |
| 88 | Grimer | NO_ITEM | NUGGET | NUGGET |
| 89 | Muk | NO_ITEM | NUGGET | NUGGET |
| 90 | Shellder | PEARL | BIG_PEARL | PEARL |
| 91 | Cloyster | PEARL | BIG_PEARL | BIG_PEARL |
| 92 | Gastly | NO_ITEM | NO_ITEM | BERRY |
| 93 | Haunter | NO_ITEM | NO_ITEM | SPELL_TAG |
| 94 | Gengar | NO_ITEM | NO_ITEM | SPELL_TAG |
| 95 | Onix | NO_ITEM | NO_ITEM | HARD_STONE |
| 96 | Drowzee | NO_ITEM | NO_ITEM | BITTER_BERRY |
| 97 | Hypno | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 98 | Krabby | NO_ITEM | NO_ITEM | RED_APRICORN |
| 99 | Kingler | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 100 | Voltorb | NO_ITEM | NO_ITEM | NO_ITEM |
| 101 | Electrode | NO_ITEM | NO_ITEM | MAGNET |
| 102 | Exeggcute | NO_ITEM | NO_ITEM | BERRY |
| 103 | Exeggutor | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 104 | Cubone | NO_ITEM | THICK_CLUB | THICK_CLUB |
| 105 | Marowak | NO_ITEM | THICK_CLUB | THICK_CLUB |
| 106 | Hitmonlee | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 107 | Hitmonchan | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 108 | Lickitung | NO_ITEM | NO_ITEM | MOOMOO_MILK |
| 109 | Koffing | NO_ITEM | NO_ITEM | PSNCUREBERRY |
| 110 | Weezing | NO_ITEM | NO_ITEM | POISON_BARB |
| 111 | Rhyhorn | NO_ITEM | NO_ITEM | NO_ITEM |
| 112 | Rhydon | NO_ITEM | NO_ITEM | NO_ITEM |
| 113 | Chansey | NO_ITEM | LUCKY_EGG | LUCKY_EGG |
| 114 | Tangela | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 115 | Kangaskhan | NO_ITEM | NO_ITEM | BERRY |
| 116 | Horsea | NO_ITEM | DRAGON_SCALE | NO_ITEM |
| 117 | Seadra | NO_ITEM | DRAGON_SCALE | DRAGON_SCALE |
| 118 | Goldeen | NO_ITEM | NO_ITEM | PEARL |
| 119 | Seaking | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 120 | Staryu | STARDUST | STAR_PIECE | STARDUST |
| 121 | Starmie | STARDUST | STAR_PIECE | STAR_PIECE |
| 122 | Mr. Mime | NO_ITEM | MYSTERYBERRY | MYSTERYBERRY |
| 123 | Scyther | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 124 | Jynx | ICE_BERRY | ICE_BERRY | ICE_BERRY |
| 125 | Electabuzz | NO_ITEM | NO_ITEM | MAGNET |
| 126 | Magmar | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY |
| 127 | Pinsir | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 128 | Tauros | NO_ITEM | NO_ITEM | NO_ITEM |
| 129 | Magikarp | NO_ITEM | NO_ITEM | BERRY |
| 130 | Gyarados | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 131 | Lapras | NO_ITEM | NO_ITEM | NEVERMELTICE |
| 132 | Ditto | NO_ITEM | NO_ITEM | NO_ITEM |
| 133 | Eevee | NO_ITEM | NO_ITEM | EVERSTONE |
| 134 | Vaporeon | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 135 | Jolteon | NO_ITEM | NO_ITEM | MAGNET |
| 136 | Flareon | NO_ITEM | NO_ITEM | CHARCOAL |
| 137 | Porygon | NO_ITEM | NO_ITEM | NO_ITEM |
| 138 | Omanyte | NO_ITEM | NO_ITEM | NO_ITEM |
| 139 | Omastar | NO_ITEM | NO_ITEM | NO_ITEM |
| 140 | Kabuto | NO_ITEM | NO_ITEM | NO_ITEM |
| 141 | Kabutops | NO_ITEM | NO_ITEM | NO_ITEM |
| 142 | Aerodactyl | NO_ITEM | NO_ITEM | HARD_STONE |
| 143 | Snorlax | LEFTOVERS | LEFTOVERS | LEFTOVERS |
| 144 | Articuno | NO_ITEM | NO_ITEM | NEVERMELTICE |
| 145 | Zapdos | NO_ITEM | NO_ITEM | MAGNET |
| 146 | Moltres | NO_ITEM | NO_ITEM | CHARCOAL |
| 147 | Dratini | NO_ITEM | DRAGON_SCALE | BERRY |
| 148 | Dragonair | NO_ITEM | DRAGON_SCALE | DRAGON_SCALE |
| 149 | Dragonite | NO_ITEM | DRAGON_SCALE | DRAGON_SCALE |
| 150 | Mewtwo | NO_ITEM | BERSERK_GENE | BERSERK_GENE |
| 151 | Mew | NO_ITEM | MIRACLEBERRY | MIRACLEBERRY |
| 152 | Chikorita | NO_ITEM | NO_ITEM | NO_ITEM |
| 153 | Bayleef | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 154 | Meganium | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 155 | Cyndaquil | NO_ITEM | NO_ITEM | NO_ITEM |
| 156 | Quilava | NO_ITEM | NO_ITEM | CHARCOAL |
| 157 | Typhlosion | NO_ITEM | NO_ITEM | CHARCOAL |
| 158 | Totodile | NO_ITEM | NO_ITEM | NO_ITEM |
| 159 | Croconaw | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 160 | Feraligatr | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 161 | Sentret | NO_ITEM | BERRY | BERRY |
| 162 | Furret | BERRY | GOLD_BERRY | GOLD_BERRY |
| 163 | Hoothoot | NO_ITEM | NO_ITEM | BLK_APRICORN |
| 164 | Noctowl | NO_ITEM | NO_ITEM | SHARP_BEAK |
| 165 | Ledyba | NO_ITEM | NO_ITEM | TINYMUSHROOM |
| 166 | Ledian | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 167 | Spinarak | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 168 | Ariados | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 169 | Crobat | NO_ITEM | NO_ITEM | POISON_BARB |
| 170 | Chinchou | NO_ITEM | NO_ITEM | PRZCUREBERRY |
| 171 | Lanturn | NO_ITEM | NO_ITEM | MAGNET |
| 172 | Pichu | NO_ITEM | BERRY | BERRY |
| 173 | Cleffa | MYSTERYBERRY | MOON_STONE | MYSTERYBERRY |
| 174 | Igglybuff | NO_ITEM | NO_ITEM | NO_ITEM |
| 175 | Togepi | NO_ITEM | NO_ITEM | BERRY |
| 176 | Togetic | NO_ITEM | NO_ITEM | NO_ITEM |
| 177 | Natu | NO_ITEM | NO_ITEM | GRN_APRICORN |
| 178 | Xatu | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 179 | Mareep | NO_ITEM | NO_ITEM | PRZCUREBERRY |
| 180 | Flaaffy | NO_ITEM | NO_ITEM | MAGNET |
| 181 | Ampharos | NO_ITEM | NO_ITEM | MAGNET |
| 182 | Bellossom | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 183 | Marill | NO_ITEM | NO_ITEM | FRESH_WATER |
| 184 | Azumarill | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 185 | Sudowoodo | NO_ITEM | NO_ITEM | HARD_STONE |
| 186 | Politoed | NO_ITEM | KINGS_ROCK | KINGS_ROCK |
| 187 | Hoppip | NO_ITEM | NO_ITEM | BERRY |
| 188 | Skiploom | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 189 | Jumpluff | NO_ITEM | NO_ITEM | GOLD_BERRY |
| 190 | Aipom | NO_ITEM | NO_ITEM | NO_ITEM |
| 191 | Sunkern | NO_ITEM | NO_ITEM | ENERGY_ROOT |
| 192 | Sunflora | NO_ITEM | NO_ITEM | MIRACLE_SEED |
| 193 | Yanma | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 194 | Wooper | NO_ITEM | NO_ITEM | BLU_APRICORN |
| 195 | Quagsire | NO_ITEM | NO_ITEM | SOFT_SAND |
| 196 | Espeon | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 197 | Umbreon | NO_ITEM | NO_ITEM | BLACKGLASSES |
| 198 | Murkrow | NO_ITEM | NO_ITEM | BLACKGLASSES |
| 199 | Slowking | NO_ITEM | KINGS_ROCK | KINGS_ROCK |
| 200 | Misdreavus | NO_ITEM | SPELL_TAG | SPELL_TAG |
| 201 | Unown | NO_ITEM | NO_ITEM | MYSTERYBERRY |
| 202 | Wobbuffet | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 203 | Girafarig | NO_ITEM | NO_ITEM | TWISTEDSPOON |
| 204 | Pineco | NO_ITEM | NO_ITEM | SILVERPOWDER |
| 205 | Forretress | NO_ITEM | NO_ITEM | METAL_COAT |
| 206 | Dunsparce | NO_ITEM | NO_ITEM | BERRY |
| 207 | Gligar | NO_ITEM | NO_ITEM | SOFT_SAND |
| 208 | Steelix | NO_ITEM | METAL_COAT | METAL_COAT |
| 209 | Snubbull | NO_ITEM | NO_ITEM | TINYMUSHROOM |
| 210 | Granbull | NO_ITEM | NO_ITEM | BIG_MUSHROOM |
| 211 | Qwilfish | NO_ITEM | NO_ITEM | POISON_BARB |
| 212 | Scizor | NO_ITEM | NO_ITEM | METAL_COAT |
| 213 | Shuckle | BERRY | BERRY | BERRY_JUICE |
| 214 | Heracross | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 215 | Sneasel | NO_ITEM | QUICK_CLAW | QUICK_CLAW |
| 216 | Teddiursa | NO_ITEM | NO_ITEM | NO_ITEM |
| 217 | Ursaring | NO_ITEM | NO_ITEM | NO_ITEM |
| 218 | Slugma | NO_ITEM | NO_ITEM | BERRY |
| 219 | Magcargo | NO_ITEM | NO_ITEM | CHARCOAL |
| 220 | Swinub | NO_ITEM | NO_ITEM | NO_ITEM |
| 221 | Piloswine | NO_ITEM | NO_ITEM | NEVERMELTICE |
| 222 | Corsola | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 223 | Remoraid | NO_ITEM | NO_ITEM | FRESH_WATER |
| 224 | Octillery | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 225 | Delibird | NO_ITEM | NO_ITEM | NEVERMELTICE |
| 226 | Mantine | NO_ITEM | NO_ITEM | MYSTERYBERRY |
| 227 | Skarmory | NO_ITEM | NO_ITEM | SHARP_BEAK |
| 228 | Houndour | NO_ITEM | NO_ITEM | BLACKGLASSES |
| 229 | Houndoom | NO_ITEM | NO_ITEM | BLACKGLASSES |
| 230 | Kingdra | NO_ITEM | DRAGON_SCALE | DRAGON_SCALE |
| 231 | Phanpy | NO_ITEM | NO_ITEM | SOFT_SAND |
| 232 | Donphan | NO_ITEM | NO_ITEM | SOFT_SAND |
| 233 | Porygon2 | NO_ITEM | NO_ITEM | NO_ITEM |
| 234 | Stantler | NO_ITEM | NO_ITEM | NO_ITEM |
| 235 | Smeargle | NO_ITEM | NO_ITEM | NO_ITEM |
| 236 | Tyrogue | NO_ITEM | NO_ITEM | BERRY |
| 237 | Hitmontop | NO_ITEM | NO_ITEM | BLACKBELT_I |
| 238 | Smoochum | ICE_BERRY | ICE_BERRY | ICE_BERRY |
| 239 | Elekid | NO_ITEM | NO_ITEM | PRZCUREBERRY |
| 240 | Magby | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY |
| 241 | Miltank | MOOMOO_MILK | MOOMOO_MILK | MOOMOO_MILK |
| 242 | Blissey | NO_ITEM | LUCKY_EGG | LUCKY_EGG |
| 243 | Raikou | NO_ITEM | NO_ITEM | MAGNET |
| 244 | Entei | NO_ITEM | NO_ITEM | CHARCOAL |
| 245 | Suicune | NO_ITEM | NO_ITEM | MYSTIC_WATER |
| 246 | Larvitar | NO_ITEM | NO_ITEM | HARD_STONE |
| 247 | Pupitar | NO_ITEM | NO_ITEM | HARD_STONE |
| 248 | Tyranitar | NO_ITEM | NO_ITEM | HARD_STONE |
| 249 | Lugia | NO_ITEM | NO_ITEM | NO_ITEM |
| 250 | Ho-Oh | SACRED_ASH | SACRED_ASH | SACRED_ASH |
| 251 | Celebi | NO_ITEM | MIRACLEBERRY | MIRACLEBERRY |
