# Debug Room Warp Guide

## Opening the Debug Room

Hold **SELECT + START** while standing in the overworld. The debug room menu opens immediately.

After closing the debug room (press **B** to exit), the map graphics are automatically refreshed — there is a brief fade. This is normal.

---

## WARP TO — How It Works

The **WARP TO** option is on **Page 3** of the debug room (cycle pages with the **NEXT** option at the bottom of each page).

1. Select **WARP TO** and press **A**.
2. Two values appear:
   - **GROUP** — the map group (hex)
   - **MAP** — the map number within that group (hex)
3. The currently highlighted field has a `▶` cursor.
4. Press **RIGHT** to increment the value, **LEFT** to decrement.
5. Press **DOWN** to move the cursor to the next field, **UP** to go back.
6. Once GROUP and MAP are set, press **START** to queue the warp.
7. Press **B** to close the warp editor, then **B** again to close the main debug menu.
8. The warp executes automatically — the screen fades and the player appears at the **first warp entrance** (warp event 1) of the destination map.

> **Note:** The default on opening is GROUP `07H`, MAP `06H` (Cerulean Gym), which is useful for testing the MACHINE_PART randomizer protection.

> **Note:** Warping to outdoor routes and cities places the player at their first building entrance warp, which may not be the centre of the map. Beta/unused maps (marked below) may crash or behave unexpectedly.

---

## Quick Reference — Randomizer Test Destinations

| Destination | GROUP | MAP | What to test |
|---|---|---|---|
| Cerulean Gym | `07H` | `06H` | MACHINE_PART hidden item |
| Ice Path 1F | `03H` | `3DH` | HM_WATERFALL item ball |
| Goldenrod Underground | `03H` | `35H` | COIN_CASE item ball |

---

## Full Map Table

The GROUP and MAP values are in **hex**, matching the display in the debug room.

### Group 01H — Olivine

| Map | GROUP | MAP |
|---|---|---|
| Olivine Pokécenter 1F | `01H` | `01H` |
| Olivine Gym | `01H` | `02H` |
| Tim's House | `01H` | `03H` |
| Olivine House (Beta) | `01H` | `04H` |
| Punishment Speech House | `01H` | `05H` |
| Good Rod House | `01H` | `06H` |
| Olivine Café | `01H` | `07H` |
| Olivine Mart | `01H` | `08H` |
| Route 38 Ecruteak Gate | `01H` | `09H` |
| Route 39 Barn | `01H` | `0AH` |
| Route 39 Farmhouse | `01H` | `0BH` |
| Route 38 | `01H` | `0CH` |
| Route 39 | `01H` | `0DH` |
| Olivine City | `01H` | `0EH` |

### Group 02H — Mahogany

| Map | GROUP | MAP |
|---|---|---|
| Red Gyarados Speech House | `02H` | `01H` |
| Mahogany Gym | `02H` | `02H` |
| Mahogany Pokécenter 1F | `02H` | `03H` |
| Route 42 Ecruteak Gate | `02H` | `04H` |
| Route 42 | `02H` | `05H` |
| Route 44 | `02H` | `06H` |
| Mahogany Town | `02H` | `07H` |

### Group 03H — Dungeons

