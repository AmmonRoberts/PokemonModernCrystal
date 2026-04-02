; NewGameOptions menu constants
; Page 1: Core Randomizer options
	const_def
	const NEWGAMEOPT_WILD_ENCOUNTERS  ; 0
	const NEWGAMEOPT_STARTER_RAND     ; 1
	const NEWGAMEOPT_TRAINER_RAND     ; 2
	const NEWGAMEOPT_BERRY_RAND       ; 3
	const NEWGAMEOPT_ITEM_RAND        ; 4
	const NEWGAMEOPT_GIFT_RAND        ; 5
	const NEWGAMEOPT_PAGE1_CONTINUE   ; 6
DEF NUM_NEWGAMEOPTIONS_PAGE1 EQU const_value ; 7

; Page 2: More Randomizer options (overflow / future randomizers)
	const_def
	const NEWGAMEOPT_TYPE_RAND        ; 0
	const NEWGAMEOPT_AUTO_NICKNAME    ; 1
	const NEWGAMEOPT_PAGE2_CONTINUE   ; 2
DEF NUM_NEWGAMEOPTIONS_PAGE2 EQU const_value ; 3

; Page 3: Modernization options
	const_def
	const NEWGAMEOPT_TM_MODE          ; 0
	const NEWGAMEOPT_EXP_MULTIPLIER   ; 1
	const NEWGAMEOPT_RARE_CANDY_MART  ; 2
	const NEWGAMEOPT_POISON_SURVIVAL  ; 3
	const NEWGAMEOPT_PAGE3_CONTINUE   ; 4
DEF NUM_NEWGAMEOPTIONS_PAGE3 EQU const_value ; 5

; Page 4: Nuzlocke/Challenge options
	const_def
	const NEWGAMEOPT_PERMADEATH       ; 0
	const NEWGAMEOPT_RESET_ON_WIPE    ; 1
	const NEWGAMEOPT_PARTY_LIMIT      ; 2
	const NEWGAMEOPT_FIRST_ENCOUNTER  ; 3
	const NEWGAMEOPT_PAGE4_CONTINUE   ; 4
DEF NUM_NEWGAMEOPTIONS_PAGE4 EQU const_value ; 5

DEF NUM_NEWGAMEOPTIONS EQU NUM_NEWGAMEOPTIONS_PAGE1 ; For compatibility

; Rare Candy mart modes (stored in wRareCandyMart)
	; 0 = disabled, 1 = cheap, 2 = pricey, 3 = free
DEF RARE_CANDY_MART_DISABLED EQU 0
DEF RARE_CANDY_MART_CHEAP    EQU 1
DEF RARE_CANDY_MART_PRICEY   EQU 2
DEF RARE_CANDY_MART_FREE     EQU 3
DEF NUM_RARE_CANDY_MART_MODES EQU 4
DEF RARE_CANDY_CHEAP_PRICE   EQU 500

_NewGameOptions:
	; Initialize Crystal data (including all new game options to defaults)
	call InitCrystalData
	
	; Set up the screen
	call InitGenderScreen
	call LoadGenderScreenPal
	call LoadGenderScreenLightBlueTile
	call WaitBGMap2
	call SetDefaultBGPAndOBP
	
	ld hl, hInMenu
	ld a, [hl]
	push af
	ld [hl], TRUE
	
	; Start on page 1
	xor a
	ld [wNewGameOptionsPage], a
	
.refresh_page
	hlcoord 0, 0
	ld b, SCREEN_HEIGHT - 2
	ld c, SCREEN_WIDTH - 2
	call Textbox
	hlcoord 2, 2
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .page1_str
	cp 1
	jr z, .page2_str
	cp 2
	jr z, .page3_str
	ld de, StringNewGameOptionsPage4
	jr .display_page
.page1_str
	ld de, StringNewGameOptionsPage1
	jr .display_page
.page2_str
	ld de, StringNewGameOptionsPage2
	jr .display_page
.page3_str
	ld de, StringNewGameOptionsPage3
.display_page
	call PlaceString
	xor a
	ld [wJumptableIndex], a

; Display the settings of each option when the menu is opened
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .page1_count
	cp 1
	jr z, .page2_count
	cp 2
	jr z, .page3_count
	ld c, NUM_NEWGAMEOPTIONS_PAGE4 - 1
	jr .print_text_loop
