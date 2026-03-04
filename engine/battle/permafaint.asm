WipePermafaintSave:
; Wipes all SRAM banks (deletes the save) and sets bit 1 of wPermafaint
; to signal Script_Whiteout to perform a soft reset instead of healing/warping.
	farcall EmptyAllSRAMBanks
	ld a, 3   ; bit 0 = permafaint on, bit 1 = game-over reset pending
	ld [wPermafaint], a
	ret

DoProcessPermafaintReleases:
; After a battle, release all party Pokemon with 0 HP if permafaint mode is on.
; Scans from the last slot backward so index-shifting after removal is handled safely.
; Skips: permafaint disabled, link battles, Battle Tower, or player just lost.
	ld a, [wPermafaint]
	and a
	ret z
	; Skip for link battles
	ld a, [wLinkMode]
	and a
	ret nz
	; Skip for Battle Tower
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	ret nz
	; Skip if the player lost (save is already wiped via EmptyAllSRAMBanks in LostBattle)
	ld a, [wBattleResult]
	and $f
	cp LOSE
	ret z
.restart:
	ld a, [wPartyCount]
	and a
	ret z
	dec a
	ld [wCurPartyMon], a
.scan:
	ld hl, wPartyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wCurPartyMon]
	call AddNTimes
	ld a, [hli]
	or [hl]
	jr z, .release
	; HP is non-zero - check the previous slot
	ld a, [wCurPartyMon]
	and a
	ret z
	dec a
	ld [wCurPartyMon], a
	jr .scan
.release:
	; wCurPartyMon points to a fainted mon - release it permanently
	xor a ; REMOVE_PARTY
	ld [wPokemonWithdrawDepositParameter], a
	farcall RemoveMonFromPartyOrBox
	jr .restart