| Map | GROUP | MAP |
|---|---|---|
| Sprout Tower 1F | `03H` | `01H` |
| Sprout Tower 2F | `03H` | `02H` |
| Sprout Tower 3F | `03H` | `03H` |
| Tin Tower 1F | `03H` | `04H` |
| Tin Tower 2F | `03H` | `05H` |
| Tin Tower 3F | `03H` | `06H` |
| Tin Tower 4F | `03H` | `07H` |
| Tin Tower 5F | `03H` | `08H` |
| Tin Tower 6F | `03H` | `09H` |
| Tin Tower 7F | `03H` | `0AH` |
| Tin Tower 8F | `03H` | `0BH` |
| Tin Tower 9F | `03H` | `0CH` |
| Burned Tower 1F | `03H` | `0DH` |
| Burned Tower B1F | `03H` | `0EH` |
| National Park | `03H` | `0FH` |
| National Park (Bug Contest) | `03H` | `10H` |
| Radio Tower 1F | `03H` | `11H` |
| Radio Tower 2F | `03H` | `12H` |
| Radio Tower 3F | `03H` | `13H` |
| Radio Tower 4F | `03H` | `14H` |
| Radio Tower 5F | `03H` | `15H` |
| Ruins of Alph Outside | `03H` | `16H` |
| Ruins of Alph — Ho-Oh Chamber | `03H` | `17H` |
| Ruins of Alph — Kabuto Chamber | `03H` | `18H` |
| Ruins of Alph — Omanyte Chamber | `03H` | `19H` |
| Ruins of Alph — Aerodactyl Chamber | `03H` | `1AH` |
| Ruins of Alph Inner Chamber | `03H` | `1BH` |
| Ruins of Alph Research Center | `03H` | `1CH` |
| Ruins of Alph — Ho-Oh Item Room | `03H` | `1DH` |
| Ruins of Alph — Kabuto Item Room | `03H` | `1EH` |
| Ruins of Alph — Omanyte Item Room | `03H` | `1FH` |
| Ruins of Alph — Aerodactyl Item Room | `03H` | `20H` |
| Ruins of Alph — Ho-Oh Word Room | `03H` | `21H` |
| Ruins of Alph — Kabuto Word Room | `03H` | `22H` |
| Ruins of Alph — Omanyte Word Room | `03H` | `23H` |
| Ruins of Alph — Aerodactyl Word Room | `03H` | `24H` |
| Union Cave 1F | `03H` | `25H` |
| Union Cave B1F | `03H` | `26H` |
| Union Cave B2F | `03H` | `27H` |
| Slowpoke Well B1F | `03H` | `28H` |
| Slowpoke Well B2F | `03H` | `29H` |
| Olivine Lighthouse 1F | `03H` | `2AH` |
| Olivine Lighthouse 2F | `03H` | `2BH` |
| Olivine Lighthouse 3F | `03H` | `2CH` |
| Olivine Lighthouse 4F | `03H` | `2DH` |
| Olivine Lighthouse 5F | `03H` | `2EH` |
| Olivine Lighthouse 6F | `03H` | `2FH` |
| Mahogany Mart 1F | `03H` | `30H` |
| Team Rocket Base B1F | `03H` | `31H` |
| Team Rocket Base B2F | `03H` | `32H` |
| Team Rocket Base B3F | `03H` | `33H` |
| Ilex Forest | `03H` | `34H` |
| Goldenrod Underground | `03H` | `35H` |
| Goldenrod Underground Switch Room | `03H` | `36H` |
| Goldenrod Dept Store B1F | `03H` | `37H` |
| Goldenrod Underground Warehouse | `03H` | `38H` |
| Mt. Mortar 1F Outside | `03H` | `39H` |
| Mt. Mortar 1F Inside | `03H` | `3AH` |
| Mt. Mortar 2F Inside | `03H` | `3BH` |
| Mt. Mortar B1F | `03H` | `3CH` |
| Ice Path 1F  | `03H` | `3DH` |
| Ice Path B1F | `03H` | `3EH` |
| Ice Path B2F (Mahogany side) | `03H` | `3FH` |
| Ice Path B2F (Blackthorn side) | `03H` | `40H` |
| Ice Path B3F | `03H` | `41H` |
| Whirl Island NW | `03H` | `42H` |
| Whirl Island NE | `03H` | `43H` |
| Whirl Island SW | `03H` | `44H` |
| Whirl Island Cave | `03H` | `45H` |
| Whirl Island SE | `03H` | `46H` |
| Whirl Island B1F | `03H` | `47H` |
| Whirl Island B2F | `03H` | `48H` |
| Whirl Island — Lugia Chamber | `03H` | `49H` |
| Silver Cave Room 1 | `03H` | `4AH` |
| Silver Cave Room 2 | `03H` | `4BH` |
| Silver Cave Room 3 | `03H` | `4CH` |
| Silver Cave Item Rooms | `03H` | `4DH` |
| Dark Cave (Violet entrance) | `03H` | `4EH` |
| Dark Cave (Blackthorn entrance) | `03H` | `4FH` |
| Dragon's Den 1F | `03H` | `50H` |
| Dragon's Den B1F | `03H` | `51H` |
| Dragon Shrine | `03H` | `52H` |
| Tohjo Falls | `03H` | `53H` |
| Diglett's Cave | `03H` | `54H` |
| Mt. Moon | `03H` | `55H` |
| Underground Path | `03H` | `56H` |
| Rock Tunnel 1F | `03H` | `57H` |
| Rock Tunnel B1F | `03H` | `58H` |
| Safari Zone Fuchsia Gate (Beta) | `03H` | `59H` |
| Safari Zone (Beta) | `03H` | `5AH` |
| Victory Road | `03H` | `5BH` |

### Group 04H — Ecruteak