.page1_count
	ld c, NUM_NEWGAMEOPTIONS_PAGE1 - 1 ; omit continue button
	jr .print_text_loop
.page2_count
	ld c, NUM_NEWGAMEOPTIONS_PAGE2 - 1
	jr .print_text_loop
.page3_count
	ld c, NUM_NEWGAMEOPTIONS_PAGE3 - 1
.print_text_loop
	push bc
	xor a
	ldh [hJoyLast], a
	call GetNewGameOptionPointer
	pop bc
	ld hl, wJumptableIndex
	inc [hl]
	dec c
	jr nz, .print_text_loop

	xor a
	ld [wJumptableIndex], a
	inc a
	ldh [hBGMapMode], a
	call WaitBGMap
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call SetDefaultBGPAndOBP

.joypad_loop
	call JoyTextDelay
	ldh a, [hJoyPressed]
	and PAD_START
	jr nz, .handle_start
	ldh a, [hJoyPressed]
	and PAD_B
	jr nz, .handle_b
	call NewGameOptionsControl
	jr c, .dpad
	call GetNewGameOptionPointer
	jr c, .handle_continue_button
	jr .dpad

.handle_start
	; START advances to next page or starts game
	ld a, [wNewGameOptionsPage]
	cp 3
	jr z, .ExitOptions
	inc a
	ld [wNewGameOptionsPage], a
	jp .refresh_page

.handle_b
	; B button behavior
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .CancelNewGame ; Page 1: cancel new game
	dec a
	ld [wNewGameOptionsPage], a
	jp .refresh_page

.handle_continue_button
	; Continue button pressed
	ld a, [wNewGameOptionsPage]
	cp 3
	jr z, .ExitOptions
	inc a
	ld [wNewGameOptionsPage], a
	jp .refresh_page

.dpad
	call NewGameOptions_UpdateCursorPosition
	ld c, 3
	call DelayFrames
	jr .joypad_loop

.ExitOptions:
	ld de, SFX_TRANSACTION
	call PlaySFX
	call WaitSFX
	pop af
	ldh [hInMenu], a
	and a ; clear carry, continue with new game
	ret

.CancelNewGame:
	ld de, SFX_WRONG
	call PlaySFX
	call WaitSFX
	pop af
	ldh [hInMenu], a
	scf ; set carry, cancel new game
	ret

StringNewGameOptionsPage1:
	db "RANDOMIZERS   1/4<LF>"
	db "WILD #MON<LF>"
	db "     :<LF>"
	db "STARTERS<LF>"
	db "     :<LF>"
	db "TRAINERS<LF>"
	db "     :<LF>"
	db "BERRY TREES<LF>"
	db "     :<LF>"
	db "ITEMS<LF>"
	db "     :<LF>"
	db "GIFT #MON<LF>"
	db "     :<LF>"
	db "CONTINUE@"

StringNewGameOptionsPage2:
	db "RANDOMIZERS   2/4<LF>"
	db "TYPES<LF>"
	db "     :<LF>"
	db "NICKNAMES<LF>"
	db "     :<LF>"	
	db "CONTINUE@"

StringNewGameOptionsPage3:
	db "MODERNIZATION 3/4<LF>"
	db "TM MODE<LF>"
	db "     :<LF>"
	db "EXP MULTIPLIER<LF>"
	db "     :<LF>"
	db "BUY RARE CANDY<LF>"
	db "     :<LF>"
	db "POISON FADES<LF>"
	db "     :<LF>"
	db "CONTINUE@"

StringNewGameOptionsPage4:
	db "CHALLENGE     4/4<LF>"
	db "PERMADEATH<LF>"
	db "     :<LF>"
	db "RESET ON WIPE<LF>"
	db "     :<LF>"
	db "PARTY LIMIT<LF>"
	db "     :<LF>"
	db "1ST ENCOUNTER<LF>"
	db "     :<LF>"
	db "CONTINUE@"

GetNewGameOptionPointer:
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .page1
	cp 1
	jr z, .page2
	cp 2
	jr z, .page3
	jumptable .PointersPage4, wJumptableIndex
.page1
	jumptable .PointersPage1, wJumptableIndex
