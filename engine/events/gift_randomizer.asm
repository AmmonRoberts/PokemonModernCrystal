; Gift Pokémon randomizer helpers
; See constants/randomizer_constants.asm for GIFT_RAND_* and GIFT_RESULT_* constants.
; See ram/wram.asm for wGiftRandMode.

; ---------------------------------------------------------------------------
; GetRandomGiftSpecies
; ---------------------------------------------------------------------------
; Selects the species to give based on wGiftRandMode.
; Input:  A = default species (used for STANDARD mode)
; Output: A = species to give; carry set if GIFT_RAND_DISABLED (caller should abort)
; Destroys: B, HL (from Random)
GetRandomGiftSpecies::
	ld a, [wGiftRandMode]
	cp GIFT_RAND_DISABLED
	jr z, .Disabled
	cp GIFT_RAND_RANDOMIZED
	jr nz, .Standard
.Generate:
	call Random          ; a = pseudo-random byte
	and a                ; species 0 is invalid
	jr z, .Generate
	cp NUM_POKEMON + 1   ; must be 1-251
	jr nc, .Generate
	; A = random species 1-251
	and a                ; clear carry
	ret
.Standard:
	ld a, [wCurPartySpecies] ; default species set by caller before farcall
	and a                ; clear carry
	ret
.Disabled:
	scf
	ret

; ---------------------------------------------------------------------------
; LoadGiftMonName
; ---------------------------------------------------------------------------
; Copies the name of wCurPartySpecies into wMonOrItemNameBuffer.
; Destroys: A, BC, DE, HL
LoadGiftMonName::
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	ret

; ---------------------------------------------------------------------------
; PrepareGiftMon
; ---------------------------------------------------------------------------
; General-purpose gift-mon preparation routine.
; Sets wCurPartySpecies to the effective species (possibly randomised),
; fills wMonOrItemNameBuffer with that species' name, and sets wScriptVar
; to GIFT_RESULT_DISABLED (0) or GIFT_RESULT_PARTY (1) to indicate whether
; the gift should proceed.
;
; Input:  A = default species
;         wCurPartyLevel = desired level (set by caller)
; Output: wCurPartySpecies, wMonOrItemNameBuffer, wScriptVar
; Destroys: A, B, HL
PrepareGiftMon::
	call GetRandomGiftSpecies ; reads default from wCurPartySpecies, returns effective species in A
	jr c, .Disabled
	ld [wCurPartySpecies], a
	call LoadGiftMonName
	ld a, GIFT_RESULT_PARTY  ; = 1 (gift is available)
	ld [wScriptVar], a
	ret
.Disabled:
	ld a, GIFT_RESULT_DISABLED ; = 0
	ld [wScriptVar], a
	ret

; ---------------------------------------------------------------------------
; GiftAutoNicknameParty
; ---------------------------------------------------------------------------
; If MODFLAG_AUTO_NICKNAME_F is set, overwrites the nickname of the last party
; mon with a random name.  Otherwise this is a no-op.
; Destroys: A, B, C, D, E, HL
GiftAutoNicknameParty::
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	ret z
	; Auto-nickname: pick a random name into the last party mon's nickname slot
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonNicknames
	call SkipNames
	push hl
	pop de               ; de = nickname destination
	farcall GiveRandomNickname
	ret

; ---------------------------------------------------------------------------
; GiftAutoNicknameBox
; ---------------------------------------------------------------------------
; If MODFLAG_AUTO_NICKNAME_F is set, overwrites the nickname of the first box
; slot with a random name.  Otherwise this is a no-op.
; Destroys: A, B, C, D, E, HL
GiftAutoNicknameBox::
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	ret z
	ld a, BANK(sBoxMonNicknames)
	call OpenSRAM
	ld de, sBoxMonNicknames
	farcall GiveRandomNickname
	call CloseSRAM
	ret

; ---------------------------------------------------------------------------
; GiftAskNicknameBox
; ---------------------------------------------------------------------------
; For gift Pokémon whose data was placed in the box via InsertPokemonIntoBox:
;   – If MODFLAG_AUTO_NICKNAME_F is set, writes a random name to sBoxMonNicknames.
;   – Otherwise, asks "Give it a nickname?" and opens the naming screen if yes,
;     then writes the chosen name to sBoxMonNicknames.
; The text box must be OPEN when this is called (caller has opentext active).
; If the naming screen is opened (via InitNickname), ExitAllMenus will close the
; text window; the caller must do closetext+opentext before any subsequent writetext.
; Destroys: A, B, C, D, E, HL
GiftAskNicknameBox::
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	jr nz, .AutoNickname
	; _CaughtAskNicknameText uses wStringBuffer1 for the species name — copy it there
	ld hl, wMonOrItemNameBuffer
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	; Manual path: ask the player
	farcall GiveANickname_YesNo
	ret c                        ; player said no — species name already in sBoxMonNicknames
	; Player said yes: open naming screen for the box mon
	ld a, BOXMON
	ld [wMonType], a
	ld de, wMonOrItemNameBuffer
	farcall InitNickname          ; chosen name → wMonOrItemNameBuffer; calls ExitAllMenus
	; Copy chosen name to sBoxMonNicknames
	ld a, BANK(sBoxMonNicknames)
	call OpenSRAM
	ld hl, wMonOrItemNameBuffer
	ld de, sBoxMonNicknames
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	call CloseSRAM
	ret
