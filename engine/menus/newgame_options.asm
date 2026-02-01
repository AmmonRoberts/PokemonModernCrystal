; NewGameOptions menu constants
; Page 1: Randomizer options
	const_def
	const NEWGAMEOPT_WILD_ENCOUNTERS  ; 0
	const NEWGAMEOPT_STARTER_RAND     ; 1
	const NEWGAMEOPT_TRAINER_RAND     ; 2
	const NEWGAMEOPT_BERRY_RAND       ; 3
	const NEWGAMEOPT_ITEM_RAND        ; 4
	const NEWGAMEOPT_PAGE1_CONTINUE   ; 5
DEF NUM_NEWGAMEOPTIONS_PAGE1 EQU const_value ; 6

; Page 2: Other options
	const_def
	const NEWGAMEOPT_AUTO_NICKNAME    ; 0
	const NEWGAMEOPT_TM_MODE          ; 1
	const NEWGAMEOPT_POISON_SURVIVAL  ; 2
	const NEWGAMEOPT_PAGE2_CONTINUE   ; 3
DEF NUM_NEWGAMEOPTIONS_PAGE2 EQU const_value ; 4

DEF NUM_NEWGAMEOPTIONS EQU NUM_NEWGAMEOPTIONS_PAGE1 ; For compatibility

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
	jr nz, .page2
	ld de, StringNewGameOptionsPage1
	jr .display_page
.page2
	ld de, StringNewGameOptionsPage2
.display_page
	call PlaceString
	xor a
	ld [wJumptableIndex], a

; Display the settings of each option when the menu is opened
	ld a, [wNewGameOptionsPage]
	and a
	jr nz, .page2_count
	ld c, NUM_NEWGAMEOPTIONS_PAGE1 - 1 ; omit continue button
	jr .print_text_loop
.page2_count
	ld c, NUM_NEWGAMEOPTIONS_PAGE2 - 1 ; omit continue button
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
	and a
	jr z, .go_to_page2
	; On page 2, start the game
	jr .ExitOptions

.go_to_page2
	ld a, 1
	ld [wNewGameOptionsPage], a
	jp .refresh_page

.handle_b
	; B button behavior
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .CancelNewGame ; Page 1: cancel new game
	; Page 2: go back to page 1
	xor a
	ld [wNewGameOptionsPage], a
	jp .refresh_page

.handle_continue_button
	; Continue button pressed
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .go_to_page2 ; Page 1: go to page 2
	; Page 2: start the game
	jr .ExitOptions

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
	db "RANDOMIZERS   1/2<LF>"
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
	db "CONTINUE@"

StringNewGameOptionsPage2:
	db "OTHER OPTIONS 2/2<LF>"
	db "NICKNAMES<LF>"
	db "     :<LF>"
	db "TM MODE<LF>"
	db "     :<LF>"
	db "WALKING POISON<LF>"
	db "     :<LF>"
	db "CONTINUE@"

GetNewGameOptionPointer:
	ld a, [wNewGameOptionsPage]
	and a
	jr nz, .page2
	jumptable .PointersPage1, wJumptableIndex
.page2
	jumptable .PointersPage2, wJumptableIndex

.PointersPage1:
; entries correspond to NEWGAMEOPT_* constants (Page 1)
	dw NewGameOptions_WildEncounters
	dw NewGameOptions_StarterRandomization
	dw NewGameOptions_TrainerRandomization
	dw NewGameOptions_BerryRandomization
	dw NewGameOptions_ItemRandomization
	dw NewGameOptions_Continue

.PointersPage2:
; entries correspond to NEWGAMEOPT_* constants (Page 2)
	dw NewGameOptions_AutoNickname
	dw NewGameOptions_TMMode
	dw NewGameOptions_PoisonSurvival
	dw NewGameOptions_Continue
NewGameOptions_BerryRandomization:
	ld a, [wBerryTreeRandomizer]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wBerryTreeRandomizer]
	xor 1
	ld [wBerryTreeRandomizer], a
.NonePressed:
	ld a, [wBerryTreeRandomizer]
	and a
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
	ld a, [wItemRandomizer]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wItemRandomizer]
	xor 1
	ld [wItemRandomizer], a
.NonePressed:
	ld a, [wItemRandomizer]
	and a
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

NewGameOptions_WildEncounters:
	ld a, [wWildEncounterType]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wWildEncounterType]
	xor 1 ; Toggle between 0 and 1
	ld [wWildEncounterType], a
.NonePressed:
	ld a, [wWildEncounterType]
	and a
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
	ld a, [wStarterRandomization]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wStarterRandomization]
	xor 1
	ld [wStarterRandomization], a
.NonePressed:
	ld a, [wStarterRandomization]
	and a
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
	ld a, [wTrainerRandomization]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wTrainerRandomization]
	xor 1
	ld [wTrainerRandomization], a
.NonePressed:
	ld a, [wTrainerRandomization]
	and a
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
	ld a, [wTMMode]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wTMMode]
	xor 1
	ld [wTMMode], a
.NonePressed:
	ld a, [wTMMode]
	and a
	jr nz, .Unlimited
	ld de, .Standard
	jr .Display
.Unlimited:
	ld de, .Unlimited_str
.Display:
	hlcoord 8, 6
	call PlaceString
	and a
	ret

.Standard:     db "STANDARD @"
.Unlimited_str: db "UNLIMITED@"

NewGameOptions_PoisonSurvival:
	ld a, [wPoisonSurvival]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wPoisonSurvival]
	xor 1
	ld [wPoisonSurvival], a
.NonePressed:
	ld a, [wPoisonSurvival]
	and a
	jr nz, .Safe
	ld de, .Standard
	jr .Display
.Safe:
	ld de, .Safe_str
.Display:
	hlcoord 8, 8
	call PlaceString
	and a
	ret

.Standard: db "STANDARD@"
.Safe_str: db "SAFE    @"

NewGameOptions_AutoNickname:
	ld a, [wAutoNickname]
	ldh a, [hJoyPressed]
	bit B_PAD_LEFT, a
	jr nz, .Toggle
	bit B_PAD_RIGHT, a
	jr z, .NonePressed
.Toggle:
	ld a, [wAutoNickname]
	xor 1
	ld [wAutoNickname], a
.NonePressed:
	ld a, [wAutoNickname]
	and a
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

.Off:    db "STANDARD  @"
.On_str: db "RANDOMIZED@"

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
	jr nz, .page2_down
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
	jr nz, .page2_bottom
	; Page 1
	ld [hl], NEWGAMEOPT_PAGE1_CONTINUE
	scf
	ret
.page2_bottom
	; Page 2
	ld [hl], NEWGAMEOPT_PAGE2_CONTINUE
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
	
	; Place cursor at current position (starting at row 3 for first option)
	hlcoord 1, 3
	ld bc, SCREEN_WIDTH * 2
	ld a, [wJumptableIndex]
	call AddNTimes
	ld [hl], $ed ; filled right arrow
	ret
