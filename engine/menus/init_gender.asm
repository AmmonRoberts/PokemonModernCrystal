InitCrystalData:
	ld a, $1
	ld [wPlayerPrefecture], a
	xor a
	ld [wPlayerAge], a
	ld [wPlayerGender], a
	ld [wRandoFlags], a
	ld [wModFlags], a
	ld [wRareCandyMart], a
	ld a, 2 ; default EXP multiplier = 100%
	ld [wExpMultiplier], a
	xor a
	ld [wRandomStarter1], a
	ld [wRandomStarter2], a
	ld [wRandomStarter3], a
	ld [wPermafaint], a
	ld a, PARTY_LENGTH
	ld [wPartyLimit], a
	xor a
	ld [wGiftRandMode], a  ; default = GIFT_RAND_STANDARD
	ld [wTypeMatchupSeed], a
	xor a
	ld [wPlayerPostalCode], a
	ld [wPlayerPostalCode+1], a
	ld [wPlayerPostalCode+2], a
	ld [wPlayerPostalCode+3], a
	ld [wd002], a
	ld [wd003], a
	ld a, [wCrystalFlags]
	res 0, a ; ???
	ld [wCrystalFlags], a
	ld a, [wCrystalFlags]
	res 1, a ; ???
	ld [wCrystalFlags], a
	ret

INCLUDE "mobile/mobile_12.asm"

InitGender:
	call InitGenderScreen
	call LoadGenderScreenPal
	call LoadGenderScreenLightBlueTile
	call WaitBGMap2
	call SetDefaultBGPAndOBP
	ld hl, AreYouABoyOrAreYouAGirlText
	call PrintText
	ld hl, .MenuHeader
	call LoadMenuHeader
	call WaitBGMap2
	call VerticalMenu
	call CloseWindow
	ld a, [wMenuCursorY]
	dec a
	ld [wPlayerGender], a
	ld c, 10
	call DelayFrames
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 6, 4, 12, 9
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_WRAP | STATICMENU_DISABLE_B ; flags
	db 2 ; items
	db "Boy@"
	db "Girl@"

AreYouABoyOrAreYouAGirlText:
	text_far _AreYouABoyOrAreYouAGirlText
	text_end

; Individual init functions (InitWildEncounterType, InitStarterRandomization, InitTMMode)
; have been removed and replaced by the unified _NewGameOptions menu

GenerateTypeMatchupTable:
; Regenerate wTypeMatchupTable from wTypeMatchupSeed.
; Must be called after wTypeMatchupSeed is set (new game) or loaded (continue).
; wTypeMatchupSeed lives in WRAMX bank 1; wTypeMatchupTable lives in WRAMX bank 2.
; Uses a 16-bit Galois LFSR seeded from wTypeMatchupSeed.
; If RANDFLAG_TYPE_RAND_F is clear, the table is filled with EFFECTIVE (10).
;
; Table layout: 18x18 bytes, index = compact(attacker)*18 + compact(defender).
; Compact type: if type >= SPECIAL (20) subtract 10; else use as-is.
; Values: NO_EFFECT(0) / NOT_VERY_EFFECTIVE(5) / EFFECTIVE(10) / SUPER_EFFECTIVE(20).
; LFSR bits[1:0]:  00->EFFECTIVE  01->SUPER_EFFECTIVE  10->NOT_VERY_EFFECTIVE  11->NO_EFFECT

	push bc
	push de
	push hl

	; --- Read inputs from WRAMX bank 1 before any bank switch ---
	; Seed -> HL: H = wTypeMatchupSeed, L = 0 (1-byte seed in H for 255 unique starts)
	ld a, [wTypeMatchupSeed]
	ld h, a
	ld l, 0
	; Rando flag check -> B (non-zero = randomized)
	ld a, [wRandoFlags]
	and 1 << RANDFLAG_TYPE_RAND_F
	ld b, a

	; --- Switch to WRAMX bank 2 for table writes; save old bank on stack ---
	ldh a, [rWBK]
	push af			; stack: ... [bc][de][hl][old_wbk]
	ld a, BANK(wTypeMatchupTable)
	ldh [rWBK], a

	; --- Decide fill mode (B = 0: fill EFFECTIVE, nonzero: fill random) ---
	ld a, b
	and a
	jr nz, .fill_random

	; --- Fill with EFFECTIVE (= 10) ---
	ld de, wTypeMatchupTable
	ld bc, TYPE_MATCHUP_TABLE_STRIDE * TYPE_MATCHUP_TABLE_STRIDE
	ld a, EFFECTIVE