.page2
	jumptable .PointersPage2, wJumptableIndex
.page3
	jumptable .PointersPage3, wJumptableIndex

.PointersPage1:
; entries correspond to NEWGAMEOPT_* constants (Page 1 - Core Randomizers)
	dw NewGameOptions_WildEncounters
	dw NewGameOptions_StarterRandomization
	dw NewGameOptions_TrainerRandomization
	dw NewGameOptions_BerryRandomization
	dw NewGameOptions_ItemRandomization
	dw NewGameOptions_GiftRandomization
	dw NewGameOptions_Continue

.PointersPage2:
; entries correspond to NEWGAMEOPT_* constants (Page 2 - More Randomizers)
	dw NewGameOptions_TypeMatchupRandomization
	dw NewGameOptions_AutoNickname
	dw NewGameOptions_Continue

.PointersPage3:
; entries correspond to NEWGAMEOPT_* constants (Page 3 - Modernization)
	dw NewGameOptions_TMMode
	dw NewGameOptions_ExpMultiplier
	dw NewGameOptions_RareCandyMart
	dw NewGameOptions_PoisonSurvival
	dw NewGameOptions_Continue

.PointersPage4:
; entries correspond to NEWGAMEOPT_* constants (Page 4 - Nuzlocke/Challenge)
	dw NewGameOptions_Permadeath
	dw NewGameOptions_ResetOnWipe
	dw NewGameOptions_PartyLimit
	dw NewGameOptions_FirstEncounter
	dw NewGameOptions_Continue
NewGameOptions_BerryRandomization:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_BERRY_RAND_F
	ld [hl], a
.NonePressed:
	ld a, [wRandoFlags]
	bit RANDFLAG_BERRY_RAND_F, a
	jr nz, .Randomized
	ld de, .Standard
	jr .Display
.Randomized:
	ld de, .Randomized_str
.Display:
	hlcoord 8, 10
	call PlaceString
	and a
	ret
.Standard:     db "STANDARD  @"
.Randomized_str: db "RANDOMIZED@"

NewGameOptions_ItemRandomization:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_ITEM_RAND_F
	ld [hl], a
.NonePressed:
	ld a, [wRandoFlags]
	bit RANDFLAG_ITEM_RAND_F, a
	jr nz, .Randomized
	ld de, .Standard
	jr .Display
.Randomized:
	ld de, .Randomized_str
.Display:
	hlcoord 8, 12
	call PlaceString
	and a
	ret
.Standard:     db "STANDARD  @"
.Randomized_str: db "RANDOMIZED@"

NewGameOptions_TypeMatchupRandomization:
; Cycles: STANDARD -> RANDOMIZED -> BALANCED -> STANDARD (right / left in reverse)
; STANDARD:   bits 4+5 clear   (no randomization)
; RANDOMIZED: bit 4 set only   (fully random matchups)
; BALANCED:   bits 4+5 set     (random, then cap each attacker to at most 2 immunities)
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wRandoFlags]
	bit RANDFLAG_TYPE_RAND_F, a
	jr z, .set_randomized		; STANDARD -> RANDOMIZED
	bit RANDFLAG_TYPE_BALANCED_F, a
	jr z, .set_balanced		; RANDOMIZED -> BALANCED
	jr .set_standard		; BALANCED -> STANDARD
.Left:
	ld a, [wRandoFlags]
	bit RANDFLAG_TYPE_RAND_F, a
	jr z, .set_balanced		; STANDARD -> BALANCED
	bit RANDFLAG_TYPE_BALANCED_F, a
	jr nz, .set_randomized		; BALANCED -> RANDOMIZED
	jr .set_standard		; RANDOMIZED -> STANDARD
.set_standard:
	ld hl, wRandoFlags
	res RANDFLAG_TYPE_BALANCED_F, [hl]
	res RANDFLAG_TYPE_RAND_F, [hl]
	jr .Display
.set_randomized:
	ld hl, wRandoFlags
	res RANDFLAG_TYPE_BALANCED_F, [hl]
	set RANDFLAG_TYPE_RAND_F, [hl]
	jr .Display
.set_balanced:
	ld hl, wRandoFlags
	set RANDFLAG_TYPE_RAND_F, [hl]
	set RANDFLAG_TYPE_BALANCED_F, [hl]