| Map | GROUP | MAP |
|---|---|---|
| Tin Tower Entrance | `04H` | `01H` |
| Wise Trio's Room | `04H` | `02H` |
| Ecruteak Pokécenter 1F | `04H` | `03H` |
| Lugia Speech House | `04H` | `04H` |
| Dance Theater | `04H` | `05H` |
| Ecruteak Mart | `04H` | `06H` |
| Ecruteak Gym | `04H` | `07H` |
| Itemfinder House | `04H` | `08H` |
| Ecruteak City | `04H` | `09H` |

### Group 05H — Blackthorn

| Map | GROUP | MAP |
|---|---|---|
| Blackthorn Gym 1F | `05H` | `01H` |
| Blackthorn Gym 2F | `05H` | `02H` |
| Dragon Speech House | `05H` | `03H` |
| Emmy's House | `05H` | `04H` |
| Blackthorn Mart | `05H` | `05H` |
| Blackthorn Pokécenter 1F | `05H` | `06H` |
| Move Deleter's House | `05H` | `07H` |
| Route 45 | `05H` | `08H` |
| Route 46 | `05H` | `09H` |
| Blackthorn City | `05H` | `0AH` |

### Group 06H — Cinnabar

| Map | GROUP | MAP |
|---|---|---|
| Cinnabar Pokécenter 1F | `06H` | `01H` |
| Cinnabar Pokécenter 2F (Beta) | `06H` | `02H` |
| Route 19 Fuchsia Gate | `06H` | `03H` |
| Seafoam Gym | `06H` | `04H` |
| Route 19 | `06H` | `05H` |
| Route 20 | `06H` | `06H` |
| Route 21 | `06H` | `07H` |
| Cinnabar Island | `06H` | `08H` |

### Group 07H — Cerulean

| Map | GROUP | MAP |
|---|---|---|
| Gym Badge Speech House | `07H` | `01H` |
| Cerulean Police Station | `07H` | `02H` |
| Trade Speech House | `07H` | `03H` |
| Cerulean Pokécenter 1F | `07H` | `04H` |
| Cerulean Pokécenter 2F (Beta) | `07H` | `05H` |
| Cerulean Gym | `07H` | `06H` |
| Cerulean Mart | `07H` | `07H` |
| Route 10 Pokécenter 1F | `07H` | `08H` |
| Route 10 Pokécenter 2F (Beta) | `07H` | `09H` |
| Power Plant | `07H` | `0AH` |
| Bill's House | `07H` | `0BH` |
| Route 4 | `07H` | `0CH` |
| Route 9 | `07H` | `0DH` |
| Route 10 North | `07H` | `0EH` |
| Route 24 | `07H` | `0FH` |
| Route 25 | `07H` | `10H` |
| Cerulean City | `07H` | `11H` |

### Group 08H — Azalea

| Map | GROUP | MAP |
|---|---|---|
| Azalea Pokécenter 1F | `08H` | `01H` |
| Charcoal Kiln | `08H` | `02H` |
| Azalea Mart | `08H` | `03H` |
| Kurt's House | `08H` | `04H` |
| Azalea Gym | `08H` | `05H` |
| Route 33 | `08H` | `06H` |
| Azalea Town | `08H` | `07H` |

### Group 09H — Lake of Rage

| Map | GROUP | MAP |
|---|---|---|
| Hidden Power House | `09H` | `01H` |
| Magikarp House | `09H` | `02H` |
| Route 43 Mahogany Gate | `09H` | `03H` |
| Route 43 Gate | `09H` | `04H` |
| Route 43 | `09H` | `05H` |
| Lake of Rage | `09H` | `06H` |

### Group 0AH — Violet

| Map | GROUP | MAP |
|---|---|---|
| Route 32 | `0AH` | `01H` |
| Route 35 | `0AH` | `02H` |
| Route 36 | `0AH` | `03H` |
| Route 37 | `0AH` | `04H` |
| Violet City | `0AH` | `05H` |
| Violet Mart | `0AH` | `06H` |
| Violet Gym | `0AH` | `07H` |
| Earl's Pokémon Academy | `0AH` | `08H` |
| Nickname Speech House | `0AH` | `09H` |
| Violet Pokécenter 1F | `0AH` | `0AH` |
| Kyle's House | `0AH` | `0BH` |
| Route 32 Ruins of Alph Gate | `0AH` | `0CH` |
| Route 32 Pokécenter 1F | `0AH` | `0DH` |
| Route 35 Goldenrod Gate | `0AH` | `0EH` |
| Route 35 National Park Gate | `0AH` | `0FH` |
| Route 36 Ruins of Alph Gate | `0AH` | `10H` |
| Route 36 National Park Gate | `0AH` | `11H` |