.AutoNickname:
	ld a, BANK(sBoxMonNicknames)
	call OpenSRAM
	ld de, sBoxMonNicknames
	farcall GiveRandomNickname
	call CloseSRAM
	ret

; ---------------------------------------------------------------------------
; GiftAskNicknameParty
; ---------------------------------------------------------------------------
; For gift Pokémon that normally ask "Give it a nickname?":
;   – If MODFLAG_AUTO_NICKNAME_F is set, auto-nicknames and returns.
;   – Otherwise, asks "Give it a nickname?" and opens the naming screen if yes.
; Must be called AFTER wMonOrItemNameBuffer holds the species name.
; Destroys: A, BC, DE, HL
GiftAskNicknameParty::
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	jp nz, GiftAutoNicknameParty ; auto-nickname path (jumps there, which rets)
	; _CaughtAskNicknameText uses wStringBuffer1 for the species name — copy it there
	ld hl, wMonOrItemNameBuffer
	ld de, wStringBuffer1
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	; Ask the player
	farcall GiveANickname_YesNo
	ret c                ; carry = player said "no" → keep species name
	; Player said yes: open naming screen
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	xor a
	ld [wMonType], a
	ld de, wMonOrItemNameBuffer
	farcall InitNickname
	; Copy the chosen name back to the party mon's nickname slot
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonNicknames
	call SkipNames
	ld d, h
	ld e, l
	ld hl, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	ret

; ---------------------------------------------------------------------------
; TeachExtremeSpeedToLastPartyMon
; ---------------------------------------------------------------------------
; Teaches EXTREMESPEED to the party mon at index wCurPartyMon.
; If a free move slot exists, uses it; otherwise picks the occupied slot with
; the highest PP (a proxy for "early/weak move"). On a PP tie, the first
; non-damaging (status) move wins; if still tied, the first match is used.
;
; Input:  wCurPartyMon = party index of the target mon
; Destroys: A, B, C, D, E, HL
TeachExtremeSpeedToLastPartyMon::
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes            ; HL = move slot 0 address (BASE)
	push hl                   ; (A) save BASE

	; ── Phase 1: find the first empty slot (move id = 0) ────────────────────
	ld b, 0
.EmptySearch:
	ld a, [hli]               ; read slot, advance HL
	and a
	jp z, .GotSlot            ; empty -> b = slot index
	inc b
	ld a, b
	cp NUM_MOVES
	jr nz, .EmptySearch

	; ── Phase 2: highest PP; tie-break → first non-damaging slot ─────────────
	; wCurPartyMon is safe scratch after its initial read above.
	; Stack throughout phase 2: [BASE]

	; Pass A — find the highest PP across all occupied slots → wCurPartyMon
	pop hl
	push hl
	ld b, 0              ; b = highest PP seen
	ld d, 0              ; d = current slot index
.PassA:
	pop hl
	push hl              ; HL = BASE
	ld a, l
	add d
	ld l, a
	jr nc, .PassANoCarry
	inc h
.PassANoCarry:
	ld a, [hl]
	and a
	jr z, .PassANext     ; empty slot — skip
	push bc
	push de
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte      ; a = max PP
	pop de
	pop bc
	cp b
	jr c, .PassANext     ; a < b -> not higher, skip
	ld b, a              ; new best PP
.PassANext:
	inc d
	ld a, d
	cp NUM_MOVES
	jr nz, .PassA
	ld a, b
	ld [wCurPartyMon], a ; save best PP

	; Pass B — first non-damaging slot whose PP == best PP
	pop hl
	push hl
	ld b, NUM_MOVES      ; NUM_MOVES = "not found"
	ld d, 0
.PassB:
	pop hl
	push hl
	ld a, l
	add d
	ld l, a
	jr nc, .PassBNoCarry
	inc h
.PassBNoCarry:
	ld a, [hl]
	and a
	jr z, .PassBNext
	push bc
	push de
	ld e, a              ; save move id (1-based)
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte      ; a = PP
	ld b, a
	ld a, [wCurPartyMon]
	cp b
	jr nz, .PassBPop     ; PP != best, skip
	; PP matches — check power
	ld a, e
	dec a
	ld hl, Moves + MOVE_POWER
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte      ; a = power
	and a
	jr nz, .PassBPop     ; damaging — skip
	; Found: first non-damaging slot with best PP
	pop de
	pop bc
	ld b, d
	jr .GotSlot
.PassBPop:
	pop de
	pop bc
.PassBNext:
	inc d
	ld a, d
	cp NUM_MOVES
	jr nz, .PassB
	; If Pass B found something (b != NUM_MOVES) use it
	ld a, b
	cp NUM_MOVES
	jr nz, .GotSlot

	; Pass C — first slot (any type) with PP == best PP
	pop hl
	push hl
	ld b, NUM_MOVES - 1  ; fallback: last slot
	ld d, 0