.Display:
	ld a, [wRandoFlags]
	bit RANDFLAG_TYPE_RAND_F, a
	jr z, .show_standard
	bit RANDFLAG_TYPE_BALANCED_F, a
	jr nz, .show_balanced
	ld de, .Randomized_str
	jr .draw
.show_standard:
	ld de, .Standard
	jr .draw
.show_balanced:
	ld de, .Balanced_str
.draw:
	hlcoord 8, 4
	call PlaceString
	and a
	ret
.Standard:       db "STANDARD  @"
.Randomized_str: db "RANDOMIZED@"
.Balanced_str:   db "BALANCED  @"

NewGameOptions_GiftRandomization:
; Cycles: GIFT_RAND_STANDARD (0) → GIFT_RAND_RANDOMIZED (1) → GIFT_RAND_DISABLED (2) → wrap
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wGiftRandMode]
	inc a
	cp NUM_GIFT_RAND_MODES
	jr c, .set
	xor a
	jr .set
.Left:
	ld a, [wGiftRandMode]
	and a
	jr z, .WrapLeft
	dec a
	jr .set
.WrapLeft:
	ld a, NUM_GIFT_RAND_MODES - 1
.set:
	ld [wGiftRandMode], a
.Display:
	ld a, [wGiftRandMode]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 14
	call PlaceString
	and a
	ret
.Strings:
	dw .Standard
	dw .Randomized
	dw .Disabled
.Standard:   db "STANDARD  @"
.Randomized: db "RANDOMIZED@"
.Disabled:   db "DISABLED  @"

NewGameOptions_RareCandyMart:
; Cycles through DISABLED / CHEAP (500) / PRICEY (4800) / FREE (0)
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wRareCandyMart]
	inc a
	cp NUM_RARE_CANDY_MART_MODES
	jr c, .set
	xor a
	jr .set
.Left:
	ld a, [wRareCandyMart]
	and a
	jr z, .WrapLeft
	dec a
	jr .set
.WrapLeft:
	ld a, NUM_RARE_CANDY_MART_MODES - 1
.set:
	ld [wRareCandyMart], a
.Display:
	ld a, [wRareCandyMart]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 8
	call PlaceString
	and a
	ret

.Strings:
	dw .Disabled
	dw .Cheap
	dw .Pricey
	dw .Free

.Disabled: db "DISABLED @"
.Cheap:    db "CHEAP    @"
.Pricey:   db "PRICEY   @"
.Free:     db "FREE     @"

NewGameOptions_WildEncounters:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_WILD_ENCOUNTERS_F
	ld [hl], a
.NonePressed:
	ld a, [wRandoFlags]
	bit RANDFLAG_WILD_ENCOUNTERS_F, a
	jr nz, .Randomized
	ld de, .Standard
	jr .Display
.Randomized:
	ld de, .Randomized_str
.Display:
	hlcoord 8, 4
	call PlaceString
	and a
	ret

.Standard:     db "STANDARD  @"
.Randomized_str: db "RANDOMIZED@"

NewGameOptions_StarterRandomization:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_STARTER_RAND_F
	ld [hl], a
.NonePressed:
	ld a, [wRandoFlags]
	bit RANDFLAG_STARTER_RAND_F, a
	jr nz, .Randomized
	ld de, .Standard
	jr .Display
.Randomized:
	ld de, .Randomized_str
.Display:
	hlcoord 8, 6
	call PlaceString
	and a
	ret

.Standard:     db "STANDARD  @"
.Randomized_str: db "RANDOMIZED@"

NewGameOptions_TrainerRandomization:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_TRAINER_RAND_F
	ld [hl], a
.NonePressed:
	ld a, [wRandoFlags]
	bit RANDFLAG_TRAINER_RAND_F, a
	jr nz, .Randomized
	ld de, .Standard
	jr .Display
.Randomized:
	ld de, .Randomized_str
.Display:
	hlcoord 8, 8
	call PlaceString
	and a
	ret

.Standard:     db "STANDARD  @"
.Randomized_str: db "RANDOMIZED@"

NewGameOptions_TMMode:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_TM_UNLIMITED_F
	ld [hl], a
