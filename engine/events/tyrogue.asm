GiveTyrogueToBox::
; Deposits Tyrogue (lv. 10) into the current PC box when the party is at limit.
; Sets wScriptVar: 0 = box also full, 1 = sent to box successfully.
	ld a, TYROGUE
	ld [wCurPartySpecies], a
	ld [wTempEnemyMonSpecies], a
	ld a, 10
	ld [wCurPartyLevel], a
	xor a ; PARTYMON
	ld [wMonType], a
	farcall LoadEnemyMon
	farcall SendMonIntoBox
	jr nc, .BoxFull
	ld a, 1
	ld [wScriptVar], a
	ret
.BoxFull:
	xor a
	ld [wScriptVar], a
	ret
