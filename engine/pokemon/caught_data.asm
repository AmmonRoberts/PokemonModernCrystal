CheckPartyFullAfterContest:
	ld a, [wContestMonSpecies]
	and a
	jp z, .DidntCatchAnything
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	call GetBaseData
	ld hl, wPartyCount
	ld a, [wPartyLimit]
	ld b, a
	ld a, [hl]
	cp b
	jp nc, .TryAddToBox
	inc a
	ld [hl], a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wContestMonSpecies]
	ld [hli], a
	ld [wCurSpecies], a
	ld a, -1
	ld [hl], a
	ld hl, wPartyMon1Species
	ld a, [wPartyCount]
	dec a
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, wContestMon
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonOTs
	call SkipNames
	ld d, h
	ld e, l
	ld hl, wPlayerName
	call CopyBytes
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	call GiveANickname_YesNo
	jr c, .Party_SkipNickname
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	xor a
	ld [wMonType], a
	ld de, wMonOrItemNameBuffer
	callfar InitNickname

.Party_SkipNickname:
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMonNicknames
	call SkipNames
	ld d, h
	ld e, l
	ld hl, wMonOrItemNameBuffer
	call CopyBytes
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1Level
	call GetPartyLocation
	ld a, [hl]
	ld [wCurPartyLevel], a
	call SetCaughtData
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1CaughtLocation
	call GetPartyLocation
	ld a, [hl]
	and CAUGHT_GENDER_MASK
	ld b, LANDMARK_NATIONAL_PARK
	or b
	ld [hl], a
	xor a
	ld [wContestMonSpecies], a
	and a ; BUGCONTEST_CAUGHT_MON
	ld [wScriptVar], a
	ret

.TryAddToBox:
	ld a, BANK(sBoxCount)
	call OpenSRAM
	ld hl, sBoxCount
	ld a, [hl]
	cp MONS_PER_BOX
	call CloseSRAM
	jr nc, .BoxFull
	xor a
	ld [wCurPartyMon], a
	ld hl, wContestMon
	ld de, wBufferMon
	ld bc, BOXMON_STRUCT_LENGTH
	call CopyBytes
	ld hl, wPlayerName
	ld de, wBufferMonOT
	ld bc, NAME_LENGTH
	call CopyBytes
	callfar InsertPokemonIntoBox
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndex], a
	call GetPokemonName
	call GiveANickname_YesNo
	ld hl, wStringBuffer1
	jr c, .Box_SkipNickname
	ld a, BOXMON
	ld [wMonType], a
	ld de, wMonOrItemNameBuffer
	callfar InitNickname
	ld hl, wMonOrItemNameBuffer

.Box_SkipNickname:
	ld a, BANK(sBoxMonNicknames)
	call OpenSRAM
	ld de, sBoxMonNicknames
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	call CloseSRAM

.BoxFull:
	ld a, BANK(sBoxMon1Level)
	call OpenSRAM
	ld a, [sBoxMon1Level]
	ld [wCurPartyLevel], a
	call CloseSRAM
	call SetBoxMonCaughtData
	ld a, BANK(sBoxMon1CaughtLocation)
	call OpenSRAM
	ld hl, sBoxMon1CaughtLocation
	ld a, [hl]
	and CAUGHT_GENDER_MASK
	ld b, LANDMARK_NATIONAL_PARK
	or b
	ld [hl], a
	call CloseSRAM
	xor a
	ld [wContestMon], a
	ld a, BUGCONTEST_BOXED_MON
	ld [wScriptVar], a
	ret

.DidntCatchAnything:
	ld a, BUGCONTEST_NO_CATCH
	ld [wScriptVar], a
	ret

GiveANickname_YesNo:
	ld hl, CaughtAskNicknameText
	call PrintText
	jp YesNoBox

CaughtAskNicknameText:
	text_far _CaughtAskNicknameText
	text_end

SetCaughtData:
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1CaughtLevel
	call GetPartyLocation
