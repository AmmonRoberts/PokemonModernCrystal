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

; Bit index constants for wModFlags (see ram/wram.asm)
; Modernization / quality-of-life options — not randomization.
DEF MODFLAG_TM_UNLIMITED_F    EQU 0 ; set = TMs are unlimited use
DEF MODFLAG_POISON_SURVIVAL_F EQU 1 ; set = poison stops at 1 HP
DEF MODFLAG_AUTO_NICKNAME_F   EQU 2 ; set = random nicknames on catch/hatch
