; See data\items\randomizable_items.asm for the list of items.
DEF NUM_RANDOMIZABLE_ITEMS EQU 160

; Bit index constants for wRandoFlags (see ram/wram.asm)
; These are plain bit indices (0-7) for use with the BIT/SET/RES instructions
; and with `xor 1 << RANDFLAG_*_F` for toggling.
DEF RANDFLAG_WILD_ENCOUNTERS_F EQU 0 ; set = randomized wild encounters
DEF RANDFLAG_STARTER_RAND_F    EQU 1 ; set = randomized starters
DEF RANDFLAG_TRAINER_RAND_F    EQU 3 ; set = randomized trainer parties
DEF RANDFLAG_BERRY_RAND_F      EQU 6 ; set = randomized berry trees
DEF RANDFLAG_ITEM_RAND_F       EQU 7 ; set = randomized item balls

; Gift Pokémon randomizer mode (stored in wGiftRandMode, see ram/wram.asm)
DEF GIFT_RAND_STANDARD   EQU 0 ; standard species, normal gift behaviour
DEF GIFT_RAND_RANDOMIZED EQU 1 ; random species substituted for the gift
DEF GIFT_RAND_DISABLED   EQU 2 ; gift Pokémon are not given at all
DEF NUM_GIFT_RAND_MODES  EQU 3

; Return codes for GiveXxxGift specials (wScriptVar)
DEF GIFT_RESULT_DISABLED EQU 0 ; gift is disabled — nothing given
DEF GIFT_RESULT_PARTY    EQU 1 ; Pokémon (or egg) added to the party
DEF GIFT_RESULT_BOX      EQU 2 ; Pokémon sent to PC box
DEF GIFT_RESULT_FULL     EQU 3 ; party and box both full — nothing given

; Bit index constants for wModFlags (see ram/wram.asm)
; Modernization / quality-of-life options — not randomization.
DEF MODFLAG_TM_UNLIMITED_F    EQU 0 ; set = TMs are unlimited use
DEF MODFLAG_POISON_SURVIVAL_F EQU 1 ; set = poison stops at 1 HP
DEF MODFLAG_AUTO_NICKNAME_F   EQU 2 ; set = random nicknames on catch/hatch