SetBoxmonOrEggmonCaughtData:
	ld a, [wTimeOfDay]
	inc a
	rrca
	rrca
	ld b, a
	ld a, [wCurPartyLevel]
	or b
	ld [hli], a
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	ld c, a
	cp MAP_POKECENTER_2F
	jr nz, .NotPokecenter2F
	ld a, b
	cp GROUP_POKECENTER_2F
	jr nz, .NotPokecenter2F

	ld a, [wBackupMapGroup]
	ld b, a
	ld a, [wBackupMapNumber]
	ld c, a

.NotPokecenter2F:
	call GetWorldMapLocation
	ld b, a
	ld a, [wPlayerGender]
	rrca ; shift bit 0 (PLAYERGENDER_FEMALE_F) to bit 7 (CAUGHT_GENDER_MASK)
	or b
	ld [hl], a
	ret

SetBoxMonCaughtData:
	ld a, BANK(sBoxMon1CaughtLevel)
	call OpenSRAM
	ld hl, sBoxMon1CaughtLevel
	call SetBoxmonOrEggmonCaughtData
	call CloseSRAM
	ret

SetGiftBoxMonCaughtData:
	push bc
	ld a, BANK(sBoxMon1CaughtLevel)
	call OpenSRAM
	ld hl, sBoxMon1CaughtLevel
	pop bc
	call SetGiftMonCaughtData
	call CloseSRAM
	ret

SetGiftPartyMonCaughtData:
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1CaughtLevel
	push bc
	call GetPartyLocation
	pop bc
SetGiftMonCaughtData:
	xor a
	ld [hli], a
	ld a, LANDMARK_GIFT
	rrc b
	or b
	ld [hl], a
	ret

SetEggMonCaughtData:
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1CaughtLevel
	call GetPartyLocation
	ld a, [wCurPartyLevel]
	push af
	ld a, CAUGHT_EGG_LEVEL
	ld [wCurPartyLevel], a
	call SetBoxmonOrEggmonCaughtData
	pop af
	ld [wCurPartyLevel], a
	ret

SaveCrystalData::
; Save wCrystalData (mod/rando flags, party limit, exp mult, etc.) to sCrystalData.
; Called via farcall from _SaveGameData on every normal save.
	ld a, BANK(sCrystalData)
	call OpenSRAM
	ld hl, wCrystalData
	ld de, sCrystalData
	ld bc, wCrystalDataEnd - wCrystalData
	call CopyBytes
	jp CloseSRAM

CheckPartyAtLimit::
; Sets wScriptVar = 1 if wPartyCount >= wPartyLimit, 0 otherwise.
; Used by scripts as: special CheckPartyAtLimit / iftrue .PartyFull
	ld a, [wPartyLimit]
	ld b, a
	ld a, [wPartyCount]
	cp b
	ld a, 0
	jr c, .has_room   ; partyCount < partyLimit
	inc a             ; = 1 (at or over limit)
.has_room
	ld [wScriptVar], a
	ret
; --- Kenya delivery specials ---
; RANDY_OT_ID is defined in move_mon.asm.

KenyaMailMessage:
; Same content as GiftSpearowMail+1 in Route35GoldenrodGate.asm.
; Must be exactly MAIL_MSG_LENGTH + 1 bytes (33 total: message + MessageEnd).
	db "DARK CAVE leads"
	next "to another road@"
	db 0 ; MessageEnd

KenyaOTName:
; NAME_LENGTH - 1 = 10 bytes: covers the Author + Nationality fields in the mailmsg struct.
	db "RANDY@"
	ds 4 ; padding

KenyaNickname:
	db "KENYA@"

GiveKenyaToBox::
; Deposits Kenya (SPEAROW lv.10) into the current PC box when the party is at limit.
; Also writes the FLOWER_MAIL to the PC mailbox if there is room.
; Sets wScriptVar: 0 = box full, 1 = sent to box + mail deposited, 2 = sent to box + mailbox full
	ld a, SPEAROW
	ld [wCurPartySpecies], a
	ld [wTempEnemyMonSpecies], a
	ld a, 10
	ld [wCurPartyLevel], a
	xor a ; PARTYMON
	ld [wMonType], a
	farcall LoadEnemyMon
	farcall SendMonIntoBox
	jr nc, .BoxFull
