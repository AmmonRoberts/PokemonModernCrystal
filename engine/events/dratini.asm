PrepareDratiniGift::
	ld a, DRATINI
	ld [wCurPartySpecies], a  ; set default before farcall (farcall clobbers A)
	farcall PrepareGiftMon
	ld a, 15
	ld [wCurPartyLevel], a
	ret

GiveDratini:
; if wScriptVar is 0 or 1, change the moveset of the last matching species in the party.
;  0: give it a special moveset with Extremespeed.
;  1: give it the normal moveset of a level 15 Dratini.
; In RANDOMIZED mode, the species won't be DRATINI so this function is a no-op;
; TeachExtremeSpeedGift handles EXTREMESPEED for randomized species.
	ld a, [wGiftRandMode]
	cp GIFT_RAND_STANDARD
	ret nz ; RANDOMIZED / DISABLED — skip Dratini-specific moveset

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
; Deposits the prepared gift mon (lv. 15) into the current PC box when the party is at limit.
; In STANDARD mode, applies the Extremespeed moveset unless EVENT_ANSWERED_DRAGON_MASTER_QUIZ_WRONG
; is set — mirroring GiveDratini's logic.
; In RANDOMIZED mode, teaches EXTREMESPEED if quiz was passed (handles this internally).
; Sets wScriptVar: 0 = box also full, 1 = sent to box successfully.
	ld a, [wCurPartySpecies] ; species set by PrepareDratiniGift
	ld [wTempEnemyMonSpecies], a
	ld a, 15
	ld [wCurPartyLevel], a
	xor a ; PARTYMON
	ld [wMonType], a
	farcall LoadEnemyMon
	farcall SendMonIntoBox
	jp nc, .BoxFull
; Successfully sent to box.
; In STANDARD mode, patch the moveset based on quiz result.
; In RANDOMIZED mode, teach EXTREMESPEED if quiz was passed.
	ld a, [wGiftRandMode]
	cp GIFT_RAND_STANDARD
	jp z, .StandardMoveset
	cp GIFT_RAND_RANDOMIZED
	jp nz, .SkipMoveset
	; RANDOMIZED mode: teach EXTREMESPEED only if quiz was passed
	ld de, EVENT_ANSWERED_DRAGON_MASTER_QUIZ_WRONG
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	jp nz, .SkipMoveset        ; quiz wrong — skip
	; Find best slot: empty first, then highest PP, tie-break = first non-damaging.
	; wCurPartyLevel is safe scratch (already consumed by LoadEnemyMon).
	ld a, BANK(sBoxMon1)
	call OpenSRAM

	; Phase 1 — find the first empty slot (move id = 0)
	ld b, 0              ; b = slot index
.BoxEmptySearch:
	ld hl, sBoxMon1 + 2
	ld a, l
	add b
	ld l, a
	jr nc, .BES_NC
	inc h
.BES_NC:
	ld a, [hl]
	and a
	jp z, .BoxWriteES    ; empty → b = slot index, write directly
	inc b
	ld a, b
	cp NUM_MOVES
	jr nz, .BoxEmptySearch

	; Pass A — highest PP across all occupied slots → wCurPartyLevel
	ld b, 0              ; b = best PP
	ld d, 0              ; d = slot index
.BoxPassA:
	ld hl, sBoxMon1 + 2
	ld a, l
	add d
	ld l, a
	jr nc, .BPassANC
	inc h
.BPassANC:
	ld a, [hl]
	and a
	jr z, .BoxPassANext
	push bc
	push de
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop de
	pop bc
	cp b
	jr c, .BoxPassANext
	ld b, a
.BoxPassANext:
	inc d
	ld a, d
	cp NUM_MOVES
	jr nz, .BoxPassA
	ld a, b
	ld [wCurPartyLevel], a   ; save best PP

	; Pass B — first non-damaging slot with PP == best PP
	ld b, NUM_MOVES
	ld d, 0
.BoxPassB:
	ld hl, sBoxMon1 + 2
	ld a, l
	add d
	ld l, a
	jr nc, .BPassBNC
	inc h
.BPassBNC:
	ld a, [hl]
	and a
	jr z, .BoxPassBNext
	push bc
	push de
	ld e, a
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	ld b, a
	ld a, [wCurPartyLevel]
	cp b
	jr nz, .BoxPassBPop
	ld a, e
	dec a
	ld hl, Moves + MOVE_POWER
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	and a
	jr nz, .BoxPassBPop
	pop de
	pop bc
	ld b, d
	jr .BoxWriteES
.BoxPassBPop:
	pop de
	pop bc
.BoxPassBNext:
	inc d
	ld a, d
	cp NUM_MOVES
	jr nz, .BoxPassB
	ld a, b
	cp NUM_MOVES
	jr nz, .BoxWriteES

	; Pass C — first slot (any type) with PP == best PP
	ld b, NUM_MOVES - 1
	ld d, 0
.BoxPassC:
	ld hl, sBoxMon1 + 2
	ld a, l
	add d
	ld l, a
	jr nc, .BPassCNC
	inc h
.BPassCNC:
	ld a, [hl]
	and a
	jr z, .BoxPassCNext
	push bc
	push de
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	ld c, a
	ld a, [wCurPartyLevel]
	cp c
	pop de
	pop bc
	jr nz, .BoxPassCNext
	ld b, d
	jr .BoxWriteES
.BoxPassCNext:
	inc d
	ld a, d
	cp NUM_MOVES
	jr nz, .BoxPassC

.BoxWriteES:
	; b = target slot index (0-3)
	ld hl, sBoxMon1 + 2
	ld a, l
	add b
	ld l, a
	jr nc, .BWriteNC
	inc h
.BWriteNC:
	ld [hl], EXTREMESPEED
	ld bc, MON_PP - MON_MOVES
	add hl, bc                 ; hl = PP slot for EXTREMESPEED
	push hl
	ld a, EXTREMESPEED - 1     ; 0-based move index
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte            ; a = max PP of EXTREMESPEED
	pop hl
	ld [hl], a
	call CloseSRAM
	jp .SkipMoveset
.StandardMoveset:
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
.SkipMoveset:
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
