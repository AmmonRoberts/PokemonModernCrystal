LearnMove:
	call LoadTilemapToTempTilemap
	call ClearSprites
	call ClearTilemap
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNickname
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	call CopyBytes

.loop
	; Draw the new-move info panel at the top of the screen.
	call DrawNewMoveInfoBox
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wCurPartyMon]
	call AddNTimes
	ld d, h
	ld e, l
	ld b, NUM_MOVES
; Get the first empty move slot.  This routine also serves to
; determine whether the Pokemon learning the moves already has
; all four slots occupied, in which case one would need to be
; deleted.
.next
	ld a, [hl]
	and a
	jr z, .learn
	inc hl
	dec b
	jr nz, .next
; If we're here, we enter the routine for forgetting a move
; to make room for the new move we're trying to learn.
	push de
	call ForgetMove
	pop de
	jp c, .cancel

	push hl
	push de
	ld [wNamedObjectIndex], a

	ld b, a
	ld a, [wBattleMode]
	and a
	jr z, .not_disabled
	ld a, [wDisabledMove]
	cp b
	jr nz, .not_disabled
	xor a
	ld [wDisabledMove], a
	ld [wPlayerDisableCount], a
.not_disabled

	call GetMoveName
	ld hl, Text_1_2_and_Poof ; 1, 2 and…
	call PrintText
	pop de
	pop hl

.learn
	ld a, [wPutativeTMHMMove]
	ld [hl], a
	ld bc, MON_PP - MON_MOVES
	add hl, bc

	push hl
	push de
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop de
	pop hl

	ld [hl], a

	ld a, [wBattleMode]
	and a
	jp z, .learned

	ld a, [wCurPartyMon]
	ld b, a
	ld a, [wCurBattleMon]
	cp b
	jp nz, .learned

	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_TRANSFORMED, a
	jp nz, .learned

	ld h, d
	ld l, e
	ld de, wBattleMonMoves
	ld bc, NUM_MOVES
	call CopyBytes
	ld bc, wPartyMon1PP - (wPartyMon1Moves + NUM_MOVES)
	add hl, bc
	ld de, wBattleMonPP
	ld bc, NUM_MOVES
	call CopyBytes
	jp .learned

.cancel
	ld hl, StopLearningMoveText
	call PrintText
	call YesNoBox
	jp c, .loop

	ld hl, DidNotLearnMoveText
	call PrintText
	call ClearNewMoveInfoBox
	call RestoreBattleScreenAfterLearnMove
	ld b, 0
	ret

.learned
	call DrawNewMoveInfoBox
	ld hl, LearnedMoveText
	call PrintText
	call ClearNewMoveInfoBox
	call RestoreBattleScreenAfterLearnMove
	ld b, 1
	ret

ForgetMove:
	push hl
	ld hl, AskForgetMoveText
	call PrintText
	call YesNoBox
	pop hl
	ret c
	; Clear the new-move panel now that the move-list UI is about to take the screen.
	push hl
	call ClearNewMoveInfoBox
	pop hl
	ld bc, -NUM_MOVES
	add hl, bc
	push hl
	ld de, wListMoves_MoveIndicesBuffer
	ld bc, NUM_MOVES
	call CopyBytes
	pop hl
.loop
	push hl
	ld hl, MoveAskForgetText
	call PrintText
	hlcoord 5, 0
	ld b, NUM_MOVES * 2
	ld c, MOVE_NAME_LENGTH
	call Textbox
	hlcoord 7, 2
	ld a, SCREEN_WIDTH * 2
	ld [wListMovesLineSpacing], a
	predef ListMoves
	; Clear rows 10-11 to remove any leftover tilemap data from the previous screen.
	hlcoord 0, 10
	lb bc, 2, SCREEN_WIDTH
	call ClearBox
	; w2DMenuData
	ld a, $2
	ld [w2DMenuCursorInitY], a
	ld a, $6
	ld [w2DMenuCursorInitX], a
	ld a, [wNumMoves]
	inc a
	ld [w2DMenuNumRows], a
	ld a, $1
	ld [w2DMenuNumCols], a
	ld [wMenuCursorY], a
	ld [wMenuCursorX], a
	ld a, PAD_A | PAD_B | PAD_START
	ld [wMenuJoypadFilter], a
	ld a, $20
	ld [w2DMenuFlags1], a
	xor a
	ld [w2DMenuFlags2], a
	ld a, $20
	ld [w2DMenuCursorOffsets], a
	xor a
	ld [wSwappingMove], a
