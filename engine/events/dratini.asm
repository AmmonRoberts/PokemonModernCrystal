GiveDratini:
; if wScriptVar is 0 or 1, change the moveset of the last Dratini in the party.
;  0: give it a special moveset with Extremespeed.
;  1: give it the normal moveset of a level 15 Dratini.

	ld a, [wScriptVar]
	cp $2
	ret nc
	ld bc, wPartyCount
	ld a, [bc]
	ld hl, MON_SPECIES
	call .GetNthPartyMon
	ld a, [bc]
	ld c, a
	ld de, PARTYMON_STRUCT_LENGTH
.CheckForDratini:
; start at the end of the party and search backwards for a Dratini
	ld a, [hl]
	cp DRATINI
	jr z, .GiveMoveset
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	dec c
	jr nz, .CheckForDratini
	ret

.GiveMoveset:
	push hl
	ld a, [wScriptVar]
	ld hl, .Movesets
	ld bc, .Moveset1 - .Moveset0
	call AddNTimes

	; get address of mon's first move
	pop de
	inc de
	inc de

.GiveMoves:
	ld a, [hl]
	and a ; is the move 00?
	ret z ; if so, we're done here

	push hl
	push de
	ld [de], a ; give the Pokémon the new move

	; get the PP of the new move
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte

	; get the address of the move's PP and update the PP
	ld hl, MON_PP - MON_MOVES
	add hl, de
	ld [hl], a

	pop de
	pop hl
	inc de
	inc hl
	jr .GiveMoves

.Movesets:
.Moveset0:
; Dratini does not normally learn Extremespeed. This is a special gift.
	db WRAP
	db THUNDER_WAVE
	db TWISTER
	db EXTREMESPEED
	db 0
.Moveset1:
; This is the normal moveset of a level 15 Dratini
	db WRAP
	db LEER
	db THUNDER_WAVE
	db TWISTER
	db 0

.GetNthPartyMon:
; inputs:
; hl must be set to 0 before calling this function.
; a must be set to the number of Pokémon in the party.

; outputs:
; returns the address of the last Pokémon in the party in hl.
; sets carry if a is 0.

	ld de, wPartyMon1
	add hl, de
	and a
	jr z, .EmptyParty
	dec a
	ret z
	ld de, PARTYMON_STRUCT_LENGTH
.loop
	add hl, de
	dec a
	jr nz, .loop
	ret

.EmptyParty:
	scf
	ret

GiveDratiniToBox::
; Deposits Dratini (lv. 15) into the current PC box when the party is at limit.
; Applies the Extremespeed moveset unless EVENT_ANSWERED_DRAGON_MASTER_QUIZ_WRONG is set,
; in which case the standard level-15 moveset is used — mirroring GiveDratini's logic.
; Sets wScriptVar: 0 = box also full, 1 = sent to box successfully.
	ld a, DRATINI
	ld [wCurPartySpecies], a
	ld [wTempEnemyMonSpecies], a
	ld a, 15
	ld [wCurPartyLevel], a
	xor a ; PARTYMON
	ld [wMonType], a
	farcall LoadEnemyMon
	farcall SendMonIntoBox
	jr nc, .BoxFull
; Successfully sent to box. Patch the moveset and PP in the new box mon.
	ld de, EVENT_ANSWERED_DRAGON_MASTER_QUIZ_WRONG
	ld b, CHECK_FLAG
	call EventFlagAction
; c is nonzero if the quiz was answered wrong → use normal moveset.
; c is zero if answered correctly → use Extremespeed moveset.
	ld a, c
	and a
	ld hl, .NormalMoveset
	jr nz, .PatchMoves
	ld hl, .ExtraspeedMoveset
.PatchMoves:
	ld a, BANK(sBoxMon1)
	call OpenSRAM
	ld de, sBoxMon1 + 2 ; first move slot (after species[1] + item[1])
.Loop:
	ld a, [hli]
	and a
	jr z, .Done
	ld [de], a
	push hl
	push de
	dec a               ; move constant is 1-based; table is 0-based
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte     ; a = PP for this move
	ld hl, MON_PP - MON_MOVES
	add hl, de          ; hl = PP slot corresponding to current move slot
	ld [hl], a
	pop de
	pop hl
	inc de
	jr .Loop
.Done:
	call CloseSRAM
	ld a, 1
	ld [wScriptVar], a
	ret
.BoxFull:
	xor a
	ld [wScriptVar], a
	ret
.ExtraspeedMoveset:
	db WRAP
	db THUNDER_WAVE
	db TWISTER
	db EXTREMESPEED
	db 0
.NormalMoveset:
	db WRAP
	db LEER
	db THUNDER_WAVE
	db TWISTER
	db 0