.NonePressed:
	ld a, [wModFlags]
	bit MODFLAG_TM_UNLIMITED_F, a
	jr nz, .Unlimited
	ld de, .Standard
	jr .Display
.Unlimited:
	ld de, .Unlimited_str
.Display:
	hlcoord 8, 4
	call PlaceString
	and a
	ret

.Standard:     db "STANDARD @"
.Unlimited_str: db "UNLIMITED@"

NewGameOptions_PoisonSurvival:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_POISON_SURVIVAL_F
	ld [hl], a
.NonePressed:
	ld a, [wModFlags]
	bit MODFLAG_POISON_SURVIVAL_F, a
	jr nz, .Safe
	ld de, .Standard
	jr .Display
.Safe:
	ld de, .Safe_str
.Display:
	hlcoord 8, 10
	call PlaceString
	and a
	ret

.Standard: db "STANDARD@"
.Safe_str: db "SAFE    @"

NewGameOptions_AutoNickname:
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_AUTO_NICKNAME_F
	ld [hl], a
.NonePressed:
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	jr nz, .On
	ld de, .Off
	jr .Display
.On:
	ld de, .On_str
.Display:
	hlcoord 8, 6
	call PlaceString
	and a
	ret

.Off:    db "STANDARD  @"
.On_str: db "RANDOMIZED@"

NewGameOptions_ExpMultiplier:
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wExpMultiplier]
	cp 4
	jr z, .WrapToMin
	inc a
	ld [wExpMultiplier], a
	jr .Display
.WrapToMin:
	xor a
	ld [wExpMultiplier], a
	jr .Display
.Left:
	ld a, [wExpMultiplier]
	and a
	jr z, .WrapToMax
	dec a
	ld [wExpMultiplier], a
	jr .Display
.WrapToMax:
	ld a, 4
	ld [wExpMultiplier], a
.Display:
	ld a, [wExpMultiplier]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 6
	call PlaceString
	and a
	ret

.Strings:
	dw .str_050
	dw .str_075
	dw .str_100
	dw .str_125
	dw .str_150

.str_050: db "x0.50@"
.str_075: db "x0.75@"
.str_100: db "x1.00@"
.str_125: db "x1.25@"
.str_150: db "x1.50@"

NewGameOptions_Permadeath:
	ld a, [wPermafaint]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wPermafaint]
	xor 1     ; toggle bit 0 (permadeath)
	ld [wPermafaint], a
.NonePressed:
	ld a, [wPermafaint]
	bit 0, a
	jr nz, .On
	ld de, .Off
	jr .Display
.On:
	ld de, .On_str
.Display:
	hlcoord 8, 4
	call PlaceString
	and a
	ret
.Off:    db "OFF     @"
.On_str: db "ON      @"

NewGameOptions_ResetOnWipe:
	ld a, [wPermafaint]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wPermafaint]
	xor 2     ; toggle bit 1 (reset-on-wipe)
	ld [wPermafaint], a
.NonePressed:
	ld a, [wPermafaint]
	bit 1, a
	jr nz, .On
	ld de, .Off
	jr .Display
.On:
	ld de, .On_str
.Display:
	hlcoord 8, 6
	call PlaceString
	and a
	ret
.Off:    db "OFF     @"
.On_str: db "ON      @"

NewGameOptions_PartyLimit:
; Cycles through 1-6 (PARTY_LENGTH); default is PARTY_LENGTH
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wPartyLimit]
	cp PARTY_LENGTH
	jr z, .Display  ; already at max
	inc a
	ld [wPartyLimit], a
	jr .Display
.Left:
	ld a, [wPartyLimit]
	cp 1
	jr z, .Display  ; already at min
	dec a
	ld [wPartyLimit], a
.Display:
	ld a, [wPartyLimit]
	dec a           ; convert 1-6 to 0-5 for table index
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 8, 8
	call PlaceString
	and a
	ret

.Strings:
	dw .str1
	dw .str2
	dw .str3
	dw .str4
	dw .str5
	dw .str6

.str1: db "1       @"
.str2: db "2       @"
.str3: db "3       @"
.str4: db "4       @"
.str5: db "5       @"
.str6: db "6       @"

NewGameOptions_FirstEncounter:
; Cycles DISABLED -> FORGIVING -> STRICT -> DISABLED (right / left in reverse)
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Right
	bit B_PAD_LEFT, a
	jr nz, .Left
	jr .Display