.joypad_loop
	call StaticMenuJoypad
	bit B_PAD_A, a
	jr nz, .a_pressed
	bit B_PAD_B, a
	jr nz, .b_pressed
	bit B_PAD_START, a
	jr nz, .toggle_info_panel
	bit B_PAD_UP, a
	jr nz, .cursor_moved
	bit B_PAD_DOWN, a
	jr nz, .cursor_moved
	jr .joypad_loop

.a_pressed
	push af
	call SafeLoadTempTilemapToTilemap
	call ClearSprites
	call ClearTilemap
	call DrawNewMoveInfoBox
	pop af
	pop hl
	push hl
	ld a, [wMenuCursorY]
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	push af
	pop de
	pop hl
	add hl, bc
	and a
	ret

.b_pressed
	ld a, [wSwappingMove]
	and a
	jr z, .b_cancel
	xor a
	ld [wSwappingMove], a
	ld a, PAD_A | PAD_B | PAD_START
	ld [wMenuJoypadFilter], a
	call ForgetMove_ClearInfoPanel
	ld hl, MoveAskForgetText
	call PrintText
	jp .joypad_loop

.b_cancel
	push af
	call SafeLoadTempTilemapToTilemap
	pop af
	pop hl

.cancel
	scf
	ret

.toggle_info_panel
	ld a, [wSwappingMove]
	and a
	jr nz, .hide_info_panel
	ld a, 1
	ld [wSwappingMove], a
	ld a, PAD_A | PAD_B | PAD_UP | PAD_DOWN | PAD_START
	ld [wMenuJoypadFilter], a
	call ForgetMove_DrawInfoPanel
	jr .joypad_loop

.hide_info_panel
	xor a
	ld [wSwappingMove], a
	ld a, PAD_A | PAD_B | PAD_START
	ld [wMenuJoypadFilter], a
	call ForgetMove_ClearInfoPanel
	ld hl, MoveAskForgetText
	call PrintText
	jp .joypad_loop

.cursor_moved
	; Erase the stale cursor glyph at its current visual position before
	; re-entering StaticMenuJoypad, which would otherwise leave a ghost.
	ld hl, wCursorCurrentTile
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wCursorOffCharacter]
	ld [hl], a
	call ForgetMove_DrawInfoPanel
	jp .joypad_loop