; Success: patch OT name, nickname, and OT ID in SRAM so the box mon shows Randy as trainer.
	ld a, BANK(sBoxMonOTs)
	call OpenSRAM
	ld hl, sBoxMonOTs
	ld de, KenyaOTName
	call CopyName2        ; "RANDY@" -> OT slot 1
	ld hl, sBoxMonNicknames
	ld de, KenyaNickname
	call CopyName2        ; "KENYA@" -> nickname slot 1
	ld hl, sBoxMon1 + 1 + 1 + NUM_MOVES ; OT ID field (species + item + moves = offset 6)
	ld a, HIGH(RANDY_OT_ID)
	ld [hli], a
	ld a, LOW(RANDY_OT_ID)
	ld [hl], a
	call CloseSRAM
; Check whether there is room in the PC mailbox.
	ld a, BANK(sMailboxCount)
	call OpenSRAM
	ld a, [sMailboxCount]
	call CloseSRAM
	cp MAILBOX_CAPACITY
	jr nc, .MailboxFull
; Write the FLOWER_MAIL to the next free mailbox slot.
	; a = current count = 0-based index of the new slot
	push bc             ; save bc (b used as slot index below)
	ld hl, sMailboxes
	ld bc, MAIL_STRUCT_LENGTH
	call AddNTimes      ; hl = sMailboxes + count * MAIL_STRUCT_LENGTH
	ld d, h
	ld e, l             ; de = destination (new slot)
; Write Message + MessageEnd (MAIL_MSG_LENGTH + 1 = 33 bytes)
	ld hl, KenyaMailMessage
	ld bc, MAIL_MSG_LENGTH + 1
	ld a, BANK(sMailboxCount)
	call OpenSRAM
	call CopyBytes      ; hl (ROM) -> de (SRAM), bc bytes; de advances to Author field
; Write Author + Nationality (NAME_LENGTH - 1 = 10 bytes covers both fields)
	ld hl, KenyaOTName
	ld bc, NAME_LENGTH - 1
	call CopyBytes      ; de advances to AuthorID field
; Write AuthorID (2 bytes)
	ld a, HIGH(RANDY_OT_ID)
	ld [de], a
	inc de
	ld a, LOW(RANDY_OT_ID)
	ld [de], a
	inc de
; Write Species (1 byte)
	ld a, SPEAROW
	ld [de], a
	inc de
; Write Type / mail item (1 byte)
	ld a, FLOWER_MAIL
	ld [de], a
; Increment mailbox count
	ld hl, sMailboxCount
	inc [hl]
	call CloseSRAM
	pop bc
	ld a, 1
	ld [wScriptVar], a
	ret
.MailboxFull
	ld a, 2
	ld [wScriptVar], a
	ret
.BoxFull
	xor a
	ld [wScriptVar], a
	ret

ClaimKenyaMailFromMailbox::
; Searches the PC mailbox for a FLOWER_MAIL entry. If found, removes it and sets
; wScriptVar = 1. Sets wScriptVar = 0 if no FLOWER_MAIL is in the mailbox.
	ld a, BANK(sMailboxCount)
	call OpenSRAM
	ld a, [sMailboxCount]
	call CloseSRAM
	and a
	jr z, .NotFound     ; mailbox is empty
	ld c, a             ; c = count
	ld b, 0             ; b = current slot index
.ScanLoop
	ld a, b
	cp c
	jr nc, .NotFound    ; checked all slots
	push bc
	; Navigate to the Type byte: sMailboxes + b * MAIL_STRUCT_LENGTH + (MAIL_STRUCT_LENGTH - 1)
	ld hl, sMailboxes
	ld bc, MAIL_STRUCT_LENGTH
	call AddNTimes      ; a = b = slot index (still in a from ld a,b above, before push bc)
	ld bc, MAIL_STRUCT_LENGTH - 1
	add hl, bc          ; hl = address of Type byte for this slot
	ld a, BANK(sMailboxCount)
	call OpenSRAM
	ld a, [hl]
	call CloseSRAM
	pop bc              ; restore b = index, c = count
	cp FLOWER_MAIL
	jr z, .Found
	inc b
	jr .ScanLoop
.Found
	; b = slot index to remove
	farcall DeleteMailFromPC
	ld a, 1
	ld [wScriptVar], a
	ret
.NotFound
	xor a
	ld [wScriptVar], a
	ret