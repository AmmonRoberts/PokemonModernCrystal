NuzlockeWildBattleStart::
; Called via farcall from .PrintBattleStartText in core.asm.
; DE = appearance text pointer (set via ld d,h / ld e,l before the farcall;
; farcall preserves DE). BattleStart_TrainerHuds may clobber DE, so it is
; push/popped. Calls StdBattleTextbox (home fn) via tail-jp before returning;
; StdBattleTextbox's ret goes through ReturnFarCall back to core.asm.
	call NuzlockeCheckFirstEncounter
	push de                        ; save text ptr across farcall (may be clobbered)
	farcall BattleStart_TrainerHuds
	pop de                         ; restore text ptr
	ld a, [wNuzlockeFirstEncounter]
	and a
	jr z, .print_text
.print_text
	ld h, d              ; HL = text pointer
	ld l, e
	jp StdBattleTextbox  ; tail-jp: StdBattleTextbox's ret returns via ReturnFarCall


NuzlockeCheckFirstEncounter::
; Called at wild battle start (before "Wild X appeared!" text).
; If nuzlocke mode is active and this is the first encounter in the current
; landmark, sets wNuzlockeFirstEncounter = 1 and records the species in
; wNuzlockeAreas[landmark]. Also saves the landmark to wNuzlockeCurLandmark.
; In FORGIVING mode, skips marking if the species' evo line was already caught
; (duplicate clause) leaving the area OPEN for the next encounter.
; Always clears wNuzlockeFirstEncounter and wNuzlockeCurLandmark on entry.
;
; Register contract entering WRAMX 2 section:
;   B = raw enemy species, C = base-species-0-indexed
;   D = 0, E = landmark index
;
	push bc
	push de
	push hl

	xor a
	ld [wNuzlockeFirstEncounter], a
	ld [wNuzlockeCurLandmark], a

	ld a, [wNuzlockeMode]
	and a
	jr z, .done ; NUZLOCKE_DISABLED = 0

	ld a, [wBattleMode]
	dec a
	jr nz, .done ; not a wild battle (wBattleMode != 1)

	; Gate: rules don't apply until the player has returned the egg to Elm
	; (EVENT_GAVE_MYSTERY_EGG_TO_ELM is the canonical "intro arc done" flag)
	ld b, CHECK_FLAG
	ld de, EVENT_GAVE_MYSTERY_EGG_TO_ELM
	call EventFlagAction ; c = 0 if flag not set
	ld a, c
	and a
	jr z, .done ; intro not done yet: no nuzlocke restriction

	; Get the landmark for the current map (reads WRAMX 1)
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	call GetWorldMapLocation ; a = landmark index
	ld [wNuzlockeCurLandmark], a  ; WRAM0
	ld e, a            ; E = landmark (preserved into WRAMX 2 section)

	; Pre-resolve base evolution while WRAMX 1 is still active
	; (GetBaseEvolution uses wCurPartySpecies which is in WRAMX 1)
	ld a, [wEnemyMonSpecies]   ; WRAMX 1
	ld [wCurPartySpecies], a   ; WRAMX 1
	callfar GetBaseEvolution   ; wCurPartySpecies = base species; clobbers B via ReturnFarCall
	ld a, [wCurPartySpecies]   ; WRAMX 1 - base species
	dec a                      ; 0-indexed for SmallFarFlagAction
	ld c, a                    ; C = base species 0-indexed
	ld a, [wEnemyMonSpecies]   ; WRAMX 1 - reload raw species (ReturnFarCall clobbered B)
	ld b, a                    ; B = raw species for area slot
	ld a, [wNuzlockeCurLandmark] ; WRAM0 - reload landmark
	ld e, a                    ; E = landmark index
	ld d, 0                    ; D = 0 (for add hl, de; also SmallFarFlagAction d=0)

	; === Switch to WRAMX 2 for array operations ===
	ldh a, [rWBK]
	push af
	ld a, BANK(wNuzlockeAreas)
	ldh [rWBK], a

	; Check if area is OPEN (indexed by E = landmark, D = 0)
	ld hl, wNuzlockeAreas
	add hl, de
	ld a, [hl]
	cp NUZLOCKE_AREA_OPEN
	jr nz, .restore_bank   ; area already used, leave wNuzlockeFirstEncounter = 0

	; Area is OPEN — check mode (wNuzlockeMode is WRAM0, accessible at any bank)
	ld a, [wNuzlockeMode]
	cp NUZLOCKE_FORGIVING
	jr nz, .mark_area      ; STRICT: always mark

	; FORGIVING: apply duplicate clause
	; C = base-species-0-indexed, D = 0
	push bc                ; save B = raw_species, C = base_0indexed
	ld hl, wNuzlockeLinesCaught
	ld b, CHECK_FLAG
	predef SmallFarFlagAction ; C = 0 not caught; nonzero = caught dup
	ld a, c
	pop bc                 ; restore B = raw_species, C = base_0indexed
	and a
	jr nz, .restore_bank   ; evo line already caught: area stays OPEN, no indicator