ForgetMove_DrawInfoPanel:
; Draw the move info panel for the currently-highlighted move in ForgetMove.
; Row 10: folder-tab top  ┌────────┐
; Row 11: │TYPE_NAME└──(main box top continues)────┐
; Row 12: │ACC/ nnn    ATK/ nnn                    │
; Row 13: │description line 1                      │
; Row 15: │description line 2 (via <NEXT>)         │
; Row 17: └────────────────────────────────────────┘
	ld a, [wMenuCursorY]
	dec a
	ld hl, wListMoves_MoveIndicesBuffer
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	and a
	ret z
	ld [wCurSpecies], a
	xor a
	ldh [hBGMapMode], a
	; Main panel box rows 11-17.
	hlcoord 0, 11
	ld b, 5
	ld c, 18
	call Textbox
	; Folder-tab top at row 10 (cols 0-9, width fits longest type "ELECTRIC").
	hlcoord 0, 10
	ld de, .TypeTabTop
	call PlaceString
	; Replace the ┌ at col 0 row 11 (drawn by Textbox) with │ (left wall of tab).
	hlcoord 0, 11
	ld [hl], '│'
	; Clear cols 1-8 of row 11 so leftover ─ border chars don't show after the type name.
	hlcoord 1, 11
	lb bc, 1, 8
	call ClearBox
	; Place the type name at col 1 row 11.
	hlcoord 1, 11
	ld a, [wCurSpecies]
	ld b, a
	predef PrintMoveType
	; Close the tab's bottom-right corner at col 9 row 11.
	hlcoord 9, 11
	ld [hl], '└'
	; ACC/ label and accuracy value at row 12 left.
	hlcoord 1, 12
	ld de, .AccLabel
	call PlaceString
	; Load ACC and convert to percentage: (stored*100+127)/255.
	ld a, [wCurSpecies]
	dec a
	ld hl, Moves + MOVE_ACC
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte          ; a = acc_stored (0 = always hits, 255 = 100%)
	and a
	jr z, .no_acc
	ld h, 0
	ld l, a                  ; hl = x
	add hl, hl               ; x*2
	add hl, hl               ; x*4
	ld d, h
	ld e, l                  ; de = x*4
	add hl, hl               ; x*8
	add hl, hl               ; x*16
	add hl, hl               ; x*32
	ld b, h
	ld c, l                  ; bc = x*32
	add hl, hl               ; x*64
	add hl, bc               ; x*96
	add hl, de               ; x*100
	ld bc, 127
	add hl, bc               ; x*100 + 127 (rounds to nearest)
	ld a, h
	ldh [hDividend + 0], a
	ld a, l
	ldh [hDividend + 1], a
	ld a, 255
	ldh [hDivisor], a
	ld b, 2
	call Divide
	ldh a, [hQuotient + 3]   ; percentage 0-100
	ld [wTextDecimalByte], a
	hlcoord 6, 12
	ld de, wTextDecimalByte
	lb bc, 1, 3
	call PrintNum
	jr .draw_atk
.no_acc:
	hlcoord 6, 12
	ld de, .NoAccStr
	call PlaceString
.draw_atk:
	; ATK/ label and power value at row 12 right.
	hlcoord 12, 12
	ld de, .MoveAtkLabel
	call PlaceString
	ld a, [wCurSpecies]
	dec a
	ld hl, Moves + MOVE_POWER
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	hlcoord 16, 12
	cp 2
	jr c, .no_power
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	lb bc, 1, 3
	call PrintNum
	jr .draw_description
.no_power:
	ld de, .NoPowerStr
	call PlaceString
.draw_description:
	; Description: line 1 at row 14, <NEXT> +2 rows → line 2 at row 16.
	hlcoord 1, 14
	predef PrintMoveDescription
	call WaitBGMap
	ret

.TypeTabTop:
	db "┌────────┐@"
.AccLabel:
	db "ACC/@"
.NoAccStr:
	db "---@"
.MoveAtkLabel:
	db "ATK/@"
.NoPowerStr:
	db "---@"

ForgetMove_ClearInfoPanel:
; Clear the folder tab (row 10) and info panel (rows 11-17).
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 10
	lb bc, 8, SCREEN_WIDTH
	call ClearBox
	call WaitBGMap
	ret

LearnedMoveText:
	text_far _LearnedMoveText
	text_end

DrawNewMoveInfoBox:
; Draw a folder-tab info box at the top of the screen for wPutativeTMHMMove.
; Tab row 0, main box rows 1-9 (full width).
; Row 2: type name  Row 3: ACC+ATK  Rows 5+7: description
	ld a, [wPutativeTMHMMove]
	and a
	ret z
	ld [wCurSpecies], a
	xor a
	ldh [hBGMapMode], a
	; Main box rows 1-7 (b=5 inner rows → bottom border at row 7).
	hlcoord 0, 1
	ld b, 5
	ld c, 18
	call Textbox
	; Tab top at row 0.
	hlcoord 0, 0
	ld de, .TypeTabTop
	call PlaceString
	; Set PAL_BG_TEXT in wAttrmap for the tab row (row 0, cols 0-9).
	hlcoord 0, 0
	ld de, wAttrmap - wTilemap
	add hl, de
	ld c, 10
	ld a, PAL_BG_TEXT
