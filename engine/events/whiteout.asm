Script_BattleWhiteout::
	callasm BattleBGMap
	sjump Script_Whiteout

OverworldWhiteoutScript::
	reanchormap
	callasm OverworldBGMap

Script_Whiteout:
	writetext .WhitedOutText
	waitbutton
	callasm ShowPermadeathWhiteoutMessage
	special FadeOutToWhite
	pause 40
	callasm CheckPermafaintGameOver
	special HealParty
	checkflag ENGINE_BUG_CONTEST_TIMER
	iftrue .bug_contest
	callasm HalveMoney
	callasm GetWhiteoutSpawn
	farscall Script_AbortBugContest
	special WarpToSpawnPoint
	newloadmap MAPSETUP_WARP
	endall

.bug_contest
	jumpstd BugContestResultsWarpScript

.WhitedOutText:
	text_far _WhitedOutText
	text_end

.PCWithdrawText:
	text_far _PermadeathPCWithdrawText
	text_end

.NoMonsGameOverText:
	text_far _PermadeathNoMonsGameOverText
	text_end

.WipeGameOverText:
	text_far _PermadeathWipeGameOverText
	text_end

OverworldBGMap:
	call ClearPalettes
	call ClearScreen
	call WaitBGMap2
	call HideSprites
	call RotateThreePalettesLeft
	ret

ShowPermadeathWhiteoutMessage:
; Called from Script_Whiteout after the "blacked out" text is dismissed.
; Shows an informational or game-over message based on wPermafaint flags:
;   bit 3 set → a Pokémon was retrieved from the PC into slot 0 of the party
;   bit 2 set + bit 1 set → game over due to reset-on-wipe
;   bit 2 set + bit 1 clear → game over: no Pokémon remain anywhere
	ld a, [wPermafaint]
	bit 3, a
	jr z, .check_gameover
	; Load the withdrawn mon's nickname fresh from party slot 0.
	; It was just placed there by TryPermadeathPCWithdraw and is safe to read now.
	res 3, a
	ld [wPermafaint], a
	xor a
	ld hl, wPartyMonNicknames
	call GetNickname
	ld hl, Script_Whiteout.PCWithdrawText
	call PrintText
	call WaitPressAorB_BlinkCursor
	ret
.check_gameover:
	bit 2, a
	ret z           ; no game-over, nothing to show
	bit 1, a
	jr z, .no_mons
	; Reset-on-wipe game over
	ld hl, Script_Whiteout.WipeGameOverText
	call PrintText
	call WaitPressAorB_BlinkCursor
	ret
.no_mons:
	; Permadeath: no Pokémon left anywhere
	ld hl, Script_Whiteout.NoMonsGameOverText
	call PrintText
	call WaitPressAorB_BlinkCursor
	ret

CheckPermafaintGameOver:
; If bit 2 of wPermafaint is set, the save was just wiped due to a party wipe.
; Soft-reset the game instead of healing and warping the player.
	ld a, [wPermafaint]
	bit 2, a
	ret z        ; not a game-over wipe — return normally to the script
	jp Reset     ; screen is already white; reset to title

BattleBGMap:
	ld b, SCGB_BATTLE_GRAYSCALE
	call GetSGBLayout
	call SetDefaultBGPAndOBP
	ret

HalveMoney:
	farcall StubbedTrainerRankings_WhiteOuts

; Halve the player's money.
	ld hl, wMoney
	ld a, [hl]
	srl a
	ld [hli], a
	ld a, [hl]
	rra
	ld [hli], a
	ld a, [hl]
	rra
	ld [hl], a
	ret

GetWhiteoutSpawn:
	ld a, [wLastSpawnMapGroup]
	ld d, a
	ld a, [wLastSpawnMapNumber]
	ld e, a
	farcall IsSpawnPoint
	ld a, c
	jr c, .yes
	xor a ; SPAWN_HOME

.yes
	ld [wDefaultSpawnpoint], a
	ret