### Group 0BH — Goldenrod

| Map | GROUP | MAP |
|---|---|---|
| Route 34 | `0BH` | `01H` |
| Goldenrod City | `0BH` | `02H` |
| Goldenrod Gym | `0BH` | `03H` |
| Bike Shop | `0BH` | `04H` |
| Happiness Rater | `0BH` | `05H` |
| Bill's Family's House | `0BH` | `06H` |
| Goldenrod Magnet Train Station | `0BH` | `07H` |
| Flower Shop | `0BH` | `08H` |
| PP Speech House | `0BH` | `09H` |
| Name Rater | `0BH` | `0AH` |
| Goldenrod Dept. Store 1F | `0BH` | `0BH` |
| Goldenrod Dept. Store 2F | `0BH` | `0CH` |
| Goldenrod Dept. Store 3F | `0BH` | `0DH` |
| Goldenrod Dept. Store 4F | `0BH` | `0EH` |
| Goldenrod Dept. Store 5F | `0BH` | `0FH` |
| Goldenrod Dept. Store 6F | `0BH` | `10H` |
| Goldenrod Dept. Store Elevator | `0BH` | `11H` |
| Goldenrod Dept. Store Roof | `0BH` | `12H` |
| Game Corner | `0BH` | `13H` |
| Goldenrod Pokécenter 1F | `0BH` | `14H` |
| Pokécom Center Admin Office (Mobile) | `0BH` | `15H` |
| Ilex Forest Azalea Gate | `0BH` | `16H` |
| Route 34 Ilex Forest Gate | `0BH` | `17H` |
| Day Care | `0BH` | `18H` |

### Group 0CH — Vermilion

| Map | GROUP | MAP |
|---|---|---|
| Route 6 | `0CH` | `01H` |
| Route 11 | `0CH` | `02H` |
| Vermilion City | `0CH` | `03H` |
| Fishing Speech House | `0CH` | `04H` |
| Vermilion Pokécenter 1F | `0CH` | `05H` |
| Vermilion Pokécenter 2F (Beta) | `0CH` | `06H` |
| Pokémon Fan Club | `0CH` | `07H` |
| Magnet Train Speech House | `0CH` | `08H` |
| Vermilion Mart | `0CH` | `09H` |
| Diglett's Cave Speech House | `0CH` | `0AH` |
| Vermilion Gym | `0CH` | `0BH` |
| Route 6 Saffron Gate | `0CH` | `0CH` |
| Route 6 Underground Path Entrance | `0CH` | `0DH` |

### Group 0DH — Pallet

| Map | GROUP | MAP |
|---|---|---|
| Route 1 | `0DH` | `01H` |
| Pallet Town | `0DH` | `02H` |
| Red's House 1F | `0DH` | `03H` |
| Red's House 2F | `0DH` | `04H` |
| Blue's House | `0DH` | `05H` |
| Oak's Lab | `0DH` | `06H` |

### Group 0EH — Pewter

| Map | GROUP | MAP |
|---|---|---|
| Route 3 | `0EH` | `01H` |
| Pewter City | `0EH` | `02H` |
| Nidoran Speech House | `0EH` | `03H` |
| Pewter Gym | `0EH` | `04H` |
| Pewter Mart | `0EH` | `05H` |
| Pewter Pokécenter 1F | `0EH` | `06H` |
| Pewter Pokécenter 2F (Beta) | `0EH` | `07H` |
| Snooze Speech House | `0EH` | `08H` |

### Group 0FH — S.S. Aqua / Fast Ship

| Map | GROUP | MAP |
|---|---|---|
| Olivine Port | `0FH` | `01H` |
| Vermilion Port | `0FH` | `02H` |
| S.S. Aqua 1F | `0FH` | `03H` |
| Cabins NNW/NNE/NE | `0FH` | `04H` |
| Cabins SW/SSW/NW | `0FH` | `05H` |
| Cabins SE/SSE/Captain's Cabin | `0FH` | `06H` |
| S.S. Aqua B1F | `0FH` | `07H` |
| Olivine Port Passage | `0FH` | `08H` |
| Vermilion Port Passage | `0FH` | `09H` |
| Mt. Moon Square | `0FH` | `0AH` |
| Mt. Moon Gift Shop | `0FH` | `0BH` |
| Tin Tower Roof | `0FH` | `0CH` |