.pal_loop:
	ld [hli], a
	dec c
	jr nz, .pal_loop
	; Replace ┌ at col 0 row 1 with │ (tab left wall).
	hlcoord 0, 1
	ld [hl], '│'
	; Clear cols 1-8 of row 1 (remove leftover ─ from Textbox border).
	hlcoord 1, 1
	lb bc, 1, 8
	call ClearBox
	; Type name at col 1 row 1.
	hlcoord 1, 1
	ld a, [wCurSpecies]
	ld b, a
	predef PrintMoveType
	; Close tab bottom-right corner at col 9 row 1.
	hlcoord 9, 1
	ld [hl], '└'
	; ACC/ label + value at row 2 left.
	hlcoord 1, 2
	ld de, .AccLabel
	call PlaceString
	ld a, [wCurSpecies]
	dec a
	ld hl, Moves + MOVE_ACC
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	and a
	jr z, .no_acc
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc
	add hl, de
	ld bc, 127
	add hl, bc
	ld a, h
	ldh [hDividend + 0], a
	ld a, l
	ldh [hDividend + 1], a
	ld a, 255
	ldh [hDivisor], a
	ld b, 2
	call Divide
	ldh a, [hQuotient + 3]
	ld [wTextDecimalByte], a
	hlcoord 6, 2
	ld de, wTextDecimalByte
	lb bc, 1, 3
	call PrintNum
	jr .draw_atk
.no_acc:
	hlcoord 6, 2
	ld de, .NoAccStr
	call PlaceString
.draw_atk:
	; ATK/ label + value at row 2 right.
	hlcoord 12, 2
	ld de, .MoveAtkLabel
	call PlaceString
	ld a, [wCurSpecies]
	dec a
	ld hl, Moves + MOVE_POWER
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	hlcoord 16, 2
	cp 2
	jr c, .no_power
	ld [wTextDecimalByte], a
	ld de, wTextDecimalByte
	lb bc, 1, 3
	call PrintNum
	jr .draw_desc
.no_power:
	ld de, .NoPowerStr
	call PlaceString
.draw_desc:
	; Description lines at rows 4 and 6 (via <NEXT>).
	hlcoord 1, 4
	predef PrintMoveDescription
	call WaitBGMap
	ret

.TypeTabTop:
	db "┌────────┐@"
.AccLabel:
	db "ACC/@"
.NoAccStr:
	db "---@"
.MoveAtkLabel:
	db "ATK/@"
.NoPowerStr:
	db "---@"

ClearNewMoveInfoBox:
; Clear the new-move info panel (rows 0-9).
	xor a
	ldh [hBGMapMode], a
	hlcoord 0, 0
	lb bc, 10, SCREEN_WIDTH
	call ClearBox
	call WaitBGMap
	ret

RestoreBattleScreenAfterLearnMove:
; If we're in a battle, restore the battle screen after the move-learn UI
; wiped it. Reloads the saved tilemap snapshot and redraws both mon sprites.
; No-op outside of battle.
	ld a, [wBattleMode]
	and a
	ret z
	call SafeLoadTempTilemapToTilemap
	farcall GetBattleMonBackpic
	farcall GetEnemyMonFrontpic
	ret

MoveAskForgetText:
	text_far _MoveAskForgetText
	text_end

StopLearningMoveText:
	text_far _StopLearningMoveText
	text_end

DidNotLearnMoveText:
	text_far _DidNotLearnMoveText
	text_end

AskForgetMoveText:
	text_far _AskForgetMoveText
	text_end

Text_1_2_and_Poof:
	text_far Text_MoveForgetCount ; 1, 2 and…
	text_asm
	push de
	ld de, SFX_SWITCH_POKEMON
	call PlaySFX
	pop de
	ld hl, .MoveForgotText
	ret

.MoveForgotText:
	text_far _MoveForgotText
	text_end

MoveCantForgetHMText:
	text_far _MoveCantForgetHMText
	text_end