.Right:
	ld a, [wNuzlockeMode]
	inc a
	cp NUM_NUZLOCKE_MODES
	jr c, .set_mode
	xor a ; wrap to DISABLED
.set_mode:
	ld [wNuzlockeMode], a
	jr .Display
.Left:
	ld a, [wNuzlockeMode]
	and a
	jr z, .set_strict ; wrap to STRICT
	dec a
	jr .set_mode
.set_strict:
	ld a, NUZLOCKE_STRICT
	jr .set_mode
.Display:
	ld a, [wNuzlockeMode]
	cp NUZLOCKE_FORGIVING
	jr z, .show_forgiving
	cp NUZLOCKE_STRICT
	jr z, .show_strict
	ld de, .str_disabled
	jr .draw
.show_forgiving:
	ld de, .str_forgiving
	jr .draw
.show_strict:
	ld de, .str_strict
.draw:
	hlcoord 8, 10
	call PlaceString
	and a
	ret
.str_disabled:  db "DISABLED  @"
.str_forgiving: db "FORGIVING @"
.str_strict:    db "STRICT    @"

NewGameOptions_Continue:
	ldh a, [hJoyPressed]
	and PAD_A
	jr nz, .pressed
	and a
	ret

.pressed:
	scf
	ret

NewGameOptionsControl:
	ld hl, wJumptableIndex
	ldh a, [hJoyLast]
	cp PAD_DOWN
	jr z, .DownPressed
	cp PAD_UP
	jr z, .UpPressed
	and a
	ret

.DownPressed:
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .page1_down
	cp 1
	jr z, .page2_down
	cp 2
	jr z, .page3_down
	; Page 4
	ld a, [hl]
	cp NEWGAMEOPT_PAGE4_CONTINUE
	jr z, .WrapToTop
	inc [hl]
	scf
	ret
.page1_down
	; Page 1
	ld a, [hl]
	cp NEWGAMEOPT_PAGE1_CONTINUE
	jr z, .WrapToTop
	inc [hl]
	scf
	ret
.page2_down
	; Page 2
	ld a, [hl]
	cp NEWGAMEOPT_PAGE2_CONTINUE
	jr z, .WrapToTop
	inc [hl]
	scf
	ret
.page3_down
	; Page 3
	ld a, [hl]
	cp NEWGAMEOPT_PAGE3_CONTINUE
	jr z, .WrapToTop
	inc [hl]
	scf
	ret

.WrapToTop:
	ld [hl], 0
	scf
	ret

.UpPressed:
	ld a, [hl]
	and a
	jr z, .WrapToBottom
	dec [hl]
	scf
	ret

.WrapToBottom:
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .page1_bottom
	cp 1
	jr z, .page2_bottom
	cp 2
	jr z, .page3_bottom
	; Page 4
	ld [hl], NEWGAMEOPT_PAGE4_CONTINUE
	scf
	ret
.page1_bottom
	; Page 1
	ld [hl], NEWGAMEOPT_PAGE1_CONTINUE
	scf
	ret
.page2_bottom
	; Page 2
	ld [hl], NEWGAMEOPT_PAGE2_CONTINUE
	scf
	ret
.page3_bottom
	; Page 3
	ld [hl], NEWGAMEOPT_PAGE3_CONTINUE
	scf
	ret

NewGameOptions_UpdateCursorPosition:
	; Clear cursor positions at all possible rows
	hlcoord 1, 3
	ld [hl], $7f ; space character
	hlcoord 1, 5
	ld [hl], $7f ; space character
	hlcoord 1, 7
	ld [hl], $7f ; space character
	hlcoord 1, 9
	ld [hl], $7f ; space character
	hlcoord 1, 11
	ld [hl], $7f ; space character
	hlcoord 1, 13
	ld [hl], $7f ; space character
	hlcoord 1, 15
	ld [hl], $7f ; space character
	
	; Place cursor at current position (starting at row 3 for first option)
	hlcoord 1, 3
	ld bc, SCREEN_WIDTH * 2
	ld a, [wJumptableIndex]
	call AddNTimes
	ld [hl], $ed ; filled right arrow
	ret