### Group 10H — Indigo Plateau

| Map | GROUP | MAP |
|---|---|---|
| Route 23 | `10H` | `01H` |
| Indigo Plateau Pokécenter 1F | `10H` | `02H` |
| Will's Room | `10H` | `03H` |
| Koga's Room | `10H` | `04H` |
| Bruno's Room | `10H` | `05H` |
| Karen's Room | `10H` | `06H` |
| Lance's Room | `10H` | `07H` |
| Hall of Fame | `10H` | `08H` |

### Group 11H — Fuchsia

| Map | GROUP | MAP |
|---|---|---|
| Route 13 | `11H` | `01H` |
| Route 14 | `11H` | `02H` |
| Route 15 | `11H` | `03H` |
| Route 18 | `11H` | `04H` |
| Fuchsia City | `11H` | `05H` |
| Fuchsia Mart | `11H` | `06H` |
| Safari Zone Main Office | `11H` | `07H` |
| Fuchsia Gym | `11H` | `08H` |
| Bill's Older Sister's House | `11H` | `09H` |
| Fuchsia Pokécenter 1F | `11H` | `0AH` |
| Fuchsia Pokécenter 2F (Beta) | `11H` | `0BH` |
| Safari Zone Warden's Home | `11H` | `0CH` |
| Route 15 Fuchsia Gate | `11H` | `0DH` |

### Group 12H — Lavender

| Map | GROUP | MAP |
|---|---|---|
| Route 8 | `12H` | `01H` |
| Route 12 | `12H` | `02H` |
| Route 10 South | `12H` | `03H` |
| Lavender Town | `12H` | `04H` |
| Lavender Pokécenter 1F | `12H` | `05H` |
| Lavender Pokécenter 2F (Beta) | `12H` | `06H` |
| Mr. Fuji's House | `12H` | `07H` |
| Lavender Speech House | `12H` | `08H` |
| Lavender Name Rater | `12H` | `09H` |
| Lavender Mart | `12H` | `0AH` |
| Soul House | `12H` | `0BH` |
| Lavender Radio Tower 1F | `12H` | `0CH` |
| Route 8 Saffron Gate | `12H` | `0DH` |
| Route 12 Super Rod House | `12H` | `0EH` |

### Group 13H — Silver / Mt. Silver

| Map | GROUP | MAP |
|---|---|---|
| Route 28 | `13H` | `01H` |
| Silver Cave Outside | `13H` | `02H` |
| Silver Cave Pokécenter 1F | `13H` | `03H` |
| Route 28 Steel Wing House | `13H` | `04H` |

### Group 14H — Cable Club

| Map | GROUP | MAP |
|---|---|---|
| Pokécenter 2F | `14H` | `01H` |
| Trade Center | `14H` | `02H` |
| Colosseum | `14H` | `03H` |
| Time Capsule | `14H` | `04H` |
| Mobile Trade Room | `14H` | `05H` |
| Mobile Battle Room | `14H` | `06H` |

### Group 15H — Celadon

| Map | GROUP | MAP |
|---|---|---|
| Route 7 | `15H` | `01H` |
| Route 16 | `15H` | `02H` |
| Route 17 | `15H` | `03H` |
| Celadon City | `15H` | `04H` |
| Celadon Dept. Store 1F | `15H` | `05H` |
| Celadon Dept. Store 2F | `15H` | `06H` |
| Celadon Dept. Store 3F | `15H` | `07H` |
| Celadon Dept. Store 4F | `15H` | `08H` |
| Celadon Dept. Store 5F | `15H` | `09H` |
| Celadon Dept. Store 6F | `15H` | `0AH` |
| Celadon Dept. Store Elevator | `15H` | `0BH` |
| Celadon Mansion 1F | `15H` | `0CH` |
| Celadon Mansion 2F | `15H` | `0DH` |
| Celadon Mansion 3F | `15H` | `0EH` |
| Celadon Mansion Roof | `15H` | `0FH` |
| Celadon Mansion Roof House | `15H` | `10H` |
| Celadon Pokécenter 1F | `15H` | `11H` |
| Celadon Pokécenter 2F (Beta) | `15H` | `12H` |
| Celadon Game Corner | `15H` | `13H` |
| Celadon Game Corner Prize Room | `15H` | `14H` |
| Celadon Gym | `15H` | `15H` |
| Celadon Café | `15H` | `16H` |
| Route 16 Fuchsia Speech House | `15H` | `17H` |
| Route 16 Gate | `15H` | `18H` |
| Route 7 Saffron Gate | `15H` | `19H` |
| Route 17/18 Gate | `15H` | `1AH` |

