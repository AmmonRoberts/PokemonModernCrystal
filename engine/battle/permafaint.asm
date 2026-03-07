WipePermafaintSave:
; Wipes all SRAM banks (deletes the save) and sets bit 2 of wPermafaint
; to signal Script_Whiteout to perform a soft reset instead of healing/warping.
	farcall EmptyAllSRAMBanks
	ld a, [wPermafaint]
	set 2, a  ; bit 2 = game-over reset pending
	ld [wPermafaint], a
	ret

HandlePermadeathAfterBattle:
; Called from ExitBattle. If the player just lost a single-player battle and
; reset-on-wipe (bit 1 of wPermafaint) is set, wipes the save.
; Then releases fainted party mons (if permadeath bit 0 is on),
; and if the party ended up empty, tries to withdraw the first PC mon.
	; Check: Lost, single-player, not Battle Tower, reset-on-wipe set
	ld a, [wBattleResult]
	and $f
	cp LOSE
	jr nz, .skip_wipe
	ld a, [wLinkMode]
	and a
	jr nz, .skip_wipe
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	jr nz, .skip_wipe
	ld a, [wPermafaint]
	bit 1, a
	jr z, .skip_wipe
	call WipePermafaintSave
.skip_wipe:
	call DoProcessPermafaintReleases
	call TryPermadeathPCWithdraw
	ret

TryPermadeathPCWithdraw:
; If permadeath (bit 0) is on, reset-on-wipe (bit 1) is off, and the party just became
; empty (due to permadeath releases), withdraw the first available mon from the PC.
; If no PC mon exists at all, wipe the save and set the game-over reset flag instead.
	ld a, [wPermafaint]
	bit 0, a
	ret z           ; permadeath off, nothing to do
	bit 1, a
	ret nz          ; reset-on-wipe is on; wipe logic already ran in LostBattle
	ld a, [wPartyCount]
	and a
	ret nz          ; party not empty, nothing to do

	; Party is empty with permadeath on. Try every PC box for a mon.
	ld a, [wCurBox]
	push af         ; save original active box index
	xor a
	ld [wCurBox], a
.try_next_box:
	farcall LoadBox
	ld a, BANK(sBoxCount)
	call OpenSRAM
	ld a, [sBoxCount]
	call CloseSRAM
	and a
	jr nz, .found_mon
	ld a, [wCurBox]
	inc a
	cp NUM_BOXES
	jr nc, .no_mons_anywhere
	ld [wCurBox], a
	jr .try_next_box

.found_mon:
	; wCurBox contains the box with a mon; sBox is loaded.
	; Withdraw slot 0 from the box into the party.
	xor a
	ld [wCurPartyMon], a
	ld a, BANK(sBoxSpecies)
	call OpenSRAM
	ld a, [sBoxSpecies]
	call CloseSRAM
	ld [wCurPartySpecies], a
	xor a ; wPokemonWithdrawDepositParameter = 0 (get into party)
	ld [wPokemonWithdrawDepositParameter], a
	predef SendGetMonIntoFromBox
	ld a, REMOVE_BOX
	ld [wPokemonWithdrawDepositParameter], a
	farcall RemoveMonFromPartyOrBox
	farcall SaveBox
	; Set bit 3 of wPermafaint to trigger the PC-withdraw message in Script_Whiteout.
	ld a, [wPermafaint]
	set 3, a
	ld [wPermafaint], a
	; Restore the original active box
	pop af
	ld [wCurBox], a
	farcall LoadBox
	ret

.no_mons_anywhere:
	; No mons in party or PC — wipe the save and trigger game-over reset
	pop af          ; discard saved box index (save is about to be wiped)
	call WipePermafaintSave
	ret

DoProcessPermafaintReleases:
; After a battle, release all party Pokemon with 0 HP if permafaint mode is on.
; Scans from the last slot backward so index-shifting after removal is handled safely.
; Skips: permafaint disabled, link battles, Battle Tower.
; Also skips if the player just lost AND reset-on-wipe is on (save already wiped).
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
	; If the player lost AND bit 1 (reset-on-wipe) is on, the save was already wiped — skip.
	; If reset-on-wipe is off, we still need to release fainted mons even on a loss.
	ld a, [wBattleResult]
	and $f
	cp LOSE
	jr nz, .run_releases
	ld a, [wPermafaint]
	bit 1, a
	ret nz
.run_releases:
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