.mark_area
	; Record raw species in area slot (B = raw species, D = 0, E = landmark)
	ld hl, wNuzlockeAreas
	add hl, de
	ld [hl], b

	; Signal that this is a first encounter
	ld a, 1
	ld [wNuzlockeFirstEncounter], a

.restore_bank
	pop af
	ldh [rWBK], a

.done
	pop hl
	pop de
	pop bc
	ret


NuzlockeMarkCaught::
; Call this after a successful catch in a nuzlocke-tracked wild battle.
; Marks the current area as CAUGHT and records the evo line in wNuzlockeLinesCaught.
; Safe to call always — guards on wNuzlockeFirstEncounter internally.
	push bc
	push de
	push hl

	ld a, [wNuzlockeFirstEncounter]
	and a
	jr z, .done ; not tracked

	; Pre-resolve base species while WRAMX 1 is still active
	ld a, [wEnemyMonSpecies]    ; WRAMX 1
	ld [wCurPartySpecies], a    ; WRAMX 1
	callfar GetBaseEvolution    ; wCurPartySpecies = base species (WRAMX 1)
	ld a, [wCurPartySpecies]    ; WRAMX 1
	dec a                       ; 0-indexed
	ld c, a                     ; C = base species 0-indexed
	ld a, [wNuzlockeCurLandmark] ; WRAM0
	ld e, a                     ; E = landmark
	ld d, 0                     ; D = 0

	; === Switch to WRAMX 2 ===
	ldh a, [rWBK]
	push af
	ld a, BANK(wNuzlockeAreas)
	ldh [rWBK], a

	; Mark area as CAUGHT
	ld hl, wNuzlockeAreas
	add hl, de
	ld a, NUZLOCKE_AREA_CAUGHT
	ld [hl], a

	; Set caught evo-line flag (C = base 0-indexed, D = 0)
	ld hl, wNuzlockeLinesCaught
	ld b, SET_FLAG
	predef SmallFarFlagAction

	pop af
	ldh [rWBK], a

.done
	pop hl
	pop de
	pop bc
	ret


NuzlockePostBattle::
; Called after a wild battle ends (from Script_reloadmapafterbattle).
; Updates wNuzlockeAreas based on the battle result.
; In FORGIVING mode, if the wild mon fled (wNuzlockeWildFled = 1), reopens the area.
; Otherwise the area is marked FAILED. Clears runtime flags.
	push bc
	push de
	push hl

	ld a, [wNuzlockeFirstEncounter]
	and a
	jr z, .done ; not tracked or already handled by NuzlockeMarkCaught

	ld a, [wNuzlockeCurLandmark]   ; WRAM0
	ld e, a
	ld d, 0

	; Pre-read WRAMX 1 values before bank switch
	ld a, [wBattleResult]          ; WRAMX 1
	and ~BATTLERESULT_BITMASK
	ld b, a                        ; B = masked battle result

	; === Switch to WRAMX 2 ===
	ldh a, [rWBK]
	push af
	ld a, BANK(wNuzlockeAreas)
	ldh [rWBK], a

	ld hl, wNuzlockeAreas
	add hl, de
	ld a, [hl]
	cp NUZLOCKE_AREA_CAUGHT        ; already caught (NuzlockeMarkCaught ran)
	jr z, .restore_bank

	; Decide: reopen (FORGIVING + DRAW + wild fled) or FAILED
	ld a, [wNuzlockeMode]          ; WRAM0
	cp NUZLOCKE_FORGIVING
	jr nz, .fail

	ld a, b                        ; masked battle result
	cp DRAW
	jr nz, .fail

	ld a, [wNuzlockeWildFled]      ; WRAM0
	and a
	jr z, .fail

	; FORGIVING + DRAW + wild fled: reopen this area
	ld a, NUZLOCKE_AREA_OPEN
	ld [hl], a
	jr .restore_bank

.fail
	ld a, NUZLOCKE_AREA_FAILED
	ld [hl], a

.restore_bank
	pop af
	ldh [rWBK], a

	xor a
	ld [wNuzlockeFirstEncounter], a ; WRAM0
	ld [wNuzlockeWildFled], a       ; WRAM0

.done
	pop hl
	pop de
	pop bc
	ret


; NuzlockeCannotCatchText pointer lives in engine/items/item_effects.asm
; (same bank as NuzlockeBlockCatch) so PrintText resolves it correctly.


NuzlockeDrawIndicator::
; Called via farcall from DrawEnemyHUD (Battle Core) at the end of every
; enemy HUD draw. Draws "!" at col 0 row 0 if wNuzlockeFirstEncounter is set.
; Col 0 is outside DrawEnemyHUD's ClearBox range (cols 1-11) so the tile
; persists for the full battle and is cleared naturally by ClearTilemap.
	ld a, [wNuzlockeFirstEncounter]
	and a
	ret z
	hlcoord 0, 0
	ld [hl], '!'
	ret
