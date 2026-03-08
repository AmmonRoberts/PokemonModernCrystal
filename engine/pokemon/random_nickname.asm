GiveRandomNickname::
; Gives the Pokemon at de a random nickname from the list.
; Inputs:
;   de = pointer to nickname destination

	push de
	
	; Check if auto-nickname is enabled
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	jr z, .no_auto_nickname
	
	; Get a random name index from the list
	ld a, NUM_RANDOM_NAMES
	call RandomRange
	; a now contains a random index from 0 to NUM_RANDOM_NAMES-1
	
	; Calculate offset using AddNTimes: hl = RandomPokemonNames + (a * MON_NAME_LENGTH)
	ld hl, RandomPokemonNames
	ld bc, MON_NAME_LENGTH
	call AddNTimes
	
	; hl now points to the random name
	pop de
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	and a ; clear carry to indicate success
	ret

.no_auto_nickname
	pop de
	scf ; set carry to indicate failure
	ret
NicknameStarterPokemon::
; Handles nicknaming for a starter Pokemon
; If auto-nickname is enabled, gives a random nickname
; Otherwise, prompts the player to nickname
; Inputs:
;   de = pointer to nickname destination

	push de
	
	; Check if auto-nickname is enabled
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	jr z, .ask_for_nickname
	
	; Auto-nickname is enabled, apply random nickname
	pop de
	ld hl, RandomPokemonNames
	ld a, NUM_RANDOM_NAMES
	call RandomRange
	ld bc, MON_NAME_LENGTH
	call AddNTimes
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	ret

.ask_for_nickname
	; Auto-nickname is disabled, prompt player to nickname
	; First show the "Do you want to nickname?" prompt
	pop de
	push de
	ld hl, AskNicknameText
	call PrintText
	call YesNoBox
	pop de
	jr c, .skip_naming
	; Player said yes, open naming screen
	push de
	call LoadStandardMenuHeader
	call DisableSpriteUpdates
	pop de
	push de
	ld a, PARTYMON
	ld [wMonType], a
	xor a
	ld [wCurPartyMon], a
	pop de
	push de
	ld b, NAME_MON
	farcall NamingScreen
	pop hl
	ld de, wStringBuffer1
	call InitName
	ld a, $4
	ld hl, ExitAllMenus
	rst FarCall
	ret
.skip_naming
	ret

AskNicknameText:
	text_far _CaughtAskNicknameText
	text_end