.PassC:
	pop hl
	push hl
	ld a, l
	add d
	ld l, a
	jr nc, .PassCNoCarry
	inc h
.PassCNoCarry:
	ld a, [hl]
	and a
	jr z, .PassCNext
	push bc
	push de
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	ld c, a
	ld a, [wCurPartyMon]
	cp c
	pop de
	pop bc
	jr nz, .PassCNext
	ld b, d
	jr .GotSlot
.PassCNext:
	inc d
	ld a, d
	cp NUM_MOVES
	jr nz, .PassC

.GotSlot:
	; b = target slot (0-3)
	; Stack: [BASE_A]
	pop hl                    ; HL = BASE
	ld a, l
	add b
	ld l, a
	jr nc, .WriteNoCarry
	inc h
.WriteNoCarry:
	; HL = address of the target move slot — write EXTREMESPEED
	ld [hl], EXTREMESPEED
	; Update the corresponding PP slot
	ld bc, MON_PP - MON_MOVES
	add hl, bc
	push hl
	ld a, EXTREMESPEED - 1    ; 0-based
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte           ; a = max PP of EXTREMESPEED
	pop hl
	ld [hl], a
	ret

; ---------------------------------------------------------------------------
; TeachExtremeSpeedGift
; ---------------------------------------------------------------------------
; Special-callable: teaches EXTREMESPEED to the last party mon, but only in
; RANDOMIZED mode when the Dragon's Den quiz was passed (wScriptVar == 0).
; In all other cases this is a no-op.
; Input:  wGiftRandMode, wScriptVar (0 = quiz passed, 1 = quiz failed)
;         wCurPartyMon set by the caller (or last party mon is used).
TeachExtremeSpeedGift::
	ld a, [wGiftRandMode]
	cp GIFT_RAND_RANDOMIZED
	ret nz                   ; only act in RANDOMIZED mode
	ld a, [wScriptVar]
	and a                    ; 0 = quiz passed
	ret nz                   ; quiz failed — don't teach
	; Use the last party mon
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	call TeachExtremeSpeedToLastPartyMon
	ret

; ---------------------------------------------------------------------------
; SanitizeGiftRandMode
; ---------------------------------------------------------------------------
; Clamps wGiftRandMode to [0, NUM_GIFT_RAND_MODES). Old saves have garbage here.
; Called via farcall from _LoadData.
SanitizeGiftRandMode::
	ld a, [wGiftRandMode]
	cp NUM_GIFT_RAND_MODES
	ret c                   ; value is valid (< NUM_GIFT_RAND_MODES)
	xor a                   ; invalid → GIFT_RAND_STANDARD
	ld [wGiftRandMode], a
	ret

; ---------------------------------------------------------------------------
; PrepareOddEggGift
; ---------------------------------------------------------------------------
; Checks wGiftRandMode and sets wScriptVar for the Odd Egg.
;   GIFT_RESULT_DISABLED (0) — gifts are disabled, do not give the egg
;   GIFT_RESULT_PARTY    (1) — proceed with giving the egg
; Species randomisation (RANDOMIZED mode) is applied inside _GiveOddEgg.
PrepareOddEggGift::
	ld a, [wGiftRandMode]
	cp GIFT_RAND_DISABLED
	jr nz, .Available
	ld a, GIFT_RESULT_DISABLED
	ld [wScriptVar], a
	ret
.Available:
	ld a, GIFT_RESULT_PARTY
	ld [wScriptVar], a
	ret

; ---------------------------------------------------------------------------
; GiveTogepiGift
; ---------------------------------------------------------------------------
; Gives a Togepi egg (or a random-species egg when GIFT_RAND_RANDOMIZED) to
; the party.  Respects GIFT_RAND_DISABLED.  If the party is full, reports FULL
; (eggs cannot be boxed directly via this routine).
;
; Sets wMonOrItemNameBuffer to the egg species name (for the received text).
;
; Output: wScriptVar = GIFT_RESULT_DISABLED (0)
;                      GIFT_RESULT_PARTY    (1) – egg added to party
;                      GIFT_RESULT_FULL     (3) – party is full
GiveTogepiGift::
	ld a, TOGEPI
	ld [wCurPartySpecies], a  ; set before call so GetRandomGiftSpecies can read the default
	call GetRandomGiftSpecies ; A = effective species, carry = disabled
	jr c, .Disabled
	; Store effective species and load the display name
	ld [wCurPartySpecies], a
	call LoadGiftMonName      ; wMonOrItemNameBuffer = species name
	; Give as an EGG (uses wCurPartySpecies, level EGG_LEVEL)
	ld a, EGG_LEVEL
	ld [wCurPartyLevel], a
	xor a ; PARTYMON
	ld [wMonType], a
	farcall GiveEgg           ; returns carry set = party full (failed)
	jr nc, .Full
	ld a, GIFT_RESULT_PARTY
	ld [wScriptVar], a
	ret
.Full:
	ld a, GIFT_RESULT_FULL
	ld [wScriptVar], a
	ret
.Disabled:
	ld a, GIFT_RESULT_DISABLED
	ld [wScriptVar], a
	ret