### Group 16H — Cianwood

| Map | GROUP | MAP |
|---|---|---|
| Route 40 | `16H` | `01H` |
| Route 41 | `16H` | `02H` |
| Cianwood City | `16H` | `03H` |
| Mania's House | `16H` | `04H` |
| Cianwood Gym | `16H` | `05H` |
| Cianwood Pokécenter 1F | `16H` | `06H` |
| Cianwood Pharmacy | `16H` | `07H` |
| Cianwood Photo Studio | `16H` | `08H` |
| Lugia Speech House | `16H` | `09H` |
| Poké Seer's House | `16H` | `0AH` |
| Battle Tower 1F | `16H` | `0BH` |
| Battle Tower Battle Room | `16H` | `0CH` |
| Battle Tower Elevator | `16H` | `0DH` |
| Battle Tower Hallway | `16H` | `0EH` |
| Route 40 Battle Tower Gate | `16H` | `0FH` |
| Battle Tower Outside | `16H` | `10H` |

### Group 17H — Viridian

| Map | GROUP | MAP |
|---|---|---|
| Route 2 | `17H` | `01H` |
| Route 22 | `17H` | `02H` |
| Viridian City | `17H` | `03H` |
| Viridian Gym | `17H` | `04H` |
| Nickname Speech House | `17H` | `05H` |
| Trainer House 1F | `17H` | `06H` |
| Trainer House B1F | `17H` | `07H` |
| Viridian Mart | `17H` | `08H` |
| Viridian Pokécenter 1F | `17H` | `09H` |
| Viridian Pokécenter 2F (Beta) | `17H` | `0AH` |
| Route 2 Nugget House | `17H` | `0BH` |
| Route 2 Gate | `17H` | `0CH` |
| Victory Road Gate | `17H` | `0DH` |

### Group 18H — New Bark

| Map | GROUP | MAP |
|---|---|---|
| Route 26 | `18H` | `01H` |
| Route 27 | `18H` | `02H` |
| Route 29 | `18H` | `03H` |
| New Bark Town | `18H` | `04H` |
| Elm's Lab | `18H` | `05H` |
| Player's House 1F | `18H` | `06H` |
| Player's House 2F | `18H` | `07H` |
| Player's Neighbor's House | `18H` | `08H` |
| Elm's House | `18H` | `09H` |
| Route 26 Heal House | `18H` | `0AH` |
| Day-of-Week Siblings' House | `18H` | `0BH` |
| Route 27 Sandstorm House | `18H` | `0CH` |
| Route 29/46 Gate | `18H` | `0DH` |

### Group 19H — Saffron

| Map | GROUP | MAP |
|---|---|---|
| Route 5 | `19H` | `01H` |
| Saffron City | `19H` | `02H` |
| Fighting Dojo | `19H` | `03H` |
| Saffron Gym | `19H` | `04H` |
| Saffron Mart | `19H` | `05H` |
| Saffron Pokécenter 1F | `19H` | `06H` |
| Saffron Pokécenter 2F (Beta) | `19H` | `07H` |
| Mr. Psychic's House | `19H` | `08H` |
| Saffron Magnet Train Station | `19H` | `09H` |
| Silph Co. 1F | `19H` | `0AH` |
| Copycat's House 1F | `19H` | `0BH` |
| Copycat's House 2F | `19H` | `0CH` |
| Route 5 Underground Path Entrance | `19H` | `0DH` |
| Route 5 Saffron Gate | `19H` | `0EH` |
| Route 5 Cleanse Tag House | `19H` | `0FH` |

### Group 1AH — Cherrygrove

| Map | GROUP | MAP |
|---|---|---|
| Route 30 | `1AH` | `01H` |
| Route 31 | `1AH` | `02H` |
| Cherrygrove City | `1AH` | `03H` |
| Cherrygrove Mart | `1AH` | `04H` |
| Cherrygrove Pokécenter 1F | `1AH` | `05H` |
| Gym Speech House | `1AH` | `06H` |
| Guide Gent's House | `1AH` | `07H` |
| Evolution Speech House | `1AH` | `08H` |
| Route 30 Berry House | `1AH` | `09H` |
| Mr. Pokémon's House | `1AH` | `0AH` |
| Route 31 Violet Gate | `1AH` | `0BH` |