.fill_effective:
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	ld a, EFFECTIVE
	jr nz, .fill_effective
	jr .done

.fill_random:
	; If seed is 0, force a non-zero start so the LFSR doesn't get stuck
	ld a, h
	or l
	jr nz, .seed_ok
	ld h, $AC
	ld l, $E1
.seed_ok:
	ld de, wTypeMatchupTable
	ld bc, TYPE_MATCHUP_TABLE_STRIDE * TYPE_MATCHUP_TABLE_STRIDE
.loop:
	; 16-bit Galois LFSR step (polynomial $B400)
	; if bit 0 of HL is set, XOR H with $B4
	ld a, l
	rra			; carry = old bit 0; L >>= 1
	ld l, a
	ld a, h
	rra			; H >>= 1 (with carry from L's shift)
	ld h, a
	jr nc, .no_feedback
	ld a, h
	xor $B4
	ld h, a
.no_feedback:
	; Map bits [1:0] of H to an effectiveness constant
	; (L is used for shift feedback only; the entropy is in H)
	ld a, h
	and %00000011
	; 0->EFFECTIVE(10)   1->SUPER_EFFECTIVE(20)
	; 2->NOT_VERY_EFFECTIVE(5)   3->NO_EFFECT(0)
	jr z, .eff
	dec a
	jr z, .super
	dec a
	jr z, .nve
	; 3: NO_EFFECT (0)
	ld a, NO_EFFECT
	jr .store
.super:
	ld a, SUPER_EFFECTIVE
	jr .store
.nve:
	ld a, NOT_VERY_EFFECTIVE
	jr .store
.eff:
	ld a, EFFECTIVE
.store:
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop

.done:
	; Restore the previous WRAMX bank (was pushed before the bank switch)
	pop af
	ldh [rWBK], a

	pop hl
	pop de
	pop bc
	ret


GenerateRandomStarters:
; Generate three unique random Pokemon species (1-251)
; Store them in wRandomStarter1, wRandomStarter2, wRandomStarter3
	
.generate_first
	call Random
	and a
	jr z, .generate_first ; avoid 0
	cp NUM_POKEMON + 1
	jr nc, .generate_first ; avoid > 251
	ld [wRandomStarter1], a
	
.generate_second
	call Random
	and a
	jr z, .generate_second ; avoid 0
	cp NUM_POKEMON + 1
	jr nc, .generate_second ; avoid > 251
	ld b, a
	ld a, [wRandomStarter1]
	cp b
	jr z, .generate_second ; same as first, try again
	ld a, b
	ld [wRandomStarter2], a
	
.generate_third
	call Random
	and a
	jr z, .generate_third ; avoid 0
	cp NUM_POKEMON + 1
	jr nc, .generate_third ; avoid > 251
	ld b, a
	ld a, [wRandomStarter1]
	cp b
	jr z, .generate_third ; same as first, try again
	ld a, [wRandomStarter2]
	cp b
	jr z, .generate_third ; same as second, try again
	ld a, b
	ld [wRandomStarter3], a
	ret

InitGenderScreen:
	ld a, $10
	ld [wMusicFade], a
	ld a, LOW(MUSIC_NONE)
	ld [wMusicFadeID], a
	ld a, HIGH(MUSIC_NONE)
	ld [wMusicFadeID + 1], a
	ld c, 8
	call DelayFrames
	call ClearBGPalettes
	; Removed InitCrystalData call from here - it's now only called in InitGender
	call LoadFontsExtra
	hlcoord 0, 0
	ld bc, SCREEN_AREA
	ld a, $0
	call ByteFill
	hlcoord 0, 0, wAttrmap
	ld bc, SCREEN_AREA
	xor a
	call ByteFill
	ret

LoadGenderScreenPal:
	ld hl, .Palette
	ld de, wBGPals1
	ld bc, 1 palettes
	ld a, BANK(wBGPals1)
	call FarCopyWRAM
	farcall ApplyPals
	ret

.Palette:
INCLUDE "gfx/new_game/gender_screen.pal"

LoadGenderScreenLightBlueTile:
	ld de, .LightBlueTile
	ld hl, vTiles2 tile $00
	lb bc, BANK(.LightBlueTile), 1
	call Get2bpp
	ret

.LightBlueTile:
INCBIN "gfx/new_game/gender_screen.2bpp"
