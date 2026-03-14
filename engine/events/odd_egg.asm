PrepareOddEggData:
; Selects a random OddEgg entry, copies it into wOddEgg, optionally
; randomises the species and moveset, then removes the EGG_TICKET.
	; Figure out which egg to give.
	; Compare a random word to probabilities out of $ffff.
	call Random
	ld hl, OddEggProbabilities
	ld c, 0
	ld b, c
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a

	; Break on $ffff.
	ld a, d
	cp HIGH($ffff)
	jr nz, .not_done
	ld a, e
	cp LOW($ffff)
	jr z, .done
.not_done

	; Break when the random word <= the next probability in de.
	ldh a, [hRandomSub]
	cp d
	jr c, .done
	jr z, .ok
	jr .next
.ok
	ldh a, [hRandomAdd]
	cp e
	jr c, .done
	jr z, .done
.next
	inc bc
	jr .loop
.done

	ld hl, OddEggs
	ld a, NICKNAMED_MON_STRUCT_LENGTH
	call AddNTimes

	; Writes to wOddEgg, wOddEggName, and wOddEggOT,
	; even though OddEggs does not have data for wOddEggOT
	ld de, wOddEgg
	ld bc, NICKNAMED_MON_STRUCT_LENGTH + NAME_LENGTH
	call CopyBytes

	; In RANDOMIZED mode, override the species byte with a random Pokémon.
	ld a, [wGiftRandMode]
	cp GIFT_RAND_RANDOMIZED
	jr nz, .KeepSpecies
.RandomiseOddEgg:
	call Random
	and a                ; species 0 is invalid
	jr z, .RandomiseOddEgg
	cp NUM_POKEMON + 1   ; must be 1-251
	jr nc, .RandomiseOddEgg
	ld [wOddEgg], a      ; first byte of wOddEgg is the species
	; Replace the vanilla special moveset with default level-up moves for this species.
	ld [wCurPartySpecies], a
	ld a, EGG_LEVEL
	ld [wCurPartyLevel], a
	ld hl, wOddEgg + MON_MOVES
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wSkipMovesBeforeLevelUp], a
	ld de, wOddEgg + MON_MOVES
	predef FillMoves
	; Fill the PP slots for the newly assigned moves.
	ld b, NUM_MOVES
	ld hl, wOddEgg + MON_MOVES
	ld de, wOddEgg + MON_PP
.FillOddEggPP:
	ld a, [hli]
	and a
	jr z, .OddEggNoPP    ; empty slot → 0 PP
	push bc
	push hl
	push de
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte      ; a = max PP of this move
	pop de
	pop hl
	pop bc
	jr .OddEggSetPP
.OddEggNoPP:
	xor a
.OddEggSetPP:
	ld [de], a
	inc de
	dec b
	jr nz, .FillOddEggPP
.KeepSpecies:

	ld a, EGG_TICKET
	ld [wCurItem], a
	ld a, 1
	ld [wItemQuantityChange], a
	ld a, -1
	ld [wCurItemQuantity], a
	ld hl, wNumItems
	call TossItem
	ret

_GiveOddEgg:
	call PrepareOddEggData

	; load species in wMobileMonSpecies
	ld a, EGG
	ld [wMobileMonMiscSpecies], a

	; load pointer to (wMobileMonSpecies - 1) in wMobileMonSpeciesPointer
	ld a, LOW(wMobileMonMiscSpecies - 1)
	ld [wMobileMonSpeciesPointer], a
	ld a, HIGH(wMobileMonMiscSpecies - 1)
	ld [wMobileMonSpeciesPointer + 1], a
	; load pointer to wOddEgg in wMobileMonStructPointer
	ld a, LOW(wOddEgg)
	ld [wMobileMonStructPointer], a
	ld a, HIGH(wOddEgg)
	ld [wMobileMonStructPointer + 1], a

	; load Odd Egg Name in wTempOddEggNickname
	ld hl, .Odd
	ld de, wTempOddEggNickname
	ld bc, MON_NAME_LENGTH
	call CopyBytes

	; load pointer to wTempOddEggNickname in wMobileMonOTPointer
	ld a, LOW(wTempOddEggNickname)
	ld [wMobileMonOTPointer], a
	ld a, HIGH(wTempOddEggNickname)
	ld [wMobileMonOTPointer + 1], a
	; load pointer to wOddEggName in wMobileMonNicknamePointer
	ld a, LOW(wOddEggName)
	ld [wMobileMonNicknamePointer], a
	ld a, HIGH(wOddEggName)
	ld [wMobileMonNicknamePointer + 1], a
	farcall AddMobileMonToParty
	ret

.Odd:
	dname "ODD", MON_NAME_LENGTH + 1

INCLUDE "data/events/odd_eggs.asm"

GiveOddEggToBox::
; Deposits the Odd Egg into the current PC box when the party is at limit.
; Calls PrepareOddEggData to select/randomise the egg and remove the ticket,
; then sends it to the box. Preserves DVs, moves, and hatch counter.
; Sets wScriptVar: 0 = box also full, 1 = sent to box successfully.
	call PrepareOddEggData
	; Set EGG as the species entry in the box species list; EGG_LEVEL for exp.
	ld a, EGG
	ld [wCurPartySpecies], a
	ld a, EGG_LEVEL
	ld [wCurPartyLevel], a
	; Copy species, item, and moves from wOddEgg into wEnemyMon.
	ld hl, wOddEgg
	ld de, wEnemyMon
	ld bc, 1 + 1 + NUM_MOVES
	call CopyBytes
	; Copy DVs and PP from wOddEgg into wEnemyMonDVs.
	ld hl, wOddEgg + MON_DVS
	ld de, wEnemyMonDVs
	ld bc, 2 + NUM_MOVES
	call CopyBytes
	farcall SendMonIntoBox
	jr nc, .BoxFull
	; SendMonIntoBox overwrites the happiness byte with BASE_HAPPINESS.
	; Restore the real hatch counter from wOddEgg.
	ld a, BANK(sBoxMon1)
	call OpenSRAM
	ld hl, sBoxMon1 + MON_HAPPINESS
	ld a, [wOddEgg + MON_HAPPINESS]
	ld [hl], a
	call CloseSRAM
	ld a, 1
	ld [wScriptVar], a
	ret
.BoxFull:
	xor a
	ld [wScriptVar], a
	ret
